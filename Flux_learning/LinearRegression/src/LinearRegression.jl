using Pkg

Pkg.activate("/home/felipe/Julia_envs/Flux_env/")

using Flux, UnicodePlots

# primeiro vamos gerar os dados de entrada, dados aleatorios
# por enquanto
x = hcat(collect(Float32, -3:0.1:3)...)

# hcat cria uma matriz 1X61 com numeros aleatorios entre -3
# e 3. vamos agora gerar os alvos (y)
#

f(x) = @. 3x + 2;

y = f(x)

# A funcao f(x) cria um mapa entre as entradas x e o alvo
# y, o conjunto de pontos de entrada esta pronto, porem eles sao
# "perfeitos" demais, vamos adicionar um pouco de ruido

x = x .* reshape(rand(Float32, 61), (1, 61));

# vamos visualizar os pontos gerados
lineplot(vec(x), vec(y), title="Meus dados")

# ok, agora vamos construir o model

meu_modelo(W, b, x) = @. W*x + b

# o @. e uma macro que permite calculo de escalares em matrizes e vetores
# o proximo passo e iniciar o peso W de forma aleatoria

W = rand(Float32, 1, 1)

b = [0.0f0]

# podemos testar nosso modelo

meu_modelo(W, b, x) |> size

meu_modelo(W, b, x)[1], y[1]

# o valor previsto para 1 esta um pouco fora do esperado, uma vez que
# o modelo ainda nao "sabe" nada sobre a relacao entre x e y. Vamos
# criar uma funcao para estimar o quao errado o modelo e

function minha_loss(W, b, x, y)
	y_pred = meu_modelo(W, b, x)
	sum((y .- y_pred).^2) / length(x)
end;


minha_loss(W, b, x, y)

# definimos com sucesso o nosso modelo e loss. Entretanto, tudo isso foi feito
# sem usar Flux. Vamos ver como fazer o mesmo em Flux

flux_modelo = Dense(1 => 1)

# a funcao (camad?) Dense cria o modelo com um neoronio com dimensao de entrada
# 1 e saida 1, podemos checar os pesos e viezes desse modelo:

flux_modelo.weight

flux_modelo.bias

# vamos checar o modelo com flux olhando para as dimensoes de entrada e
# saida

flux_modelo(x) |> size

flux_modelo(x)[1], y[1]

# e agora a funcao loss para o modelo

function flux_loss(flux_modelo, x, y)
	y_pred = flux_modelo(x)
	Flux.mse(y_pred, y)
end;

flux_loss(flux_modelo, x, y)

# Otimo, tudo funcionando como antes!!! mas como o modelo com flux e diferente do meu?
# vamos fixar os parametros w e copiar em nosso modelo

W = Float32[-1.2505434]

minha_loss(W, b, x, y), flux_loss(flux_modelo, x, y)

# Vamor treinar o modelo

dLdW, dLdb, _, _ = gradient(minha_loss, W, b, x, y)

# e atualizando o modelo com os gradientes:

W .= W .- 0.1 .* dLdW

b .= b .- 0.1 .* dLdb

# checando a loss
minha_loss(W, b, x, y)

# Interessante, a loss era 47.69552f0 e agora 28.512438f0, o modelo melhorou!
# podemos repetir os passos anteriores mas isso e chato, vamos automatizar esse
# processo:

function treina_o_modelo()
	dLdW, dLdb, _, _ = gradient(minha_loss, W, b, x, y)
	@. W = W - 0.1 * dLdW
	@. b = b - 0.1 * dLdb
end;

treina_o_modelo()

W, b, minha_loss(W, b, x, y)

# cada vez que chamamos treina_o_modelo() o modelo e treinado por
# uma epoca, vamos treinar o modelo um pouco mais:

for i = 1:40
	treina_o_modelo()
end

W, b, minha_loss(W, b, x, y)

# Resultados

plt = scatterplot(vec(x), vec(y))

fm(x) = @. W * x + b;
lineplot!(plt, vec(x), vec(fm(x)))
