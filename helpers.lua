
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

function unicodeChars(str)
    return string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)")
end

function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

function makeWordInputs(word, n_chars)
    word = trim(word)
    local char_vectors = {}
    for char in unicodeChars(word) do
        local char_vector = torch.zeros(n_chars)
        char_vector[all_chars[char]] = 1
        table.insert(char_vectors, char_vector)
    end
    local inputs = torch.zeros(#char_vectors, n_chars)
    for ci = 1, #char_vectors do
        inputs[ci] = char_vectors[ci]
    end
    return inputs
end
