using Pkg

Pkg.activate("../LS_EDF_QC/")

using Yao, LinearAlgebra 
using YaoPlots
using Optimisers


function gausian_pdf(x, μ::Real, σ::Real)
    pl = @. 1 / sqrt(2pi * σ^2) * exp(-(x - μ)^2 / (2 * σ^2))
    pl / sum(pl)
end

pg = gausian_pdf(1:1<<6, 1<<5-0.5, 1<<4)


# the circuit

chain(Rz(0.0), Rx(0.0), Rz(0.0))


layer(nbit::Int, x::Symbol) = layer(nbit, Val(x))

layer(nbit::Int, ::Val{:first}) = chain(nbit, put(i => chain(Rx(0), Rz(0))) for i ∈ 1:nbit)

layer(nbit::Int, ::Val{:last}) = chain(nbit, put(i=>chain(Rz(0), Rx(0))) for i = 1:nbit)
layer(nbit::Int, ::Val{:mid}) = chain(nbit, put(i=>chain(Rz(0), Rx(0), Rz(0))) for i = 1:nbit);

# Entangler

entangler(pairs) = chain(control(ctrl, target=>X) for (ctrl, target) in pairs)

function build_circuit(n, nlayers, pairs)
    circuit = chain(n)
    push!(circuit, layer(n, :first))
    for i in 2:nlayers
        push!(circuit, cache(entangler(pairs)))
        push!(circuit, layer(n, :mid))
    end
    push!(circuit, cache(entangler(pairs)))
    push!(circuit, layer(n, :last))
    return circuit
end

teste_circuit = build_circuit(4, 1, [1=>2, 2=>3, 3=>4])

vizcircuit(teste_circuit; filename=joinpath(@__DIR__, "teste_circuit.png"))

# The MMD Loss and Gradients

struct RBFKernel
    σ::Float64
    m::Matrix{Float64}
end

function RBFKernel(σ::Float64, space)
    dx2 = (space .- space').^2
    return RBFKernel(σ, exp.(-1/2σ * dx2))
end

kexpect(κ::RBFKernel, x, y) = x' * κ.m * y 

get_prob(qcbm) = probs(zero_state(nqubits(qcbm)) |> qcbm)

function loss(κ, c, target)
    p = get_prob(c) - target
    return kexpect(κ, p, p)
end

# Gradient

function gradient(qcbm, κ, ptrain)
    n = nqubits(qcbm)
    prob = get_prob(qcbm)
    grad = zeros(Float64, nparameters(qcbm))

    count = 1
    for k in 1:2:length(qcbm), each_line in qcbm[k], gate in content(each_line)
        dispatch!(+, gate, π/2)
        probs_pos = probs(zero_state(n) |> qcbm)

        dispatch!(-, gate, π)
        probs_neg = probs(zero_state(n) |> qcbm)

        dispatch!(+, gate, π/2)

        grad_pos = kexpect(κ, prob, probs_pos) - kexpect(κ, prob, probs_neg)
        grad_neg = kexpect(κ, ptrain, probs_pos) - kexpect(κ, ptrain, probs_neg)
        grad[count] = grad_pos - grad_neg
        count += 1
    end
    return grad
end


qcbm = build_circuit(6, 10, [1=>2, 3=>4, 5=>6, 2=>3, 4=>5, 6=>1])

dispatch!(qcbm, :random)

κ = RBFKernel(0.25, 0:2^6-1)

pg = gausian_pdf(1:1<<6, 1<<5-0.5, 1<<4)
opt = Optimisers.setup(Optimisers.ADAM(0.01), parameters(qcbm))

function train(qcbm, κ, opt, target)
    history = Float64[]
    for _ ∈ 1:100
        train_loss = loss(κ, qcbm, target)
        push!(history, train_loss)
        ps = parameters(qcbm)
        Optimisers.update!(opt, ps, gradient(qcbm, κ, target))
        dispatch!(qcbm, ps)
    end
    return history
end

history = train(qcbm, κ, opt, pg)

# can plot the loss 

trained_pg = probs(zero_state(nqubits(qcbm)) |> qcbm)

pg .- trained_pg
