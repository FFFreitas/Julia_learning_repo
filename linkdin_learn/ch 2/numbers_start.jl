# Starting example file for Julia number types

# TODO: Julia defines a set of specific sub-types for numbers
# Signed integers: Int, Int8, Int16, Int32, Int64, BigInt
a = Int16(1)
println(typeof(a))

b = Int(2000)
println(typeof(b))

# TODO: Unsigned integers: UInt, UInt8, UInt16, UInt32, UInt64


# TODO: typemax() and typemin() will provide max and min values
#println(typemax(Int8))
#println(typemax(Int32))
#println(typemax(Int64))
#println(typemin(Int64))
# TODO: Use the WORDSIZE property to see what type of system this is 
println(Sys.WORD_SIZE)

# TODO: trying to assign a number too large for the type
# will fail and give an error
# a = UInt8(300)

# TODO: special values represent Infinity and not-a-number
println(1.0 / 0.0)
println(1.0 / Inf)
println(0.0/ 0.0)

# TODO: zero() and one() functions produce values for a given type
println(zero(Float64))
println(one(UInt32))

