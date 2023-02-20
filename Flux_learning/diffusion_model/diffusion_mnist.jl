using Pkg
Pkg.activate("/home/felipe/Julia_envs/Flux_env/")
using MLDatasets
using Flux
using Flux: @functor, chunk, params
using Flux.Data: DataLoader
using BSON
using CUDA
using Images
using Random
using Statistics


function GaussianFourierProjection(embd_dim, scale)
    W = randn(Float32, embd_dim ÷ 2) .* scale
    function GaussianFourierProject(t)
        t_proj = t' .* W * Float32(2π)
        [sin.(t_proj); cos.(t_proj)]
    end
end

marginal_prob_std(t, σ=25.0f0) = sqrt.((σ .^ (2t) .- 1.0f0) ./ 2.0f0 ./ log(σ))

struct Unet
    layers::NamedTuple
end
function Unet(channels=[1<<i for i in 5:8], embed_dim=256, scale=30.0f0)
    return Unet((
                 gaussfourierproj = GaussianFourierProjection(embd_dim, scale),
                 linear = Dense(embed_dim, embd_dim, swish),
                 #encoding
                 conv1 = Conv((3, 3), 1=> channels[1], stride=1, bias=false),
                 dense1 = Dense(embed_dim, channels[1]),
                 gnorm1 = GroupNorm(channels[1], 4, swish),
                 ###
                 conv2 = Conv((3, 3), channels[1] => channels[2], stride=2, bias=false),
                 dense2 = Dense(embed_dim, channels[2]),
                 gnorm2 = GroupNorm(channels[2], 32, swish),
                 ###
                 conv3 = Conv((3, 3), channels[2] => channels[3], stride=2, bias=false),
                 dense3 = Dense(embed_dim, channels[3]),
                 gnorm3 = GroupNorm(channels[3], 32, swish),
                 ###
                 conv4 = Conv((3, 3), channels[3] => channels[4], stride=2, bias=false),
                 dense4 = Dense(embed_dim, channels[4]),
                 gnorm4 = GroupNorm(channels[4], 32, swish),
                 #decoding
                 tconv4 = ConvTranspose((3, 3), channels[4] => channels[3], stride=2,
                                        bias=false),
                 dense5 = Dense(embed_dim, channels[3]),
                 tgnorme4 = GroupNorm(channels[3], 32, swish),
                 ###
                 tconv3 = ConvTranspose((3, 3), channels[3] + channels[3] => channels[2],
                                        pad=(0, -1, 0, -1), stride=2, bias=false),
                 dense6 = Dense(embed_dim, channels[2]),
                 tgnorme3 = GroupNorm(channels[2], 32, swish),
                 ###
                 tconv2 = ConvTranspose((3, 3), channels[2] + channels[2] => channels[1],
                                        pad=(0, -1, 0, -1), stride=2, bias=false),
                 dense7 = Dense(embed_dim, channels[1]),
                 tgnorme2 = GroupNorm(channels[1], 32, swish),
                 tconv1 = ConvTranspose((3, 3), channels[1] + channels[1] => 1, stride=1, bias=false)
                ))
end

@functor Unet

expand_dims(x::Union{AbstractVector, Matrix}, dims::Int=2) = reshape(x, (ntuple(i -> 1, dims)..., size(x)...))

function (unet::Unet)(x, t)
    #embeding
    embed = unet.layers.gaussfourierproj(t)
    embed = unet.layers.linear(embed)
    #encoder
    h1 = unet.layers.conv1(x)
    h1 = h1 .+ expand_dims(unet.layers.dense1(embed), 2)
    h1 = unet.layers.gnorm1(h1)
    h2 = unet.layers.conv2(h1)
    h2 = h2 .+ expand_dims(unet.layers.dense2(embed), 2)
    h2 = unet.layers.gnorm2(h2)
    h3 = unet.layers.conv3(h2)
    h3 = h3 .+ expand_dims(unet.layers.dense3(embed), 2)
    h3 = unet.layers.gnorm3(h3)
    h4 = unet.layers.conv4(h3)
    h4 = h4 .+ expand_dims(unet.layers.dense4(embed), 2)
    h4 = unet.layers.gnorm4(h4)
    #decoder
    h = unet.layers.tconv4(h4)
    h = h .+ expand_dims(unet.layers.dense5(embed), 2)
    h = unet.layers.tgnorme4(h)
    h = unet.layers.tconv3(cat(h, h3; dims=3))
    h = h .+ expand_dims(unet.layers.dense6(embed), 2)
    h = unet.layers.tgnorme3(h)
    h = unet.layers.tconv2(cat(h, h2; dims=3))
    h = h .+ expand_dims(unet.layers.dense7(embed), 2)
    h = unet.layers.tgnorme2(h)
    h = unet.layers.tconv1(cat(h, h1; dims=3))
    # scaling factor
    h ./ expand_dims(marginal_prob_std(t), 3)
end

function model_loss(model, x, ϵ=1.0f-5)
    batch_size = size(x)[end]
    random_t = rand!(similar(x, batch_size)) .* (1.0f0 -ϵ) .+ ϵ
    z = randn!(similar(x))
    std = expand_dims(marginal_prob_std(random_t), 3)
    perturbed_x = x + z .* std
    score = model(perturbed_x, random_t)
    mean(
         sum((score .* std + z) .^ 2; dims=1:(ndims(x) - 1))
        )
end

function get_data(batch_size)
    xtrain, ytrain = MLDatasets.MNIST(:train)[:]
    xtrain = reshape(xtrain, 28, 28, 1, :)
    DataLoader((xtrain, ytrain), batch_size=batch_size, shuffle=true)
end

function struct2dict(::Type{DT}, s) where {DT<:AbstractDict}
    DT(x => getfield(s, x) for x in fieldnames(typeof(s)))
end


Base.@kwdef mutable struct Args
    η = 1e-4                                        # learning rate
    batch_size = 32                                 # batch size
    epochs = 50                                     # number of epochs
    seed = 1                                        # random seed
    cuda = false                                    # use CPU
    verbose_freq = 10                               # logging for every verbose_freq iterations
    tblogger = true                                 # log training with tensorboard
    save_path = "output"                            # results path
end

function train(; kws)

