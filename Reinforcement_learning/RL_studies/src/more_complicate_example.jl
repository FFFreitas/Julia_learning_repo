using Pkg
Pkg.activate("../")
using InteractiveUtils
using ReinforcementLearning
using Flux: InvDecay

Base.@kwdef mutable struct LotteryEnv <: AbstractEnv
    reward::Union{Nothing, Int} = nothing
end

RLBase.action_space(env::LotteryEnv) = (:PowerRich, :MegaHaul, nothing)

RLBase.reward(env::LotteryEnv) = env.reward
RLBase.state(env::LotteryEnv) = !isnothing(env.reward)
RLBase.state_space(env::LotteryEnv) = [false, true]
RLBase.is_terminated(env::LotteryEnv) = !isnothing(env.reward)
RLBase.reset!(env::LotteryEnv) = env.reward = nothing

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

env = LotteryEnv()



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

RLBase.state(::Observation{String}, env::LotteryEnv) = is_terminated(env) ? "Game over" : "Game start"

"""
For environments which support many different kinds of states, developers should specify all the supported state styles. For example:
"""
tp = TigerProblemEnv()

StateStyle(tp)

state(tp, Observation{Int64}())

state(tp, InternalState{Int64}())

state(tp)

"""
DefaultStateStyle
The DefaultStateStyle trait returns the first element in the result of StateStyle by default.

For algorithm developers, they usually don't care about the state style. They can assume that the default state style is always well defined and simply call state(env) to get the right representation. So for environments of many different representations, state(env) will be dispatched to state(DefaultStateStyle(env), env). And we can use the DefaultStateStyleEnv wrapper to override the pre-defined DefaultStateStyle(::YourEnv).

RewardStyle
For games like Chess, Go or many card game, we only get the reward at the end of an game. We say this kind of games is of TerminalReward, otherwise we define it as StepReward. Actually the TerminalReward is a special case of StepReward (for non-terminal steps, the reward is 0). The reason we still want to distinguish these two cases is that, for some algorithms there may be a more efficient implementation for TerminalReward style games.
"""
RewardStyle(tp)

"""
ActionStyle
For some environments, the valid actions in each step may be different. We call this kind of environments are of FullActionSet. Otherwise, we say the environment is of MinimalActionSet. A typical built-in environment with FullActionSet is the TicTacToeEnv. Two extra methods must be implemented:
"""
ttt = TicTacToeEnv()

ActionStyle(ttt)

legal_action_space(ttt)

legal_action_space_mask(ttt)
