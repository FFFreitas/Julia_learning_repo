# Composite types

struct Point
    x
    y
end

p = Point(3.0, 4.0)

x = p.x

p.y

distance = sqrt(p.x^2 + p.y^2)

mutable struct MPoint
    x
    y
end

blank = MPoint(0.0, 0.0)

blank.x = 4.0
blank.y = 5.0

# Rectangles

struct Rectangle
    width
    height
    corner
end

origin = MPoint(0.0, 0.0)

box = Rectangle(100.0, 200.0, origin)

function printpoint(p)
    println("($(p.x), $(p.y))")
end

##
function distancebetweenpoints(p1, p2)
    return sqrt((p1.x - p2.x)^ 2 + (p1.y - p2.y)^2)
end

###

printpoint(blank)

function movepoint!(p, dx, dy)
    p.x += dx
    p.y += dy
    nothing
end

origin = MPoint(0.0, 0.0)

movepoint!(origin, 1.0, 2.0)

origin 
p
distancebetweenpoints(p, origin)

# Instances as returns values

function findcenter(rect)
    Point(rect.corner.x + rect.width/2, rect.corner.y + rect.height /2)
end

findcenter(box)


# Copying

p1 = MPoint(3.0, 4.0)

p2 = deepcopy(p1)

p1 ≡ p2

p1 == p2

# Ex

p3 = Point(3, 4)
p4 = deepcopy(p3)

p3 ≡ p4
p3 == p4


