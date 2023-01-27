using Pkg

Pkg.activate("/home/felipe/Julia_envs/Flux_env/")

using Statistics
using Flux, Flux.Optimise
using MLDatasets: CIFAR10
using Images.ImageCore
using Flux: onehotbatch, onecold
using Flux: crossentropy, Momentum
using Flux: params
using Base.Iterators: partition


# carregando os dados

train_x, train_y = CIFAR10(:train)[:]
labels = onehotbatch(train_y, 0:9)

image(x) = colorview(RGB, permutedims(x, (3,2,1)))

train_x[:,:,:,rand(1:end)]

size(train_x)
size(labels)

# as primeiras 49k (cada batch tem 1000) vao ser nosso conjunto de treino, equanto
# que o resto vai ser nosso conjunto de teste. Vamos usar a funcao partition para 
# dividir nosso conjunto

train = ([(train_x[:,:,:, i], labels[:, i]) for i in partition(1:49000, 1000)])
valset = 49001:50000
valX = train_x[:,:,:, valset]
valy = labels[:, valset]

# construindo o modelo

m = Chain(
          Conv((5,5), 3 => 16, relu),
          MaxPool((2,2)),
          Conv((5,5), 16 => 8, relu),
          MaxPool((2,2)),
          x -> reshape(x, :, size(x, 4)),
          Dense(200, 120),
          Dense(120, 84),
          Dense(84, 10),
          softmax
         ) 


# escrevendo a loss

loss(x, y) = sum(crossentropy(m(x), y))
opt = Momentum(0.01)

# e uma metrica

accuracy(x, y) = mean(onecold(m(x), 0:9) .== onecold(y, 0:9))

epochs = 10

for epoch ∈ 1:epochs
    for d ∈ train
        gs = gradient(params(m)) do
            l = loss(d...)
        end
        update!(opt, params(m), gs)
    end
    @show accuracy(valX, valy)
end


tt = rand(Float32, (32,32,3,1)) |>gpu

m(tt)
