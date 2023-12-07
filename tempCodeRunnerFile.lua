local a = {
    1, 3, 4, 5
}



for k, v in pairs(a) do
    if k == 2 then
        a[k] = nil
    end
    print(k, v)
end