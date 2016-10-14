
function map(l, fn)
    local r = {}
    for i = 1, #l do
        table.insert(r, fn(l[i]))
    end
    return r
end

function randomChoice(list)
    return list[math.ceil(math.random() * #list)]
end

function randomSample(list, n)
    local sampled = {}
    for i = 1, n do
        local item = randomChoice(list)
        table.insert(sampled, item)
    end
    return sampled
end


