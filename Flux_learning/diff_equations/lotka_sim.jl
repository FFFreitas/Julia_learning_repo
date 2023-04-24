using Pkg
Pkg.activate("/home/felipe/Julia_envs/DiffEq_env/")
using ModelingToolkit
using DifferentialEquations
using Plots


@variables t x(t)=1 y(t)=1 z(t)=2

@parameters α=1.5 β=1.0 γ=3.0 δ=1.0

D = Differential(t)

eqs = [D(x) ~ α * x - β * x * y
       D(y) ~ -γ * y + δ * x * y
       z ~ x + y]

@named sys = ODESystem(eqs, t)

simpsys = structural_simplify(sys)

tspan = (0.0, 10.0)
prob = ODEProblem(simpsys, [], tspan)

sol = solve(prob)

p1 = plot(sol, title = "Rabbits vs Wolves")
p2 = plot(sol, idxs = z, title = "Total Animals")

plot(p1, p2, layout = (2,1))
