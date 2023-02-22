using Pkg
Pkg.activate("../")
using ReinforcementLearning
using Flux: InvDecay


#defining an enviroment

env = RandomWalk1D()

# the space of states
S = state_space(env)

# The current state
s = state(env)

# The action space
A = action_space(env)

is_terminated(env)

while true
    env(rand(A))
    is_terminated(env) && break
end

state(env)

reward(env)

####
run(
    RandomPolicy(),
    RandomWalk1D(),
    StopAfterEpisode(10),
    TotalRewardPerEpisode()
   )

NS, NA = length(S), length(A)

policy = TabularPolicy(; table=Dict(zip(1:NS, fill(2, NS))))

run(
    policy,
    RandomWalk1D(),
    StopAfterEpisode(10),
    TotalRewardPerEpisode()
   )

policy = QBasedPolicy(
                      learner = MonteCarloLearner(;
                                                  approximator=TabularQApproximator(
                                                                                    ;n_state = NS,
                                                                                    n_action = NA,
                                                                                    opt = InvDecay(1.0)
                                                                                   )

                                                 ),
                      explorer = EpsilonGreedyExplorer(0.1)
                     )

run(
    policy,
    RandomWalk1D(),
    StopAfterEpisode(10),
    TotalRewardPerEpisode()
   )

agent = Agent(
              policy = policy,
              trajectory = VectorSARTTrajectory()
             )

run(agent, env, StopAfterEpisode(10), TotalRewardPerEpisode())
