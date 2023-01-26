# Deep learning com Julia e Flux 
using Pkg

Pkg.activate("/home/felipe/Julia_envs/Flux_env/")

using Flux

# Arrays
# O ponto de partida de qualquer modelo de deep learning e o Array
# (tambem conhecido como tensor). Arrays sao apenas uma lista de numeros
# que algumas vezes pode ser organizada de maneiras e formatos diferentes

x = [1, 2, 3]

# O mesmo array, so que agora organizado como uma matriz

x = [1 2; 3 4]

# uma maneira mais esperta de se construir arrays e usar as funcoes apropriadas
# para tarefas repetitivas, ninguem vai criar uma matriz com 1000 linhas e colunas
# colocando valores individuais (assim espero)

x = rand(5, 3)

# por padrao Julia armazena numeros com a maior precisao possive, conveniente para 
# quem e cientista, pessimo pra quem tem computador com memoria limitada. Uma forma
# de contornar esse problema e definir o nivel de precisao que queremos usar 

x = rand(BigFloat, 5, 3)

Base.summarysize(x)/10^6

x = rand(Float32, 5, 3)

Base.summarysize(x)/10^6

# podemos saber o tamanho de um array

length(x)

# ou mais especificamente, suas dimensoes

size(x)

# e recuperar elementos especificos usando os indices do array, 
# uma vez que sabemos onde procurar

x[2, 3]

# ou tendo uma vaga ideia

x[:, 3]

# tambem podemos fazer operacoes aritimeticas com arrays

#soma
x + x

#subtracao

x - x

# Uma das coisas legais em julia e a operacao chamada de "broadcasting", onde usamos "." 
# antes de um operador para indicar o broadcasting

# somar o numero 1 em cada elemento da matriz

x .+ 1

# com broadcasting podemos fazer operacoes bastante complexas

zeros(5,5) .+ (1:5)

# ou ainda

zeros(5,5) .+ (1:5)'

# o ' intica que o array (1:5) sera transposto

collect((1:5))
collect((1:5)')

# podemos usar isso prar fazer o produto entre matrizes

(1:5) .* (1:5)'

# isso e bastante util para modelos de machine learning, onde podemos fazer

W = rand(5, 10)
x = rand(10)
W * x

# derivada automatica

f(x) = 3x^2 + 2x + 1

f(5)

# a derivada de f(x), como e um polinomio simples, e 6x + 2, podemos checar isso 
# com a funcao gradient do Flux

using Flux: gradient

df(x) = gradient(f, x)[1]

df(5)

# podemos ainda obter a segunda derivada (caso exista)

ddf(x) = gradient(df, x)[1]

ddf(5)

# a derivacao automatica em Flux e capaz de trabalhar com qualquer coisa que 
# colocar-mos em codigo, incluindo loops, condicionais e ate camadas customizadas
# de modo que esse codigo seja construido em como uma funcao

meuseno(x) = sum((-1)^k*x^(1+2k)/factorial(1+2k) for k in 0:5)

x = 0.5

meuseno(x)

gradient(meuseno, x)

sin(x), cos(x)

# isso se torna mais interessante quando consideramos funcoes que tem arrays como
# entradas, ao inves de um numero escalar simples, e.g

minhaloss(W, b, x) = sum(W * x .+ b)

W = rand(3, 5)
b = zeros(3)
x = rand(5)

gradient(minhaloss, W, b, x)

# o resultado da operacao acima fornece os valores de gradiente da funcao minhaloss
# em relacao as variaveis W, b e x, o que e bastante util quando a gent for treinar 
# o modelo de ML

# Uma vez que modelos de ML podem conter milhoes, ou ate bilhoes, de parametros
# uma maneira mais conveniente de se escrever o gradiente para esses modelos e 
# utilizar a funcao param, onde podemos "marcar" determinados arrays como sendo
# parametros da minha funcao e depois obter as derivadas de minha funcao em relacao
# aos parametros marcados

using Flux: params

W = rand(3, 5)
b = zeros(3)
x = rand(5)

y(x) = sum(W * x .+ b)

grads = gradient(()->y(x), params([W, b]))

grads[W]

grads[b]

# Podemos agora trabalhar com as chamada e comecar-mos a construir o nosso modelo
# de ML

m = Dense(10, 5)

# e usando a funcao params podemos marcar os 55 parametros de nosso modelo para
# obter a derivada mais tarde

params(m)

# bem mais conveniente

x = rand(Float32, 10)

# vamos criar um modelo simples, e ainda sim interessante

m = Chain(Dense(10, 5, relu), Dense(5, 2), softmax)

# aqui temos: 
# Primeira camada com 10 neuronios de entrada e 5 de saida, e uma relu com ativacao
# Segunda camada com 5 neuronios de entrada e 2 de saida, sem ativacao
# uma funcao softmax para determinar a probabilidade final

l(x) = Flux.Losses.crossentropy(m(x), [0.5, 0.5])

grads = gradient(params(m)) do
    l(x)
end

# checando os gradientes

for p ∈ params(m)
    println(grads[p])
end

# O proximo passo e atualizar o nosso modelo com novos parametros, uma vez que
# sabemos o gradiente e o quanto a predicao de nosso modelo esta "errada"
#

using Flux.Optimise: update!, Descent

η = 0.1
for p in params(m)
    update!(p, η * grads[p])
end

opt = Descent(0.01)

# Agora temos quase tudo pronto, so o que falta e o loop de treino onde vamos
# fornecer o conjunto de dados que o modelo vai "aprende"
#

data, labels = rand(10, 100), fill(0.5, 2, 100)

loss(x, y) = Flux.Losses.crossentropy(m(x), y)

Flux.train!(loss, params(m), [(data, labels)], opt)


# tambem pode ser assim
# for d in training_set # assuming d looks like (data, labels)
#     # our super logic
#     gs = gradient(params(m)) do #m is our model
#       l = loss(d...)
#     end
#     update!(opt, params(m), gs)
#   end




