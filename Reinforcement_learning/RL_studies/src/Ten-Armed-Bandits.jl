using Pkg
Pkg.activate("../")
using ReinforcementLearning
using Statistics
using Flux

env = MultiArmBanditsEnv()

rwrd = [
 [
  begin
      reset!(env)
      env(a)
      reward(env)
  end
  for _ in 1:100
 ]
 for a in action_space(env)
]

for b_r in rwrd
    println(mean(b_r))
    println(std(b_r))
end

Base.@kwdef struct CollectBestActions <: AbstractHook
    best_action::Int
    isbest::Vector{Bool} = []
end

function (h::CollectBestActions)(::PreActStage, agent, env, action)
    push!(h.isbest, h.best_action == action)
end

function bandit_testbed(
        ;explorer = EpsilonGreedyExplorer(0.1),
        true_reward = 0.0,
        init=0.,
        opt=InvDecay(1.0)
    )
    env = MultiArmBanditsEnv(;true_reward=true_reward)
    agent = Agent(
                  policy = QBasedPolicy(
                                        learner=MonteCarloLearner(
                                                                  approximator = TabularQApproximator(
                                                                                                      n_state=length(state_space(env)),
                                                                                                      n_action = length(action_space(env)),
                                                                                                      init = init,
                                                                                                      opt = opt
                                                                                                     ),
                                                                  γ = 1.0
                                                                 ),
                                        explorer = explorer
                                       ),
                  trajectory = VectorSARTTrajectory()
                 )
    h1 = CollectBestActions(;best_action = findmax(env.true_values)[2])
    h2 = TotalRewardPerEpisode(;is_display_on_exit=false)
    run(agent, env, StopAfterStep(1000), ComposedHook(h1, h2))
    h1.isbest, h2.rewards
end

for ϵ in [0.1, 0.01, 0.0]
    stats = [
             bandit_testbed(;explorer=EpsilonGreedyExplorer(ϵ))
             for _ in 1:2000
            ]
    println("ϵ:$(ϵ) -> $(mean(x[2] for x in stats))")
end
