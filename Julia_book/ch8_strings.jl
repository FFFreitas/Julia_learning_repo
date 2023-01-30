# Strings

'x'

' '

'\t'

typeof('x')

'🍌'

## Strings are just sequences of characters

fruit = "banana"

letter = fruit[1]

fruit[end]

i = 1
fruit[i + 1]

## Lenght

fruits = "    🍎    "
len = length(fruits)

last = fruits[len]

## size

sizeof("    ")

nextind(fruits, 3)
fruits[4]


## Traversal

index = firstindex(fruits)
while index <= sizeof(fruits)
    letter = fruits[index]
    println(letter)
    global index = nextind(fruits, index)
end

## exercise

function RevStr(str::String)
    str = reverse(str)
    str = [x for x in str if !isspace(x)]
    for l in str
        println(l, " ")
    end
end

RevStr("This is a test")


## String slices

str = "Julius Cesar";

str[1:6]

str[8:end]

## IMMutability

greetings = "Hello world"

greetings[1] = 'J'

greetings = "J" * greetings[2:end]

## Interpolation
#
greet = "Hello"
whom = "World"

"$greet, $(whom)!"

## Searching

function find(word, letter, startfrom)
    if startfrom <= sizeof(word)
        index = startfrom
    else
        index = firstindex(word)
    while index <= sizeof(word)
        if word[index] == letter
            return index
        end
        index = nextind(word, index)
    end
    -1
end

## String lib

uppercase(greetings)

findfirst("a", "banana")

findnext("na", "banana", 4)

# The operator ∈

'a' ∈ "banana"

function inboth(word1, word2)
    for letter ∈ word1
        if letter ∈ word2
            println(letter, " ")
        end
    end
end

inboth("banana", "castanha")


# String comparison

word = "Pineable"
if word == "banana"
    println("Alright, bananas")
end

if word < "banana"
    println("Your word, $word, comes before banana")
elseif word > "banana"
    println("Your word, $word, comes after banana")
else
    println("Ok")
end 
