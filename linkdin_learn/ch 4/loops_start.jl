# Starting point for loops example for Learning Julia

# TODO: basic for loop
#for i in 1:10
#	println(i)
#end

# TODO: can be any iterable, not just a range
#for i in ["Bingo","Bingo","Bingo"]
#	println(i)
#end

# TODO: Nested for loop
#for i in 1:3, j in 2:4
#	println(i, ',', j)
#end

# TODO: while loop
#i = 1
#while i <= 5
#	println(i)
#	global i += 1
#end

# TODO: Using enumeration within a loop
#teams = ("Giants", "Wizards", "Dragons", "Knights", "Kings")
#for (idx, val) in enumerate(teams)
 #       println(idx, " ,", val)
#end

#TODO: Loop control - breaking and continuing
for i in 1:10
	if i % 3 == 0
		continue
	elseif i > 7
		break
	end
	println(i)
end

