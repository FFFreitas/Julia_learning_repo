# When defining a function, one can optionally constrain the types of parameters it is applicable to, using the :: type-assertion operator:

f(x::Float64, y::Float64) = 2x + y

f(2.0, 3.0)

# Applying it to any other types of arguments will result in a MethodError:

f(2.0, 3)

f(Float32(2.0), 3.0)

f(2.0, "3.0")

# As you can see, the arguments must be precisely of type Float64. Other numeric types, such as integers or 32-bit floating-point values, are not automatically converted to 64-bit floating-point, nor are strings parsed as numbers.

# Because Float64 is a concrete type and concrete types cannot be subclassed in Julia, such a definition can only be applied to arguments that are exactly of type Float64. It may often be useful, however, to write more general methods where the declared parameter types are abstract:

f(x::Number, y::Number) = 2x - y

f(2.0, 3) # general case
f(2.0, 3.0) # f64 f64 case


# For non-numeric values, and for fewer or more than two arguments, the function f remains undefined, and applying it will still result in a MethodError:

f("foo", 3)

methods(f)

# In the absence of a type declaration with ::, the type of a method parameter is Any by default, meaning that it is unconstrained since all values in Julia are instances of the abstract type Any. Thus, we can define a catch-all method for f like so:

f(x,y) = println("Whoops doops.")

methods(f)

f("foo", 3)

methods(+)

## Methdo Ambiguit
# It is possible to define a set of function methods such that there is no unique most specific method applicable to some combinations of arguments:

g(x::Float64, y) = 2x + y

g(x, y::Float64) = x + 2y

g(2.0, 3)

g(2, 3.0)

g(2.0, 3.0)

# You can avoid method ambiguities by specifying an appropriate method for the intersection case:

g(x::Float64, y::Float64) = 2x + 2y

g(2.0, 3)

g(2, 3.0)

g(2.0, 3.0)


## Parametric methods
# Method definitions can optionally have type parameters qualifying the signature:

same_type(x::T, y::T) where {T} = true

same_type(x, y) = false

# The first method applies whenever both arguments are of the same concrete type, regardless of what type that is, while the second method acts as a catch-all, covering all other cases. Thus, overall, this defines a boolean function that checks whether its two arguments are of the same type:

same_type(1, 2)

same_type(1,2.0)

# This kind of definition of function behavior by dispatch is quite common – idiomatic, even – in Julia. Method type parameters are not restricted to being used as the types of arguments: they can be used anywhere a value would be in the signature of the function or body of the function. Here's an example where the method type parameter T is used as the type parameter to the parametric type Vector{T} in the method signature:

myappend(v::Vector{T}, x::T) where {T} = [v..., x]

myappend([1,2,3], 4)

myappend([1,2,3], 4.0)

myappend([1.0,2.0,3.0], 4.0)

myappend([1.0,2.0,3.0], 4)

# as one can see, the type of the myappend function must be all equal, otherwise it will raise a MethodError, the next example the type T is a return value

mytypeof(x::T) where {T} = T

mytypeof(1)
mytypeof(1.0)

same_type_numeric(x::T, y::T) where {T<:Number} = true

same_type_numeric(x::Number, y::Number) = false

same_type_numeric(1, 2)

same_type_numeric(1, 2.0)

same_type_numeric("foo", 2)

## Redefining Methods
#
#When redefining a method or adding new methods, it is important to realize that these changes don't take effect immediately. This is key to Julia's ability to statically infer and compile code to run fast, without the usual JIT tricks and overhead. Indeed, any new method definition won't be visible to the current runtime environment, including Tasks and Threads (and any previously defined @generated functions). Let's start with an example to see what this means:

function tryeval()
	@eval newfun() = 1
	newfun()
end

tryeval()

newfun()

# Sometimes it is necessary to get around this (for example, if you are implementing the above REPL). Fortunately, there is an easy solution: call the function using Base.invokelatest:

function tryeval2()
	@eval newfun2() =2
	Base.invokelatest(newfun2)
end

tryeval2()

# Finally, let's take a look at some more complex examples where this rule comes into play. Define a function f(x), which initially has one method:

f(x) = "Original definition"

# Start some other operation that uses f(x)

g(x) = f(x)

t = @async f(wait()); yield();

# now we add some new methods to f(x)

f(x::Int) = "definition for Int"

f(x::Type{Int}) = "definition for Type{Int}"

# Compare how these differ

f(1)

g(1)

fetch(schedule(t, 1))

t = @async f(wait()); yield();

fetch(schedule(t, 1))

