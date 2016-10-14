require 'nn'
require 'rnn'
require 'optim'
display = require 'display'
image = require 'image'
require 'helpers'
require 'names'

rho = 10
embed_size = 50
hidden_size = 100
n_chars = n_chars
n_origins = #origins

n_iter = 1
n_iters = 500
n_epoch = 1
n_epochs = 500

errors = {}

n_predictions = 100
predictions = {}

require 'model'

local err = 0
local log_every = 100

criterion = nn.ClassNLLCriterion() -- (torch.Tensor(origin_weights))

function makeBatch()
    -- local inputs = {}
    -- local targets = {}
    -- for ii = 1, 10 do
    local item = randomChoice(all_names)
    local origin = item[1]
    local last_name = item[2]
    local input = {}
    for char in string.gfind(last_name, "([%z\1-\127\194-\244][\128-\191]*)") do
        table.insert(input, all_chars[char])
    end
    -- table.insert(inputs, input)
    -- table.insert(targets, origin)
    -- end
    -- print('inputs', inputs)
    -- print('targets', targets)
    local input = torch.LongTensor(input)--:view(-1, 1)
    local target = torch.LongTensor({origin})
    -- local targets = torch.LongTensor(1, input:size()[2]):fill(origin)
    return input, target, last_name
end

local test_input, test_target, test_name = makeBatch()
print('test input, target, name:', test_input, test_target, test_name)
local test_output = net:forward(test_input)
print('test output:', test_output)

print('--------------------------------------------------------------------------------')
print("Total of " .. #all_names .. " names and " .. n_chars .. " chars")

-- os.exit()

function predict(do_print)
    local inputs, target, name = makeBatch()
    local outputs = net:forward(inputs)
    max_val, max_index = outputs:max(1)
    local predicted = max_index[1]
    local correct = predicted == target[1]
    if do_print then
        print('[prediction]', correct, origins[predicted], origins[target[1]], name)
    end
    return correct, outputs, target
end

-- while n_iter < n_iters do
parameters, gradients = net:getParameters()
feval = function(parameters_new)
    if parameters ~= parameters_new then
        parameters:copy(parameters_new)
    end

    net:forget()
    net:zeroGradParameters()

    local inputs, target = makeBatch()
    local outputs = net:forward(inputs)
    local loss = criterion:forward(outputs, target)

    -- Backward sequence through rnn (through time)

    local gradOutputs = criterion:backward(outputs, target)
    local gradInputs = net:backward(inputs, gradOutputs)

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
    -- local im = torch.zeros(w * p, w * p)
    local mat = conf.mat:clone():double()
    mat:mul(1 / mat:max())
    local im = image.scale(mat, w * p, 'simple')

    local im2 = torch.ones(3, w * p, w * p + 100):double()
    im2[{1, {}, {1, w * p}}] = im
    im2[{2, {}, {1, w * p}}] = im
    im2[{3, {}, {1, w * p}}] = im
    for oi = 1, #origins do
        im2 = image.drawText(im2, origins[oi], w * p + 5, p * (oi - 1) + 5)
    end
    return im2
end

n_total = 0

while n_epoch < n_epochs do
    n_epoch = n_epoch + 1
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
    local conf = optim.ConfusionMatrix(origins)
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
    print("predicted", prediction_percent)
    display.plot(predictions, {win='prediction', title='prediction'})

    display.image(renderConfusion(conf), {win='conf', title='conf'})

    if n_epoch % 100 == 0 then
        print("Saving...")
        torch.save('net.t7', net)
    end
end

for pi = 1, 50 do
    predict(true)
end

torch.save('net.t7', net)

