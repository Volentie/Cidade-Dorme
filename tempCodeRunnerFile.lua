local t ={
    1,
    2,
    3,
    4
}

local copy = t[2]

t[2] = nil

print(copy, t[3])