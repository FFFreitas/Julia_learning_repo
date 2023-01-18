using Pkg

Pkg.activate("/home/felipe/Julia_envs/Flux_env/")

using Flux
using Random
using Statistics

function generate_process(phi::AbstractVector{Float32}, s::Int)
	s > 0 || error("s must be positive")
	#generate white noise
	eps = randn(Float32, s)
	# Initialize the TS
	X = zeros(Float32, s)
	p = length(phi)
	X[1] = eps[1]
	#reverse the order of the coefficients for mul latter
	phi = reverse(phi)
	# fill first p observations
	for t in 1:p-1
		X[t+1] = X[1:t]'phi[1:t] + eps[t+1]
	end
	# compute the values iteratively
	for t in p+1:s
		X[t] = X[t-p:t-1]'phi + eps[t]
	end
	X
end

function batch_timeseries(X, s::Int, r::Int)
	r > 0 || error("r must be positive")
	# if X is passed in format Tx1, reshape it
	if isa(X, AbstractVector)
		X = permutedims(X)
	end

	T = size(X, 2)
	s <= T || error("s cannot be longer than the total series")
	X = X[:, ((T - s) % r)+1:end]
	[X[:, t:r:end-s+t] for t in 1:s]
end

@Base.kwdef mutable struct Args
	seed::Int = 42
	phi::Vector{Float32} = [.3f0, .2f0, -5.f0]
	proclen::Int = 750
	dev = gpu
	opt = ADAM
	eta::Float64 = 2e-3
	hidden_nodes::Int = 64
	hidden_layers::Int = 2
	layer = LSTM
	epochs::Int = 100
	seqlen::Int = 10
	seqshift::Int = 10
	train_ratio::Float64 = 0.7
	verbose::Bool = true
end


function build_model(args)
	Chain(
	      args.layer(1, args.hidden_nodes),
	      [args.layer(args.hidden_nodes, args.hidden_nodes) for _ in 1:args.hidden_layers -1]...,
	      Dense(args.hidden_nodes, 1, identity)
	      ) |> args.dev
end

# creates the training and test TS

function generate_train_test_data(args)
	data = generate_process(args.phi, args.proclen)
	X, y = data[1:end-1], data[2:end]
	# split
	idx = round(Int, args.train_ratio * length(X))
	Xtrain, Xtest = X[1:idx], X[idx+1:end]
	ytrain, ytest = y[1:idx], y[idx+1:end]
	# transform to batches
	map(x -> batch_timeseries(x, args.seqlen, seqshift) |> args.dev,
	    (Xtrain, Xtest, ytrain, ytest))
end;

function mse_loss(model, x, y)
	model(x[1])
	mean(Flux.Losses.mse.([model(xi) for xi in x[2:end]], y[2:end]))
end;

# to train the model

function train_model(args)
	Random.seed!(args.seed)
	#build our model
	model = build_model(args)
	#get the data
	Xtrain, Xtest, ytrain, ytest = generate_train_test_data(args)

	opt = Flux.setup(args.opt(args.eta), model)

	# the training loop
	for i in 1:args.epochs
		Flux.reset!(model)
		(dLdm, ) = gradient(model) do m
			mse_loss(m, Xtrain, ytrain)
		end
		Flux.update!(opt, model, dLdm) # update the model params
		if args.verbose && i % 10 == 0
			Flux.reset!(model)
			train_loss = mse_loss(model, Xtrain, ytrain)
			Flux.reset!(model)
			test_loss = mse_loss(model, Xtest, ytest)
			@info "Epoch $i / $(args.epochs), train loss: $(round(train_loss, digits=3)) | test loss: $(round(test_loss, digits=3))"
		end
	end
	return model
end

args = Args()

m = train_model(args)
