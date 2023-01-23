using Pkg

Pkg.activate("../")

zero = Int[1 0]'

one = Int[0 1]'


# quite often we see the states represented as in dirac notation, i.e ∣0⟩ and ∣1⟩
# and their complex conjugate

zero_dagger = Int[1 0]

one_dagger = Int[0 1]


# these two states, ∣0⟩ and ∣1⟩, are particularly important because they form a basis.
# In linear algebra, a basis is a set of vectors that spans a vector space; we can wirte
# anything else in that space as linear combination of the vectors of the basis.
# Bases must consist of linear independent vectors. A special case of this is when the 
# vectors are orthogonal form each other. Orthogonlity can be checked by taking the inner
# product of the basis, however for our qubits the inner product must be computed between
# the vector and the complex conjugate:

zero_dagger * one

# Another special feature of our basis is that the norm of our vectors is 1:

sqrt(zero_dagger * zero)
sqrt(one_dagger * one)

# When the basis consist of vectors which are at the sametime orthogonal and their norm
# is 1 we call this an OrthoNormal basis
#

## Superposition
# Of course, ∣0⟩ and ∣1⟩ are not the only possible states for a qubit (otherwise, 
# they wouldn't be any different from the classical bit). What makes a qubit so 
# special is that they can exist in a superposition state, somewhere "between" ∣0⟩ 
# and ∣1⟩. Mathematically, the state of a qubit in superposition is a linear combination
# of the basis states
# 
# ∣Ψ⟩ = α∣0⟩ + β∣1⟩ = [α β]'
#
# where α and β are complex numbers such that
#
# αα† + ββ† 
#
# the α and β parameters are ofteen called amplitudes, or probability amplitudes, and the
# amplitudes carry information about the relative strength of ∣0⟩ and ∣1⟩ in the given
# state

# Suppose we have two states:
α, β = 0.5 * exp.((2*im*π).*rand(2)) 
ψ = α .* zero + β .* one

γ, δ = 0.5 * exp.((2*im*π).*rand(2))
ϕ = γ .* zero + δ .* one

# and we would like to take the inner product between ⟨ϕ∣Ψ⟩. First, we need to compute
# the bra of ∣ϕ⟩. When a qubit is in a superposition of the basis states, we can compute
# the bra by taking the bra of each basis state one at time

ϕ_bra = conj(γ) .* zero_dagger + conj(δ) .* one_dagger

ϕ_bra .* ψ
