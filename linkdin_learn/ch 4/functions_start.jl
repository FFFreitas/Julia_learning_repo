# Starting functions example for Learning Julia

# TODO: Functions are defined with the function keyword and are usually
# lowercase names, optionally with underscores if they are hard to read
#function myfunc(a, b)
#	println("this is a function")
#	return a + b
#end
#
#result = myfunc(10, 15)
#println(result)

# TODO: function arguments can have default values
#function foo(a, b, z=10)
#	return (a + b) * z
#end
#
#println(foo(2, 3))
#println(foo(2, 3, 5))

# TODO: you can also use keyword arguments - define them after a semicolon
function bar(a, b; multiplier = 10)
	return (a + b) * multiplier
end
println(bar(4,5))
println(bar(multiplier = 5, 4, 5))

# TODO: The Julia shorthand way of defining a function 
#myfunc(x, y) = (a = x - 1; 2a+y)
#result = myfunc(3, 4)
#println(result)
# TODO: use the ... notation for variable arguments
function summit(args...)
    sum = 0
    # TODO: process each argument
    for a in args
	    sum += a
    end
    return sum
end
println(summit(1, 5, 10))
println(summit(2, 4, 6, 8))

