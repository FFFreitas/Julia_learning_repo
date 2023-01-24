using Random
# Iteration

## Reasignment

x = 5
x = 7

a = 5
b = a
a = 3
a, b

# Updating variables

x = x + 1

y = y + 1

y = 0
y = y + 1

# The while statement

function countdown(n)
    while n > 0
        println(n, " ")
        n = n -1
    end
    println("Blastoff")
end

countdown(5)

function seq(n)
    while n != 1
        println(n)
        if n % 2 == 0
            n = n / 2
        else
            n = n * 3 + 1
        end
    end
end

seq(3)

while true
    println("> ")
    line = readline()
    if line == "done"
        break
    end
    println(line)
end
println("Done")


## continue

for i ∈ 1:10
    if i % 3 == 0
        continue
    end
    println(i, " ")
end

## Square roots

a = 4
x = 3
y = (x + a/x) / 2
x = y
y = (x + a/x) / 2
x = y
y = (x + a/x) / 2
x = y
y = (x + a/x) / 2
x = y
y = (x + a/x) / 2

## exercises

##7.2


function mysqrt(a, ϵ=1e-6)
    rng = MersenneTwister()
    sp = Random.Sampler(rng, 1:2*a)
    x = rand(rng, sp)
    while true
        y = (x + a/x) / 2
        if abs(y - x) < ϵ
            println(y)
            break
        end
        x = y
    end
end

mysqrt(64)



