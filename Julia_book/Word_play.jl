
fin  = open("./words.txt")

readline(fin)

readline(fin)

function hasno_e(word)
    if occursin('e', word)
        return true
    else
        return false
    end
end

for line in eachline("./words.txt")
    line = strip(line)
    if length(line) > 20
        println(line)
    end
end

for line in eachline("./words.txt")
    line = strip(line)
    if !hasno_e(line)
        println(line, " ")
    end
end
