# arrays

a = [10, 20, 30, 40]

println(eltype(a))
println(typeof(a))

b = ["crunchy frog", "ram bladder", "lark vomit"]

println(eltype(b))
println(typeof(b))

# The elements of an array don’t have to be the same type

c = ["spam", 2.0, 5, [10, 20]]

println(eltype(c))
println(typeof(c))

# Arrays Are Mutable

cheeses = ["Cheddar", "Edam", "Gouda"];
numbers = [42, 123]
empty = []

print(cheeses, " ", numbers, " ", empty)

numbers[2] = 5

println(numbers)

# Any integer expression can be used as an index.
# If you try to read or write an element that does not exist, you get a BoundsError .
# The keyword end points to the last index of the array.

# The ∈ operator also works on arrays:

@show "Edam" ∈ cheeses

@show "Brie" ∈ cheeses

# Traversing an Array

for cheese in cheeses
    println(cheese)
end

for i in eachindex(numbers)
    numbers[i] = numbers[i]*2
    println(i, " ", numbers[1])
end

nested = ["spam", 1, ["Brie", "Roquefort", "Camembert"], [1, 2, 3]]
@show collect(eachindex(nested))

# Array Slices

t = ['a', 'b', 'c', 'd', 'e', 'f']
@show t[1:3]
@show t[:]

@show t[2:3] = ['x', 'y']
@show t[:]

# Array Library

t = ['a', 'b', 'c']
push!(t, 'd')

# append! add the elements of the second array to the end of the first
t1 = ['a', 'b', 'c']
t2 = ['d', 'e']
append!(t1, t2)
@show t1

# sort! arranges the elements of the array from low to high

t = ['d', 'c', 'e', 'b', 'a']
sort!(t)
@show t

# sort returns a copy of the elements of the array in order

t = ['d', 'c', 'e', 'b', 'a']
t2 = sort(t)
@show t
@show t2

# Map, Filter and Reduce

function addall(t)
    total = 0
    for x in t
        total += x
    end
    total
end

# An operation like this that combines a sequence of elements into a single value is sometimes called a reduce operation.

t = [1, 2,3 ,4]

@show addall(t)

@show sum(t)

function acpitalizeall(t)
    res = []
    for s in t
        push!(res, uppercase(s))
    end
    res
end

# An operation like capitalizeall is sometimes called a map because it “maps” a function (in this case uppercase ) onto each of the elements in a sequence.

function onlyupper(t)
    res = []
    for s in t
        if s == uppercase(s)
            push!(res, s)
        end
    end
    res
end

# An operation like onlyupper is called a filter because it selects some of the elements and filters out the others.


# Dot Syntax

@show [1, 2, 3, 4] .^ 3

# Any Julia function f can be applied elementwise to any array with the dot syntax.

@show t = uppercase.(["abc", "dfg", "hij"])

function capitalizeall(t)
    uppercase.(t)
end

# Deleting (Inserting) Elements

t = ['a', 'b', 'c']

@show splice!(t, 2)
@show t

# splice! modifies the array and returns the element that was removed.
# pop! deletes and returns the last element:

t = ['a', 'b', 'c']
@show pop!(t)
@show t

# popfirst! deletes and returns the first element:

t = ['a', 'b', 'c']
@show popfirst!(t)
@show t

# The functions pushfirst! and push! insert an element at the beginning, respectively at the end of the array.

t = ['a', 'b', 'c']
@show pushfirst!(t, 'z')
@show push!(t, 'Z')
@show t

# If you don’t need the removed value, you can use the function deleteat! 

t = ['a', 'b', 'c']
@show deleteat!(t, 2)
@show t

# The function insert! inserts an element at a given index

t = ['a', 'b', 'c']
@show insert!(t, 2, 'x')
@show t

# Arrays and Strings

t = collect("spam")
@show t

# The collect function breaks a string or another sequence into individual elements.
# If you want to break a string into words, you can use the split function

t = split("pining for the fjords")
@show t

# An optional argument called a delimiter specifies which characters to use as word boundaries.

t = split("spam-spam-spam", '-')
@show t

# join is the inverse of split . It takes an array of strings and concatenates the elements

t = ["pining", "for", "the", "fjords"]
s = join(t, ' ')
@show s

# Objects and Values

