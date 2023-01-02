# Declaring variables and using data types in Julia

# 5 basic types of data:
# Integers, Floating point numbers, booleans, strings, and characters

# Variable names typically are lowercase. Use underscores if the name
# is too long to be easily read.
first = 1
second = 2.0
stringvar = "This is a string"
initial = 'J'
boolval = true

println(first)
println(second)
println(stringvar)
println(initial)
println(boolval)

# TODO: variables can be redefined and change type
first = 1.0
println(first)

# TODO: Strings have to be in double quotes. This will error:
# anotherstring = 'hello world'

# TODO: Constant values are declared with const and are all uppercase
# Note: this is only useful in the global scope
#const MEANING_OF_LIFE = 42
#MEANING_OF_LIFE = 43

# TODO: Constants of the same type *can* be reassigned, but with a warning
# MEANING_OF_LIFE = 42.0

# TODO: Constants of different types cannot be reassigned, this is an error
function testfunc()
	x:: String = "some text"
	x = 10
end

testfunc()

# Type Annotation identifies a variable as a particular type
