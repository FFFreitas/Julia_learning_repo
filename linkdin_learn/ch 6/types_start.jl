# Starting custom types example file for Learning Julia

# TODO Create a new custom type using the struct keyword
struct MyType
	field1::Int
	field2::String
end


# TODO instantiate the type
x = MyType(10, "ABC")
println(x)
println(x.field1, x.field2)

# TODO use "mutable" to make a type that can be altered
mutable struct MyTypeMutable
	field1::Int
	field2::String
end

x = MyTypeMutable(10, "ABC")
println(x)
x.field1 = 20
println(x)

# TODO use the isa() method to see if a variable is a given type

println(isa(x, MyTypeMutable))
