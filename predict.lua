require 'nn'
require 'rnn'
require 'helpers'

model = torch.load('model.t7')
classes = torch.load('classes.t7')
all_chars = torch.load('all_chars.t7')
n_chars = all_chars.n_chars

function predict(word)
    model:forget()
    local char_vectors = {}
    local inputs = makeWordInputs(word, n_chars)
    local outputs = model:forward(inputs)
    max_val, max_index = outputs:max(1)
    local predicted = max_index[1]
    altered = -1 * math.log(max_val[1] * -1)
    print(word, classes[predicted] .. '   ', altered)
    local predictions = {}
    for pi = 1, outputs:size()[1] do
        predictions[pi] = {class=classes[pi], score=outputs[pi]}
    end
    return classes[predicted], predictions
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