## Design Patterns with Parametric Methods
# While complex dispatch logic is not required for performance or usability, sometimes it can be the best way to express some algorithm. Here are a few common design patterns that come up sometimes when using dispatch in this way.

# Extracting the type parameter from a super-type
# Here is a correct code template for returning the element-type T of any arbitrary subtype of AbstractArray that has well-defined element type:

abstract type AbstractArray{T, N} end
eltype(::Type{<:AbstractArray{T}}) where {T} = T

# One common mistake is to try and get the element-type by using introspection:

eltype_wrong(::Type{A}) where {A<:AbstractArray} = A.parameters[1]

# However, it is not hard to construct cases where this will fail:

struct BitVector <: AbstractArray{Bool, 1}; end

# Another mistake is to try to walk up the type hierarchy using supertype:

eltype_wrong(::Type{AbstractArray{T}}) where {T} = T
eltype_wrong(::Type{AbstractArray{T, N}}) where {T, N} = T
eltype_wrong(::Type{A}) where {A<:AbstractArray} = eltype_wrong(supertype(A))

eltype_wrong(Union{AbstractArray{Int}, AbstractArray{Float64}})

# Building a similar type with a different type parameter

copy_with_eltype(input, Eltype) = copyto!(similar(input, Eltype), input)

# Iterated dispatch
#=
In order to dispatch a multi-level parametric argument list, often it is best to separate each level of dispatch into distinct functions. This may sound similar in approach to single-dispatch, but as we shall see below, it is still more flexible.

For example, trying to dispatch on the element-type of an array will often run into ambiguous situations. Instead, commonly code will dispatch first on the container type, then recurse down to a more specific method based on eltype. In most cases, the algorithms lend themselves conveniently to this hierarchical approach, while in other cases, this rigor must be resolved manually. This dispatching branching can be observed, for example, in the logic to sum two matrices:
=#

# First dispatch selects the map algorithm for element-wise summation.
+(a::Matrix, b::Matrix) = map(+, a, b)
# Then dispatch handles each element and selects the appropriate
# common element type for the computation.
+(a, b) = +(promote(a, b)...)
# Once the elements have the same type, they can be added.
# For example, via primitive operations exposed by the processor.
+(a::Float64, b::Float64) = Core.add(a, b)


# Output-type computation
#

function matmul(a::AbstractMatrix, b::AbstractMatrix)
	op = (ai, bi) -> ai * bi + ai + bi

	R = promote_op(op, eltype(a), eltype(b))

	output = similar(b, R, (size(a, 1), size(b, 2)))
	if size(a, 2) > 0
		for j in 1:size(b, 2)
			for i in 1:size(a, 1)
				ab::R = a[i, 1] * b[1, j]
				for k in 2:size(a, 2)
					ab += a[i, k] * b[k, j]
				end
				output[i, j] = ab
			end
		end
	end
	return output
end


# Parametrically-constrained Varargs methods

# Function parameters can also be used to constrain the number of arguments that may be supplied to a "varargs" function (Varargs Functions). The notation Vararg{T,N} is used to indicate such a constraint. For example:

bar(a,b,x::Vararg{Any, 2}) = (a,b,x)

bar(1,2,3)

bar(1,2,3,4)

# More usefully, it is possible to constrain varargs methods by a parameter. For example:

# function getindex(A::AbstractArray{T, N}, indices::Vararg{Number, N}) where {T,N} end

# Function-like objects
# Methods are associated with types, so it is possible to make any arbitrary Julia object "callable" by adding methods to its type. (Such "callable" objects are sometimes called "functors.")

# For example, you can define a type that stores the coefficients of a polynomial, but behaves like a function evaluating the polynomial:

struct Polynomial{R}
	coeffs::Vector{R}
end

function (p::Polynomial)(x)
	v = p.coeffs[end]
	for i = (length(p.coeffs) - 1):-1:1
		v = v*x + p.coeffs[i]
	end
	return v
end

(p::Polynomial)() = p(5)

p = Polynomial([1,10,100])

p(3)

p()

# Empty generic functions

function emptyfunc end

emptyfunc

# Tuple and NTuple arguments

f(x::NTuple{N, Int}) where {N} = 1
f(x::NTuple{N, Float64}) where {N} = 2

# are ambiguous because of the possibility that N == 0: there are no elements to determine whether the Int or Float64 variant should be called. To resolve the ambiguity, one approach is define a method for the empty tuple:

f(x::Tuple{}) = 3

# Alternatively, for all methods but one you can insist that there is at least one element in the tuple:
f(x::NTuple{N, Int}) where {N} = 1
f(x::Tuple{Float64, Vararg{Float64}}) = 2
