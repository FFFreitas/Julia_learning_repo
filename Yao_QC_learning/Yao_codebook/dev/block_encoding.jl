using Pkg

Pkg.activate("../")

using Yao, YaoPlots
using LinearAlgebra, Statistics, Random
using StatsBase
using MAT
using Printf
using Flux
using Flux: batch
include("./Layers.jl")


vars = matread("/home_2/Datasets/fashion_MNIST/FashionMNIST_1_2_wk.mat")
x_train = vars["x_train"]
y_train = vars["y_train"]
x_test = vars["x_test"]
y_test = vars["y_test"]
num_qubits = 10

num_train = 500
num_test = 100


c = 2
x_train = real(x_train[:, 1:num_train])*c
y_train = y_train[1:num_train,:]
x_test = real(x_test[:, 1:num_test])*c
y_test = y_test[1:num_test,:]

depth = 9
circuit = chain(chain(num_qubits, params_layer(num_qubits),
                      ent_cx(num_qubits)) for _ in 1:depth)


vizcircuit(circuit; filename=joinpath(@__DIR__, "circ_block_encoder.png"))
