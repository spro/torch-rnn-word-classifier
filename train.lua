require 'nn'
require 'rnn'
require 'optim'
display = require 'display'
image = require 'image'

require 'helpers'
require 'data'

hidden_size = 100
n_chars = n_chars
n_classes = #classes

n_iter = 1
n_iters = 500
n_epoch = 1
n_epochs = 200
n_predictions = 100
log_every = 100
err = 0
errors = {}
predictions = {}

require 'model'

criterion = nn.ClassNLLCriterion() -- (torch.Tensor(class_weights))

function makeExample()
    local item = randomChoice(all_words)
    local class = item[1]
    local word = item[2]
    local inputs = makeWordInputs(word, n_chars)
    local target = torch.LongTensor({class})
    return inputs, target, last_word
end

-- Run a test input through the network
-- local test_input, test_target, test_word = makeExample()
-- print('test input, target, word:', test_input, test_target, test_word)
-- local test_output = model:forward(test_input)
-- print('test output:', test_output)
-- print('--------------------------------------------------------------------------------')

print("Begin training with " .. #all_words .. " words and " .. n_chars .. " chars...")

-- os.exit()

function predict(do_print)
    local inputs, target, word = makeExample()
    local outputs = model:forward(inputs)
    max_val, max_index = outputs:max(1)
    local predicted = max_index[1]
    local correct = predicted == target[1]
    if do_print then
        print('[prediction]', correct, classes[predicted], classes[target[1]], word)
    end
    return correct, outputs, target
end

parameters, gradients = model:getParameters()
feval = function(parameters_new)
    if parameters ~= parameters_new then
        parameters:copy(parameters_new)
    end

    model:forget()
    model:zeroGradParameters()

    local inputs, target = makeExample()
    local outputs = model:forward(inputs)
    local loss = criterion:forward(outputs, target)

    -- Backward sequence through rnn (through time)

    local gradOutputs = criterion:backward(outputs, target)
    local gradInputs = model:backward(inputs, gradOutputs)

    n_iter = n_iter + 1

    return loss, gradients
end

local optim_config = {
	learningRate = 0.001,
	learningRateDecay = 1e-7,
}
local optim_state = {}

function renderConfusion(conf)
    local w = conf.mat:size()[1]
    local p = 20

    local mat = conf.mat:clone():double()
    mat:mul(1 / mat:max())
    local im = image.scale(mat, w * p, 'simple')

    local im2 = torch.ones(3, w * p, w * p + 100):double()
    im2[{1, {}, {1, w * p}}] = im
    im2[{2, {}, {1, w * p}}] = im
    im2[{3, {}, {1, w * p}}] = im
    for oi = 1, #classes do
        im2 = image.drawText(im2, classes[oi], w * p + 5, p * (oi - 1) + 5)
    end
    return im2
end

n_total = 0

while n_epoch < n_epochs do
    n_iter = 0
    err = 0

    while n_iter < n_iters do
        n_total = n_total + 1

        local _, fs = optim.adam(feval, parameters, optim_config, optim_state)
        err = err + fs[1]

        -- Plot error

        if n_total % log_every == 0 then
            table.insert(errors, {n_total, err / log_every})
            display.plot(errors, {win='error', title='error'})
            err = 0
        end

    end

    -- Plot prediction %

    local n_correct = 0
    local conf = optim.ConfusionMatrix(classes)
    conf:zero()

    for pi = 1, n_predictions do
        local correct, output, target = predict()
        conf:add(output, target[1])

        if correct then
            n_correct = n_correct + 1
        end
    end

    local prediction_percent = n_correct / n_predictions
    table.insert(predictions, {n_epoch, prediction_percent})
    print("[epoch " .. n_epoch .. "] predicted", prediction_percent)
    display.plot(predictions, {win='prediction', title='prediction'})

    display.image(renderConfusion(conf), {win='conf', title='conf'})

    if n_epoch % 100 == 0 then
        print("Saving...")
        torch.save('model.t7', model)
    end

    n_epoch = n_epoch + 1
end

torch.save('model.t7', model)

for pi = 1, 50 do
    predict(true)
end
