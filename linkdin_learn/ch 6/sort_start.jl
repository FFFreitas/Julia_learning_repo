# Starting sorting example for Learning Julia

arr1 = [2, 8, -3, -15, 5, -7, 9, 0, 11]

# TODO sort the data by a simple transformation
#result = sort(arr1, by = abs)
#println(result)

# TODO check to see if an array is already sorted
arrtup = [(1, 2), (2, 1), (3, 5), (4, 0)]
#println(issorted(arrtup, by = x->x[1]))
#println(issorted(arrtup, by = x->x[2]))
# Sorting custom types
struct MyRect
    length::Int
    width::Int
end

arr2 = [MyRect(12, 22), MyRect(10, 18),MyRect(7, 12),MyRect(9, 30)]

# TODO declare a custom sorting function
function cpmparearea(rect1::MyRect, rect2::MyRect)
	area1 = rect1.length * rect1.width
	area2 = rect2.length * rect2.width
	return area1 < area2
end

sort!(arr2, lt = cpmparearea)
println(arr2)
