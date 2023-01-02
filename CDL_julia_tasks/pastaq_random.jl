### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 34fb116e-de5c-11eb-27db-f5fd9131e20b
using PastaQ

# ╔═╡ ce6a19dd-4cc2-4d1f-ba91-8a392ac5f4d3
using ITensors

# ╔═╡ 7d30e0c4-ac75-4dba-8edb-87bfe4e4d94c
using Random

# ╔═╡ 75471344-5d65-4ebd-9f20-3b021b6452ff
Random.seed!(1234)

# ╔═╡ b6ea9aa2-b379-49e2-a9d3-12d109cc7119
N = 4

# ╔═╡ 74bbf96b-4299-43ef-89ff-a309bf644d0e
depth = 4

# ╔═╡ 9a180cd1-a484-4b40-b483-151876d4ae10
md"Random circui of depth $depth on $N qubits"

# ╔═╡ 2f304149-9db9-438d-9edd-0ae3e1ee01f6
circuit = randomcircuit(N, depth; twoqubitgates="CX", onequbitgates="Rn")

# ╔═╡ 59b6883b-9aae-4511-8656-6d3b6e1d05f1
md"""
Applying random circuit to compute
"""

# ╔═╡ 03b1f2d9-c941-481f-8755-9d391026fcac
psi = runcircuit(circuit)

# ╔═╡ 4a832220-9d95-4d98-9136-b97337003cea
@show maxlinkdim(psi)

# ╔═╡ a512e83b-d7b8-4c4d-8d03-9b2405c48124
md"""
Approximating random circuit as an MPO U...
"""

# ╔═╡ 81983ec6-3b40-41f7-9464-1f49b4b334b3
U = runcircuit(circuit; process=true)

# ╔═╡ 4c54e479-62ea-4945-b11b-36c2b4730d76
@show maxlinkdim(U)

# ╔═╡ e942bc97-e3fb-4847-a191-37ac42732803
md"""
Running the circuit with amplitude damping to compute the state
"""

# ╔═╡ 8daae81a-2010-48e0-9646-202abe5af8e3
lambda = runcircuit(circuit; process=true, noise=("amplitude_damping", (γ=0.01,)))

# ╔═╡ 5fbb0980-a7f4-4209-a0d8-47e434712dac
@show maxlinkdim(lambda)

# ╔═╡ Cell order:
# ╠═34fb116e-de5c-11eb-27db-f5fd9131e20b
# ╠═ce6a19dd-4cc2-4d1f-ba91-8a392ac5f4d3
# ╠═7d30e0c4-ac75-4dba-8edb-87bfe4e4d94c
# ╠═75471344-5d65-4ebd-9f20-3b021b6452ff
# ╠═b6ea9aa2-b379-49e2-a9d3-12d109cc7119
# ╠═74bbf96b-4299-43ef-89ff-a309bf644d0e
# ╠═9a180cd1-a484-4b40-b483-151876d4ae10
# ╠═2f304149-9db9-438d-9edd-0ae3e1ee01f6
# ╟─59b6883b-9aae-4511-8656-6d3b6e1d05f1
# ╠═03b1f2d9-c941-481f-8755-9d391026fcac
# ╠═4a832220-9d95-4d98-9136-b97337003cea
# ╟─a512e83b-d7b8-4c4d-8d03-9b2405c48124
# ╠═81983ec6-3b40-41f7-9464-1f49b4b334b3
# ╠═4c54e479-62ea-4945-b11b-36c2b4730d76
# ╟─e942bc97-e3fb-4847-a191-37ac42732803
# ╠═8daae81a-2010-48e0-9646-202abe5af8e3
# ╠═5fbb0980-a7f4-4209-a0d8-47e434712dac
