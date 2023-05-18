using Printf

# Type declarations

(1 + 2) :: Float64
(1 + 2) :: Int64

function returnfloat()
    x::Float64 = 100
    x
end

x = returnfloat()

typeof(x)

function sinc(x)::Float64
    if x == 0
        return 1
    end
    sin(x)/(x)
end

mutable struct MyTime
    hour::Int64
    minute::Int64
    second::Int64
end

function printtime(time::MyTime)
    @printf("%02d:%02d:%02d", time.hour, time.minute, time.second)
end

# additional examples
function timetoint(time)
    minutes = time.hour * 60 + time.minute
    seconds = minutes * 60 + time.second
end

function inttotime(seconds)
    minutes, second = divrem(seconds, 60)
    hour, minute = divrem(minutes, 60)
    MyTime(hour, minute, second)
end


function increment(time::MyTime, seconds::Int64)
    seconds += timetoint(time)
    inttotime(seconds)
end

# constructors

function MyTime(time::MyTime)
    MyTime(time.hour, time.minute, time.second)
end


mutable struct MyTime
    hour::Int64
    minute::Int64
    second::Int64
    function MyTime(hour::Int64=0, minute::Int64=0, second::Int64=0)
        @assert(0 ≤ minute < 60, "Minutes must be between 0 and 60.")
        @assert(0 ≤ second < 60, "Secobds must be between 0 and 60.")
        new(hour, minute, second)
    end
end

mutable struct MyTime
    hour::Int64
    minute::Int64
    second::Int64
    function MyTime(hour::Int64=0, minute::Int64=0, second::Int64=0)
        @assert(0 ≤ minute < 60, "Minutes must be between 0 and 60.")
        @assert(0 ≤ second < 60, "Secobds must be between 0 and 60.")
        time = new()
        time.hour = hour
        time.minute = minute
        time.second = second
        time
    end
end
# Show me what you got

function Base.show(io::IO, time::MyTime)
    @printf(io, "%02d:%02d:%02d", time.hour, time.minute, time.second)
end

time = MyTime(1,20,00)
