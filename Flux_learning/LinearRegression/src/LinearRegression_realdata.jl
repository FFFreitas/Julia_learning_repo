using Pkg

Pkg.activate("/home/felipe/Julia_envs/Flux_env/")

using Flux, Statistics, MLDatasets, DataFrames

x, y = BostonHousing(as_df=false)[:];

size(x)

x_train, x_test, y_train, y_test = x[:, 1:400], x[:, 401:end], y[:, 1:400], y[:,401:end]

x_train |> size, y_train |> size, x_test |> size, y_test |> size

# as "features" desse dataset sao bem disperssas, e melhor normalizar elas:

std(x_train)

# vamos usar Flux.normalise para isso

x_train_n = Flux.normalise(x_train);

std(x_train_n)


# construindo o modelo

modelo = Dense(13 => 1)

# e a loss
#

function loss(modelo, x, y)
	y_pred = modelo(x)
	Flux.mse(y_pred, y)
end;

loss(modelo, x_train_n, y_train)

# agora a funcao que treina o modelo

function train_model()
	dLdm, _, _ = gradient(loss, modelo, x_train_n, y_train)
	@. modelo.weight = modelo.weight - 0.000001 * dLdm.weight
	@. modelo.bias = modelo.bias - 0.000001 * dLdm.bias
end;


loss_init = Inf; 

while true
	train_model()
	if loss_init == Inf
		loss_init = loss(modelo, x_train_n, y_train)
		continue
	end
	if abs(loss_init - loss(modelo, x_train_n, y_train)) < 1e-4
		break
	else
		loss_init = loss(modelo, x_train_n, y_train)
	end
end;

loss(modelo, x_train_n, y_train)

x_test_n = Flux.normalise(x_test)

loss(modelo, x_test_n, y_test)
