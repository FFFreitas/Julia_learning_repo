# Starting string processing example for Learning Julia


# TODO: simple string operations - length, size
mystr = "Ångström"
teststr = "jμΛIα" # test string with some Greek characters
println("string lenght:", length(teststr))
println("string lenght:", sizeof(teststr))
println("string lenght:", length(mystr))
println("string lenght:", sizeof(mystr))
# TODO: concatenation and repetition operators

#teststr = "Hello " * "world"
#println(teststr)
#
#teststr = "ABCD" ^ 3
#println(teststr)

# TODO: search for substrings
teststr = "Julia programming is awesome"

#println(findnext("Julia", teststr, 0))
println(occursin("some", teststr))

# TODO: pad strings either left or right
testestr = lpad("Test string", 20)
println(testestr)

testestr = rpad("Test String", 20, '*')
println(testestr)

# TODO: create a string from an array
arr = ["Lions","Tigers","Bears"]

testestr = join(arr, ", ", " and ")
println(testestr)
