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

M(env)

"""
The reason is that the default state style of env is Observation{String}(). So we need to set the default state style to Observation{Int}().
"""

E = DefaultStateStyleEnv{Observation{Int}()}(env)

state(E)

explorer = EpsilonGreedyExplorer(kind=:exp, 0.1)

begin
    values = [1, 2, 3, 1]
    N = 1000
    actions = [explorer(values) for _ in 1:N]
    println([sum(actions .== i)/N for i in 1:length(values)])
end

function select_action(env, V)
    A = legal_action_space(env)
    values = map(A) do a
        V(child(env, a))
    end
    A[explorer(values)]
end

P = VBasedPolicy(; learner=M, mapping=select_action)

reset!(E)

P(E)

run(P, E, StopAfterEpisode(10), TotalRewardPerEpisode())

"""
Training
One main question we haven't answered is, how to train the policy?

Well, the usage is similar to the above one, the only difference is now we wrap the policy in an Agent, which is also an AbstractPolicy. An Agent is policy + trajectory, or people usually call it experience replay buffer.
"""
policies = MultiAgentManager(
	(
		Agent(
			policy = NamedPolicy(
				p => VBasedPolicy(;
					learner=MonteCarloLearner(;
						approximator = TabularVApproximator(;
							n_state=length(state_space(E)),
							init=0.,
							opt=InvDecay(1.0)
						),
						γ = 1.0,
						kind = FIRST_VISIT,
						sampling = NO_SAMPLING
					),
					mapping = select_action
				)
			),
			trajectory =VectorSARTTrajectory(
					;state=Int,
					action=Union{Int, NoOp},
					reward=Int,
					terminal=Bool
			)
		)
		for p in players(E)
	)...
)

reset!(E)

run(policies, E, StopAfterEpisode(100_000), TotalRewardPerEpisode())

"""
Testing
Now we have our policy trained. We can happily run several self-plays and see the result. The only necessary change is to drop out the Agent wrapper.
"""

test_policies = MultiAgentManager([p.policy for (x, p) in (policies.agents)]...)

hook = MultiAgentHook(
                      (
                       p => TotalRewardPerEpisode()
                       for p in players(E)
                      )...
                     )

run(test_policies, E, StopAfterEpisode(100), hook)
