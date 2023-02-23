using Pkg
Pkg.activate("../")
using ReinforcementLearning
using Flux

env = TicTacToeEnv()

state(env) |> Text

state(env, Observation{Int}())

state(env, Observation{BitArray{3}}())

for i in 1:7
    env(i)
end
state(env) |> Text

is_terminated(env)

[reward(env, p) for p in players(env)]

reset!(env)

state(env) |> Text

# RandomPolicy

policy = RandomPolicy()

[policy(env) for _ in 1:10]
"""
A policy will never change the internal state of an env. The env will only get updated after executing env(action).
"""
acts = [policy(env) for _ in 1:10]

for act in acts
    env(act)
end

state(env) |> Text

reset!(env)

run(policy, env, StopAfterEpisode(1))

multi_agent_policy = MultiAgentManager(
                                       (
                                        NamedPolicy(p=>RandomPolicy())
                                        for p in players(env)
                                       )...
                                      )
multi_agent_hook = MultiAgentHook(
                                  (
                                   p => TotalRewardPerEpisode()
                                   for p in players(env)
                                  )...
                                 )
run(multi_agent_policy, env, StopAfterEpisode(10), multi_agent_hook)

"""
Tackling the Tic-Tac-Toe Problem with Monte Carlo Prediction
"""

A = TabularVApproximator(;n_state=10, init=0.0, opt=InvDecay(1.0))
A(1)

update!(A, 2 => A(2) - 5.)

begin
    examples = 1:10
    for x in examples
        update!(A, 1 => A(1) - x)
    end
    A(1) == (0. + sum(examples)) / (1+length(examples))
end

M = MonteCarloLearner(;
                    approximator = TabularVApproximator(;
                                                        n_state = 5478,
                                                        init=0.,
                                                        opt=InvDecay(1.0)
                                                       ),
                    γ = 1.0,
                    kind = FIRST_VISIT,
                    sampling = NO_SAMPLING
                   )
M(1)

"""
to continue -> https://juliareinforcementlearning.org/ReinforcementLearningAnIntroduction.jl/notebooks/Chapter01_Tic_Tac_Toe.html
"""
