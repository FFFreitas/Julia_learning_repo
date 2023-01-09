using Flux
using Functors

struct Model
    layers::Any
end

function Model(inplanes::Integer, outplanes::Integer)
    conv1=Conv((3,3), inplanes => 8)
    conv2=Conv((3,3), 8=>outplanes)
    layers = Chain(conv1, conv2);
    return layers
end

(model::Model)(x::AbstractArray) = model(x)

model = Model(3, 5)
x = ones(12,12,3,1)

println(model(x) |> size)

#Flux follows (H, W, C, N) standard for images while PyTorch uses (C, N, H, W)

function unet_block(in_chs::Int, out_chs::Int, kernel = (3,3))
    return Chain(
                 conv1 = Conv(kernel, in_chs => out_chs; 
                              pad = (1, 1), 
                              init = Flux.glorot_normal
                             ),
                 norm1 = BatchNorm(out_chs, relu),
                 conv2 = Conv(kernel, out_chs => out_chs;
                              pad = (1, 1),
                              init = Flux.glorot_normal
                             ),
                 norm2 = BatchNorm(out_chs, relu)
                )
end

#Flux doesn’t allow us to name the layers explicitly

struct UNet
    encoder::Any
    decoder::Any
    upconv::Any
    pool::Any
    bottleneck::Any
    final_conv::Any
end

@functor UNet

function upconv_block(in_chs::Int, out_chs::Int, kernel = (2, 2))
    return ConvTranspose(kernel, in_chs => out_chs; 
                         stride = (2, 2),
                         init = Flux.glorot_normal
                        )
end

function UNet(in_channels::Integer = 3, inplanes::Integer = 32,
        outplanes::Integer = inplanes)
    features = inplanes

    encoder_layers = []
    append!(encoder_layers, [unet_block(in_channels, features)])
    append!(encoder_layers, [unet_block(features * 2^i, features * 2^(i+1)) for i in 0:2])

    encoder = Chain(encoder_layers)
    bottleneck = unet_block(features * 8, features * 16)
    decoder = Chain([unet_block(features * 2^(i + 1), features * 2^i) for i in 0:3])
    pool = Chain([MaxPool((2,2); stride = (2,2)) for _ in 1:4])
    upconv = Chain([upconv_block(features * 2^(i + 1), features * 2^i) for i in 3:-1:0])
    final_conv = Conv((1, 1), features => outplanes)

    return UNet(encoder, decoder, upconv, pool, bottleneck, final_conv)
end

function (u::UNet)(x::AbstractArray)
    enc_out = []

    out = x
    for i in 1:4
        out = u.encoder[i](out)
        push!(enc_out, out)

        out = u.pool[i](out)
    end

    out = u.bottleneck(out)

    for i in 4:-1:1
        out = u.upconv[5 - i](out)
        out = cat(out, enc_out[i]; dims = 3)
        out = u.decoder[i](out)
    end

    return σ(u.final_conv(out))
end

u = UNet()
println(u)
