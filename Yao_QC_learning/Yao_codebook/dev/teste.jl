using Pkg

Pkg.activate("../")

using Yao, LinearAlgebra 
using YaoPlots
using Flux

# here is the thing, we can create a dense layer using Flux
m = Dense(10,32)
# and chose the size of the output to the qubits size

qlayer(nbit::Int, x::Symbol) = qlayer(nbit, Val(x))
qlayer(nbit::Int, ::Val{:first}) = chain(nbit, put(i => chain(Rx(0), Rz(0))) for i ∈ 1:nbit)

circ = chain(5, put(i=>X) for i in 1:5)
circ = qlayer(5, :first)


# we can take the output from a layer, convert to complex number
tt = convert.(Complex{Float32}, m(rand(Float32, 10)))

# and feed the output to a quantum state

st = zero_state(5, nbatch=1)

# by doing this:
st.state .= tt

# or this
real(st.state) .= m(rand(Float32, 10))

out = st |> circ

measure(out, nshots=1024)
