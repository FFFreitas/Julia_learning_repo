# mesmo esquema de importar Pkg e ativar o ambient
using Pkg
Pkg.activate("/home/felipe/Julia_envs/Flux_env")
using DataFrames

# criando o dataframe

df = DataFrame(A=1:2:1000, B=repeat(1:10, inner=50), C=1:500)

# podemos checar as primeiras entradas com a funcao first

first(df, 6)

# ou a rabeta com a opcao last

last(df, 6)

# Julia DataFrames tambem fornece o tipo de dado de cada coluna
-1.0:5.0
DataFrame(a=1:4, b=-1.0:2, c=[false, true, true, false], d=repeat([missing], inner=4))

# pegando um subconjunto de dados
# Podemos selecionar regioes dentro do dataframe utilizando a notacao de inices

# aqui vamos pegar da primeira ate a terceira linha e todas as colunas
df[1:3,:]

# agora as linhas 1, 5 e 10 e todas as colunas
df[[1,5,10], :]

# todas as linhas e as colunas A e B
df[:, [:A, :B]]

# linhas de 1 a 3 e as colunas B e A
df[1:3, [:B, :A]]

# as linhas 3 e 1 com a coluna C
df[[3, 1], [:C]]

# repare que df[!, [:A]] e df[:, [:A]] retorna um dataframe, enquanto que
# df[!,:A] e df[:, :A] retornam vetores

typeof(df[!, [:A]])
typeof(df[!, :A])

# No primeiro caso [:A] e um vetor indicando que o objeto resultante da operacao
# deve ser um DataFrame. Por outro lado, :A e um simbolo, indicando que a coluna 
# chamada deve ser extraida para um vetor. Repare que para o primeiro caso e pre-
# ciso passar um vetor [nao qualquer iterador como uma tuple], e.g: df[:, (:x1, :x2)]
# nao e permitido, contudo df[:,[:x1, :x2]] e permitido
# Tambem e possivel utilizar regex para encontrar colunas

df = DataFrame(x1=1, x2=2, y=3)

df[!, r"x"]

# tambem operadores logicos
df[!, Not(:x1)]

# tambem pode-se usar Not, Beteween, Cols e All para se ter uma selecao de colunas 
# de maneira mais complexa
df = DataFrame(r=1, x1=2, x2=3, y=4)

# dropa a coluna r
df[:, Not(:r)]

# mantem as colunas entre r e x2
df[:,Between(:r, :x2)]

# Seleciona todas as colunas
df[:, All()]

# ou apenas as que eu quero especificamente
df[:, Cols(x -> startswith(x, "x"))]

# ou ainda as especificamente especificas com regex para colocar na ordem que 
# eu quero
# primeiro as colunas que comecam com x
df[:, Cols(r"x", :)]

# primeiro as colunas que comecam com r
df[:, Cols(Not(r"x"), :)]

# tambem podemos usar a mesma syntax para selecionar linhas
df = DataFrame(A=1:2:1000, B=repeat(1:10, inner=50), C=1:500)

# vamos selecionar as linhas que tem valores na coluna A maiores que 500
df[df.A .> 500, :]

# ou mais complicado
df[(df.A .> 500) .& (300 .< df.C .< 400), :]


