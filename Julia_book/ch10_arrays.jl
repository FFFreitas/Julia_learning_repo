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

a = "banana"
b = "banana"

@show a ≡ b

a = [1,2,3]
b = [1,2,3]

@show a ≡ b

# Aliasing

a = [1,2,3]
b = a

@show b ≡ a

# If the aliased object is mutable, changes made with one alias affect the other:
@show b[1] = 42
@show a

# For immutable objects like strings, aliasing is not as much of a problem. In this example:

a = "banana"
b = "banana"

# Array Arguments

function deletehead!(t)
    popfirst!(t)
end

letters = ['a', 'b', 'c']
t = letters
@show deletehead!(letters)
@show letters
@show t

t1 = [1, 2]
t2 = push!(t1, 3)
@show t1
@show t2

t3 = vcat(t1, [4])

@show t1
@show t3

# Exercises
# Exercise 10-1
# Write a function called nestedsum that takes an array of arrays of integers and adds up the elements from all of the nested arrays. For example:
#
t = [[1, 2], [3], [4, 5, 6]]


function nestedsum(t)
    flat = reduce(vcat, t)
    sum(flat)
end

@show nestedsum(t)

# Exercise 10-2
# Write a function called cumulsum that takes an array of numbers and returns the cumulative sum; that is, a new array where the ith element is the sum of the first i elements from the original array. For example:

function cumulsum(t)
    res = 0
    final = []
    for i in eachindex(t)
        res += t[i]
        push!(final, res)
    end
    final
end

t = [1, 2, 3]

cumulsum(t)

# Exercise 10-3
# Write a function called interior that takes an array and returns a new array that contains all but the first and last elements. For example:


function interior(t)
    tt = copy(t)
    deleteat!(tt, 1)
    pop!(tt)
    tt
end

t = [1, 2, 3, 4]
interior(t)


# Exercise 10-4
# Write a function called interior! that takes an array, modifies it by removing the first and last elements, and returns nothing .

t = [1, 2, 3, 4]

function interior!(t)
    deleteat!(t, 1)
    pop!(t)
end

interior!(t)
@show t

# Exercise 10-5
# Write a function called issort that takes an array as a parameter and returns true if the array is sorted in ascending order and false otherwise.

?sort

function issort(t)
    @show t == sort(t)
end

issort([1, 2, 2])
issort(['b', 'a'])

# Exercise 10-6
# Two words are anagrams if you can rearrange the letters from one to spell the other. Write a function called isanagram that takes two strings and returns true if they are anagrams.

function isanagram(t1, t2)
    @show sort(collect(t1)) == sort(collect(t2))
end

function isanagram_freq(t1, t2, size=256)
    a1 = zeros(size)
    b2 = zeros(size)
    for c1 in collect(t1)
        index = Int(codepoint(c1))
        a1[index] = 1.0
    end
    for c2 in collect(t2)
        index = Int(codepoint(c2))
        b2[index] = 1.0
    end

    if length(t1) != length(t2)
        return false
    end

    for i in 1:size
        if a1[i] != b2[i]
            return false
        end
    end
    return true
end

isanagram("listen", "silent")
isanagram_freq("ana", "banana")

# Exercise 10-7
# Write a function called hasduplicates that takes an array and returns true if there is any element that appears more than once. It should not modify the original array.
