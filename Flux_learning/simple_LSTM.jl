using Pkg
Pkg.activate("/home/felipe/Julia_envs/DiffEq_env/")
using Lux
using MLUtils
using Optimisers
using Zygote
using NNlib
using Random
using Statistics

############################################
# acbaou os imports

## Dataset
function get_dataloaders(; data_size=1000, sequence_length=50)
    # make spirals
    data = [MLUtils.Dataset.make_spiral(sequence_length) for _ in 1:data_size]
    # get labels
    labels = vcat(repeat([0.0f0], data_size ÷ 2), repeat([1.0f0], data_size ÷ 2))
    clockwise_spirals = [reshape(d[1][:, 1:sequence_length], :, sequence_length, 1)
                         for d ∈ data[1:(data_size ÷ 2)]]
    counterclockwise = [reshape(d[1][:, (sequence_length + 1):end], :, sequence_length, 1)
                        for d ∈ data[((data_size ÷ 2) +1):end]]
    x_data = Float32.(cat(clockwise_spirals..., counterclockwise...; dims=3))
    # Split dataset
    (x_train, y_train), (x_test, y_test) = splitobs((x_data, labels); at=0.8, shuffle=true)
    return (
            DataLoader(collect.((x_train, y_train)), batchsize=128, shuffle = true),
            DataLoader(collect.((x_test, y_test)), batchsize=128, shuffle = false)
           )
end

# creating model

struct SpiralClassifier{L, C} <: Lux.AbstractExplicitContainerLayer{(:lstm_cell, :classifier)}
    lstm_cell::L
    classifier::C
end


function SpiralClassifier(in_dims, hidden_dims, out_dims)
    return SpiralClassifier(LSTMCell(in_dims => hidden_dims),
                            Dense(hidden_dims => out_dims, sigmoid))
end

function (s::SpiralClassifier)(x::AbstractArray{T, 3}, ps::NamedTuple,
                               st::NamedTuple) where {T}
    x_init, x_rest = Iterators.peel(eachslice(x; dims=2))
    (y, carry), st_lstm = s.lstm_cell(x_init, ps.lstm_cell, st.lstm_cell)
    for x in x_rest
        (y, carry), st_lstm = s.lstm_cell((x, carry), ps.lstm_cell, lstm_cell)
    end
    y, st_classifier = s.classifier(y, ps.classifier, st.classifier)
    st = merge(st, (classifier=st_classifier, lstm_cell=st_lstm))
    return vec(y), st
end

function xlogy(x, y)
    result = x * log(y)
    return ifelse(iszero(x), zero(result), result)
end


function binarycrossentropy(y_pred, y_true)
    y_pred = y_pred .+ eps(eltype(y_pred))
    return mean(@. -xlogy(y_true, y_pred) - xlogy(1 - y_true, 1 - y_pred))
end

function compute_loss(x, y, model, ps, st)
    y_pred, st = model(x, ps, st)
    return binarycrossentropy(y_pred, y), y_pred, st
end

matches(y_pred, y_true) = sum((y_pred .> 0.5) .== y_true)
accuracy(y_pred, y_true) = matches(y_pred, y_true)/ length(y_pred)

function create_optimiser(ps)
    opt = Optimisers.ADAM(0.01f0)
    return Optimisers.setup(opt, ps)
end
