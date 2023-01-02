### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 1f1e1234-e197-11eb-2860-e3469f9a473b
using PastaQ

# ╔═╡ b3c6df86-6aa4-4927-95c1-0863c0866475
using Plots

# ╔═╡ f4346a8a-6f04-46be-ae7a-185a8745008c
using DataStructures

# ╔═╡ 9c2a13a7-fec3-4cfb-94c0-2ff4f3673927
using DataFrames

# ╔═╡ 68eb86ff-fc65-4ad7-8d25-3cc0a87b2c24
using Statistics

# ╔═╡ 362a9b71-2365-4852-b6a3-95bed8e2afa6
plotly()

# ╔═╡ fbd9f5d1-6980-4f3d-94df-a589557dff4f
function PastaQ.gate(::GateName"R"; theta::Real, phi::Real)
	[
		cos(theta/2)	(-im * exp(-im * phi) * sin(theta/2))
		(-im * exp(im * phi) * sin(theta/2))	cos(theta/2)
	]
end

# ╔═╡ 4c45065d-a85b-4d04-86e9-28a0a9dc077b
function PastaQ.gate(::GateName"M"; Theta::Real)
	[
		cos(Theta)	0 	0 	(-im * sin(Theta))
		0 	cos(Theta)	(-im * sin(Theta))	0
		0 	(-im * sin(Theta))	cos(Theta)	0
		(-im * sin(Theta))	0 	0 	cos(Theta)
	]
end

# ╔═╡ e0ea9326-d736-40c1-a9ec-cd746f01e92a
function run_circuit(N, depth,θ=2pi*rand(),ϕ=2pi*rand(),Θ=2pi*rand(), nshots = 1024)
	#random circuit.
	gates = Vector{Tuple}[]
	
	for i in 1:depth 
		one_qubit_layer = Tuple[]
		two_qubit_layer = Tuple[]
		
		for j in 1:N
			gate = ("R", j, (theta=θ, phi=ϕ))
			push!(one_qubit_layer, gate)
		end
		
		
		# Alternate start qubit for pairs
		idx_first = i % 2 + 1
		
		for j in idx_first:2:(N-1)
			gate = ("M", (j, j+1), (Theta=Θ,))
			push!(two_qubit_layer, gate)
		end
		
		push!(gates, one_qubit_layer)
		push!(gates, two_qubit_layer)
	end

	ψ = runcircuit(N, gates)
	samples = getsamples(ψ,nshots)
	
	states_bits = []
	map(0:2^N -1) do i
		out = reverse(digits(i; base=2, pad=N))
		push!(states_bits, out)
	end
	states_freq = counter(eachrow(samples))
	
	states_prob = [100*states_freq[i]/nshots for i in states_bits]
	
	data = Dict([(string.(i), 100*states_freq[k]/nshots) for (i,k) in enumerate(states_bits)])
	
	return data
	
end

# ╔═╡ c6b0e0ad-9a86-4634-9ce5-8fe6b9656d3e
a = run_circuit(10,512)

# ╔═╡ dd04a3f4-5724-4ab0-8112-05ef1eec9493
df = DataFrame(a)



# ╔═╡ Cell order:
# ╠═1f1e1234-e197-11eb-2860-e3469f9a473b
# ╠═b3c6df86-6aa4-4927-95c1-0863c0866475
# ╠═f4346a8a-6f04-46be-ae7a-185a8745008c
# ╠═9c2a13a7-fec3-4cfb-94c0-2ff4f3673927
# ╠═68eb86ff-fc65-4ad7-8d25-3cc0a87b2c24
# ╠═362a9b71-2365-4852-b6a3-95bed8e2afa6
# ╠═fbd9f5d1-6980-4f3d-94df-a589557dff4f
# ╠═4c45065d-a85b-4d04-86e9-28a0a9dc077b
# ╠═e0ea9326-d736-40c1-a9ec-cd746f01e92a
# ╠═c6b0e0ad-9a86-4634-9ce5-8fe6b9656d3e
# ╠═dd04a3f4-5724-4ab0-8112-05ef1eec9493
