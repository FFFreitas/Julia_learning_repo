using Pkg

Pkg.activate("../")

using Yao, YaoPlots
YaoPlots.CircuitStyles.gate_bgcolor[] = "white"

circuit = chain(2, put(1 => X), put(2 => X))

vizcircuit(circuit; filename=joinpath(@__DIR__, "test.png"))

# suppose now we have 5 Qubits and we need to fill all of them with
# X gate:

circuit = chain(5, repeat(X, 1:5))

vizcircuit(circuit; filename=joinpath(@__DIR__, "5Qubits.png"))

# and how about circuits with other gates? like X, Y, Z and H?

circuit = chain(3, put(1 => Y), put(2 => Z), put(3 => H), repeat(Y, 1:2),
		repeat(Z, 1:2), repeat(H, [1 3]))

vizcircuit(circuit; filename=joinpath(@__DIR__, "3Qubits_XYH.png"))

# and multiple gates?

circuit = chain(2, control(1, 2 => X))

vizcircuit(circuit; filename=joinpath(@__DIR__, "control_gate.png"))

