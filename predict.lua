require 'nn'
require 'rnn'

function trim(s)
    return s:gsub("^%s+", ""):gsub("%s+$", "")
end

net = torch.load('net.t7')
origins = torch.load('origins.t7')
all_chars = torch.load('all_chars.t7')

function predict(name)
    name = trim(name)

    net:forget()

    local inputs = {}
    for char in string.gfind(name, "([%z\1-\127\194-\244][\128-\191]*)") do
        table.insert(inputs, all_chars[char])
    end
    local inputs = torch.LongTensor(inputs)--:view(-1, 1)
    -- print('[predict]', name)
    local outputs = net:forward(inputs)
    -- print('outputs', outputs, outputs:max(2))
    max_val, max_index = outputs:max(1)
    -- print('max_index', max_index[1][1])
    local predicted = max_index[1]
    altered = -1 * math.log(max_val[1] * -1)
    print(name, origins[predicted] .. '   ', altered)
    local predictions = {}
    for pi = 1, outputs:size()[1] do
        predictions[pi] = {origin=origins[pi], score=outputs[pi]}
    end
    return origins[predicted], predictions
end

if arg[1] then
    predict(arg[1])
else
    predict("Nguyen")
    predict("Elbehri")
    predict("Regeni")
    predict("Nahas")
    predict("Johnson")
    predict("Assad")
    predict("Pierre")
    predict("Picasso")
    predict("Oliver")
    predict("Olivier")
    predict("Gomez")
    predict("Putin")
    predict("Xiang")
    predict("Satoshi")
end
