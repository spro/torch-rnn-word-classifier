require 'nn'
require 'rnn'
require 'helpers'

net = torch.load('net.t7')
origins = torch.load('origins.t7')
all_chars = torch.load('all_chars.t7')
n_chars = all_chars.n_chars

function predict(name)
    net:forget()
    local char_vectors = {}
    local inputs = makeNameInputs(name, n_chars)
    local outputs = net:forward(inputs)
    max_val, max_index = outputs:max(1)
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
