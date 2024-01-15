# The function Dict creates a new dictionary with no items. Because Dict is the name of a built-in function, you should avoid using it as a variable name.

eng2sp = Dict()

# add elements

eng2sp["One"] = "Uno"

@info eng2sp

@show eng2sp = Dict("one" => "uno", "two" => "dos", "three" => "tres")

@show eng2sp["two"]

@show eng2sp["four"]

@show length(eng2sp)

# get the keys

@show ks = keys(eng2sp)

@show "one" ∈ ks
@show "uno" ∈ ks

# and the values

@show vs = values(eng2sp)

function histogram(s::T) where T
    d = Dict()
    for c in s
        if c ∉ keys(d)
            d[c] = 1
        else
            d[c] += 1
        end
    end
    d
end

h = histogram("brontosaurus")


function histogram_get(s::T) where T
    d = Dict()
    for c in s
        d[c] = get(d, c, 0) + 1
    end
    d
end
histogram_get("brontosaurus")
