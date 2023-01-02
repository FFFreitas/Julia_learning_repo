# Starting example for built in functions in Learning Julia


# numeric functions
# TODO: round, floor, ceil, abs
#x = round(30.5)
#println(x)
#
#
#x = round(30.5, RoundUp)
#print(x)
#
#y = 29.95
#println(floor(y))
#println(ceil(y))
#
#z = -15
#println(abs(z))
# text i/o
# TODO: print, println
print("Hello ")
print("there")

# TODO: printstyled
#thestr = "This is some text"
#printstyled(thestr)
#println()
#printstyled(thestr, bold=true)
#println()
#printstyled(thestr, bold=true, color=:red)
# read standard input
# TODO: readline
#print("what is your name? ")
#str = readline()
#println(str)

# TODO: "is" functions
println(isascii("abc"))
println(isascii("αβγ"))

println(isdigit('9'))
println(isdigit('a'))

println(isspace(' '))
println(isspace('\r'))
println(isspace('\n'))
println(isspace('A'))
