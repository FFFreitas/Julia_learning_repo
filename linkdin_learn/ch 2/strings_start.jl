# Starting example file for working with chars and strings in Julia

# TODO: Julia has a specific character type
mychar = 'x'
println(Int(mychar))
println(Char(420))

# Strings are defined using double quotes or triple quotes
mystr = "This is a sample string in Julia"
myotherstr = """
    Hello There
    This is a string
    """

# TODO: Get the length of a string
println(length(mystr))

# TODO: Access individual characters - note that they are 1-indexed
#println(mystr[1])
#println(mystr[end])
#println(mystr[end - 3])

# TODO: Slicing strings is used with the : notation
#println(mystr[2:end - 1])

# TODO: Iterate over characters
#for c in mystr
#	println(c)
#end

# TODO: String concatenation using *
w1 = "hello"
w2 = "world"
println(w1 * ", " * w2 * ".")

# TODO: String interpolation
a = 5
b = 10
println("The result of $a + $b is $(a + b)")

