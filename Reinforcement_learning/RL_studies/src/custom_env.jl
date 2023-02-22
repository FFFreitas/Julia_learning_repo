using Pkg
Pkg.activate("../")
using ReinforcementLearning
using Flux: InvDecay


"""
The game is defined like this: assume you have $10 in your pocket, and you are faced with the following three choices:

Buy a PowerRich lottery ticket (win $100M w.p. 0.01; nothing otherwise);
Buy a MegaHaul lottery ticket (win $1M w.p. 0.05; nothing otherwise);
Do not buy a lottery ticket.

This game is a one-shot game. It terminates immediately after taking an action and a reward is received. First we define a concrete subtype of AbstractEnv named LotteryEnv:
"""

Base.@kwdef mutable struct LotteryEnv <: AbstractEnv
    reward::Union{Nothing, Int} = nothing
end

"""
The LotteryEnv has only one field named reward, by default it is initialized with nothing. Now let's implement the necessary interfaces:
"""
RLBase.action_space(env::LotteryEnv) = (:PowerRich, :MegaHaul, nothing)

"""
Here RLBase is just an alias for ReinforcementLearningBase.
"""
RLBase.reward(env::LotteryEnv) = env.reward
RLBase.state(env::LotteryEnv) = !isnothing(env.reward)
RLBase.state_space(env::LotteryEnv) = [false, true]
RLBase.is_terminated(env::LotteryEnv) = !isnothing(env.reward)
RLBase.reset!(env::LotteryEnv) = env.reward = nothing

"""
Because the lottery game is just a simple one-shot game. If the reward is nothing then the game is not started yet and we say the game is in state false, otherwise the game is terminated and the state is true. So the result of state_space(env) describes the possible states of this environment. By reset! the game, we simply assign the reward with nothing, meaning that it's in the initial state again.

The only left one is to implement the game logic:
"""
function (x::LotteryEnv)(action)
    if action == :PowerRich
        x.reward = rand() < 0.01 ? 100_000_000 : -10
    elseif action == :MegaHaul
        x.reward = rand() < 0.05 ? 1_000_000 : -10
    elseif isnothing(action) 
        x.reward = 0
    else
        @error "unknow action of $action"
    end
end

"""
Test Your Environment

A method named RLBase.test_runnable! is provided to rollout several simulations and see whether the environment we defined is functional.
"""

env = LotteryEnv()

RLBase.test_runnable!(env)

"""
One step further is to test that other components in ReinforcementLearning.jl also work. Similar to the test above, let's try the RandomPolicy first:
"""
run(RandomPolicy(action_space(env)), env, StopAfterEpisode(1_000))

"""
If no error shows up, then it means our environment at least works with the RandomPolicy 🎉🎉🎉. Next, we can add a hook to collect the reward in each episode to see the performance of the RandomPolicy.
"""
hook = TotalRewardPerEpisode()


run(RandomPolicy(action_space(env)), env, StopAfterEpisode(1_000), hook)

"""
Add an Environment Wrapper
Now suppose we'd like to use a tabular based monte carlo method to estimate the state-action value.
"""
p = QBasedPolicy(
    learner = MonteCarloLearner(;
        approximator = TabularQApproximator(
                                            ;n_state = length(state_space(env)),
                                            n_action = length(action_space(env)),
                                            opt = InvDecay(1.0)
                                            )
                                ),
        explorer = EpsilonGreedyExplorer(0.1)
                )
p(env)

"""
QBasedPolicy contains two parts: a learner and an explorer. The learner learn the state-action value function (aka Q function) during interactions with the env. The explorer is used to select an action based on the Q value returned by the learner. Inside of the MonteCarloLearner, a TabularQApproximator is used to estimate the Q value.

That's the problem! A TabularQApproximator only accepts states of type Int.
"""
p.learner.approximator(1, 1)

p.learner.approximator(1)

p.learner.approximator(false)

"""
An initial idea is to rewrite the RLBase.state(env::LotteryEnv) function to force it return an Int. That's workable. But in some cases, we may be using environments written by others and it's not very easy to modify the code directly. Fortunatelly, some environment wrappers are provided to help us transform the environment.
"""
wrapped_env = ActionTransformedEnv(
                                   StateTransformedEnv(
                                                       env;
                                                       state_mapping = s -> s ? 1 : 2,
                                                       state_space_mapping = _ -> Base.OneTo(2)
                                                      );
                                   action_mapping = i -> action_space(env)[i],
                                   action_space_mapping = _ -> Base.OneTo(3),
                                  )

p(wrapped_env)

h = TotalRewardPerEpisode()

run(p, wrapped_env, StopAfterEpisode(1_000), h)
