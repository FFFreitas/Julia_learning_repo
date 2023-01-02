# Starting point example for converting data types in Learning Julia

# declare some basic data types
x = 10
y = 20.0
z = "40"
f = "30.0"

# TODO: Convert an integer to a character and vice versa
c = Char(74)
println(c)

i = Int('j')
println(i)


# TODO: convert between types
flt1 = Float32(x)
int1 = Int16(y)
println(flt1, ", ", int1)

# TODO: parse values from a string
a = parse(Int, z)
b = parse(Float64, f)
c = string(y)

println(a)
println(b)
println(c)

# TODO: attempting to convert a data type that won't fit is an error

x = Char(281)
println(x)

a = UInt8(x)
println(a)
