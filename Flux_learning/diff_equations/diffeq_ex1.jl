using Pkg
Pkg.activate("/home/felipe/Julia_envs/DiffEq_env/")
using Statistics
using Random
using LinearAlgebra
using Flux
using Flux:onecold, onehot, onehotbatch
using Flux:crossentropy
using DifferentialEquations
using DiffEqFlux


function goal(x)
    s = sum(x)
    s > length(x)/2
end

train_x = [rand(Float32, 10) for _ in 1:1000]
train_y = goal.(train_x)

val_x = [rand(Float32, 10) for _ in 1:100]
val_y = goal.(val_x)

neural_net = Chain(
                   x -> x.^3,
                   Dense(10 => 5, σ),
                   Dense(5 => 2),
                   softmax
                  )
neural_net(rand(Float32, 10))

_accuracy(x, y) = onecold(neural_net(x), 0:1) == y
acc(x, y) = mean(_accuracy.(x, y))

acc(train_x, train_y)
acc(val_x, val_y)

loss(x, y) = crossentropy(neural_net(x), onehot(y, 0:1))
opt = Flux.Momentum(0.01)
prms = Flux.params(neural_net)

for (x, y) in zip(train_x, train_y)
    gs = Flux.gradient(prms) do
        loss(x, y)
    end
    Flux.update!(opt, prms, gs)
end

acc(train_x, train_y)
acc(val_x, val_y)

#######################
# DifferentialEquations.jl

function lotka_volterra(du, u, p, t)
    x, y = u
    α, β, δ, γ = p
    du[1] = dx = α*x - β*x*y
    du[2] = dy = -δ*y + y*x*y
end
u0 = [1.0, 1.0]
tspan = (0.0, 10.0)
p = [1.5, 1.0, 3.0, 1.0]
ode_problem = ODEProblem(lotka_volterra, u0, tspan, p)

ode_sol = solve(ode_problem)
#######################
p = [2.2, 1.0, 2.0, 0.4]
params = Flux.params(p)

function predict_rd()
    solve(ode_problem, Tsit5(), p=p, saveat=0.1)[1, :]
end

loss_rd() = sum(abs2, x-1 for x in predict_rd())

data = Base.Iterators.repeated((), 100)
opt = Flux.ADAM(0.1)

Flux.train!(loss_rd, params, data, opt)

