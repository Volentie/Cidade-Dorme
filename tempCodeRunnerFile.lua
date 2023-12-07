local t = {
    "a",
    "b",
    "c",
    "d",
    "e",
    "f",
    "g",
    "h"
}

for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
end
print(table.concat(t, ", "))