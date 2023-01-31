using Pkg

Pkg.activate("../")

using Yao
using Yao.EasyBuild: variational_circuit
import Yao: tracedist
using Test, Random


struct QuGAN
    nqubits::Int
    target::ArrayReg
    generator::AbstractBlock
    discriminator::AbstractBlock
    reg0::ArrayReg
    witness_op::AbstractBlock
    circuit::AbstractBlock

    function QuGAN(target::ArrayReg, gen::AbstractBlock, dis::AbstractBlock)
        N = nqubits(target)
        c = chain(subroutine(N+1, gen,1:N), dis)
        witness_op = put(N+1, (N+1)=>ConstGate.P0)
        new(N+1, join(zero_state(1), target), subroutine(N+1, gen, 1:N), dis, zero_state(N+1), witness_op, c)
    end
end

# Interfaces
circuit(qg::QuGAN) = qg.circuit
loss(qg::QuGAN) = p0t(qg) - p0g(qg)

function gradient(qg::QuGAN)
    grad_gen = expect'(qg.witness_op, qg.reg0 => qg.circuit).second
    grad_tar = expect'(qg.witness_op, qg.target => qg.circuit[2]).second
    ngen = nparameters(qg.generator)
    [-grad_gen[1:ngen]; grad_tar - grad_gen[ngen+1:end]]
end

"""probability bla bla bla"""
p0g(qg::QuGAN) = expect(qg.witness_op, qg.reg0 => qg.circuit) |> real
p0t(qg::QuGAN) = expect(qg.witness_op, qg.target => qg.circuit[2]) |> real
outputψ(qg::QuGAN) = copy(qg.reg0) |> qg.generator

"""trace distance"""
tracedist(qg::QuGAN) = tracedist(qg.target, outputψ(qg))[]

###

Random.seed!(42)

nbits = 3
depth_gen = 4
depth_dis = 4

# Define a quantum GAN

target = rand_state(nbits)
generator = dispatch!(variational_circuit(nbits, depth_gen), :random)
discriminator = dispatch!(variational_circuit(nbits+1, depth_dis), :random)

qg = QuGAN(target, generator, discriminator)

# check gradients

grad = gradient(qg)

# learning rates for generator and discriminator
g_lr = 0.2
d_lr = 0.5

for i ∈ 1:300
    ng = nparameters(qg.generator)
    grad = gradient(qg)
    dispatch!(-, qg.generator, grad[1:ng]*g_lr)
    dispatch!(-, qg.discriminator, grad[ng+1:end]*d_lr)
    println("Step $i, trace distance = $(tracedist(qg))")
end

@test  qg |> loss < 0.1
qg |> loss
