# Structs and functions
using Printf

struct MyTime
    hour
    minute
    second
end

time = MyTime(08, 19, 25)

# ex1


function printtime(time)
    println("$(@sprintf("%02d", time.hour)) : $(@sprintf("%02d", time.minute)) : $(@sprintf("%02d", time.second))")
end

printtime(time)

function isafter(t1, t2)
    c1 = (t1.hour < t2.hour) ? true : false
    c2 = (t1.hour == t2.hour) && (t1.minute < t2.minute)  ? true : false
    c3 = (t1.hour == t2.hour) && (t1.minute == t2.minute) && (t1.second < t2.second)  ? true : false

    c1 || c2 || c3
end


t1 = MyTime(12,01,01)
t2 = MyTime(10,01,02)

isafter(t1, t2)

function addtime(t1, t2)
    MyTime(t1.hour + t2.hour, t1.minute + t2.minute, t1.second + t2.second)
end

start = MyTime(9, 45, 0);

duration = MyTime(1, 35, 0);

done = addtime(start, duration)
printtime(done)

function addtime(t1, t2)
    second = t1.second + t2.second
    minute = t1.minute + t2.minute
    hour = t1.hour + t2.hour
    if second >= 60
        second -= 60
        minute += 1
    end
    if minute >= 60
        minute -= 60
        hour += 1
    end
    MyTime(hour, minute, second)
end

function increment!(time, seconds)
    time.second += seconds
    if time.second >= 60
        time.second -= 60
        time.minute += 1
    end
     if time.minute >= 60
        time.minute -= 60
        time.hour += 1
    end
end

#ex 16.3
function increment_noloop!(time, seconds)
    time.second += seconds
    time.second ≥ 60 ? time.second -= 60 : nothing
    time.second ≥ 60 ? time.minute += 1 : nothing
    time.minute ≥ 60 ? time.minute -= 60 : nothing
    time.minute ≥ 60 ? time.minute += 1 : nothing
end

 
########

function timetoint(time)
    minutes = time.hour * 60 + time.minute
    seconds = minutes * 60 + time.second
end

function inttotime(seconds)
    minutes, second = divrem(seconds, 60)
    hour, minute = divrem(minutes, 60)
    MyTime(hour, minute, second)
end

printtime(inttotime(3200))

function isvalidtime(time)
    if time.hour < 0 || time.minute < 0 || time.second < 0
        return false
    end
    if time.minute >= 60 || time.second >= 60
        return false
    end
    true
end
