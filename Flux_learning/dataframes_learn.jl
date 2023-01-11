# first we need to import the package menegement tool called Pkg, so we can
# activate the julia envioroment
using Pkg

# here we activate the envioroment with DataFrames by providing the 
# path to the envioroment 

Pkg.activate("/home/felipe/Julia_envs/Flux_env")

# now we can import the DataFrames package

using DataFrames, CSV

# lets create an empty dataframe

df = DataFrame(A=1:4, B=["M", "F", "F", "M"])

# Columns can be directly (i.e. without copying) extracted using df.col, df."col", df[!, :col] or df[!, "col"] (this rule applies to getting data from a data frame, not writing data to a data frame).

df.A

# we can also do

df."A"

# and this

df[!, :A]

df.A === df[!, :A]
df."A" === df.A

# Column names can be obtained as strings using the names function:

names(df)

# we can also filter columns names by passing a column selector condition
# as second argument 

names(df, r"A")

names(df, Int)

names(df, Not(:B))

# To get column names as Symbols use the propertynames function:

propertynames(df)

# Constructing Column by Column
# its also possible to start an empty DataFrame and add columns to it one by one

df = DataFrame()

df.A = 1:8

df[:, :B] = ["M","M","F","M","F","M","F", "P"]

df[:, :C] .= 0

# lets see the dataframe
df

#The dataframe we built this way has 8 rows and 3 columns, this can be 
# checked with the size function

size(df, 1)

size(df, 2)

size(df)

# In the above example notice that the df[!, :C] .= 0 expression created a new column in the data frame by broadcasting a scalar.

# When setting a column of a data frame the df[!, :C] and df.C syntaxes are equivalent and they would replace (or create) the :C column in df. This is different from using df[:, :C] to set a column in a data frame, which updates the contents of column in-place if it already exists.

# Here is an example showing this difference. Let us try changing the :B column to a binary variable.

df[:, :B] = df.B .== "F"

df[:, :B] .= df.B .== "F"

# The above operations did not work because when you use : as row selector the :B column is updated in-place, and it only supports storing strings.

# On the other hand the following works:

df.B = df.B .== "F"

df

# Constructing Row by Row

df = DataFrame(A=Int[], B=String[])

# Rows can then be added as tuples or vectors, where the order of elements matches that of columns. To add new rows at the end of a data frame use push!:

push!(df, (1, "M"))

push!(df, [2, "N"])

# Rows can also be added as Dicts, where the dictionary keys match the column names:

push!(df, Dict(:B => "F", :A => 3))

# Constructing from another table type

df = DataFrame(a=[1, 2, 3], b=[:a, :b, :c])

# write to CSV file
CSV.write("simple_dataframe.csv", df)



