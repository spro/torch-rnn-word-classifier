require 'nn'
require 'rnn'
require 'optim'
display = require 'display'

require 'helpers'
require 'confusion'

-- Parse command line arguments

cmd = torch.CmdLine()
cmd:text()

cmd:option('-data_dir', 'data', 'Data directory, containing a text file per class')

cmd:option('-hidden_size', 200, 'Hidden size of LSTM layer')
cmd:option('-learning_rate', 0.001, 'Learning rate')
cmd:option('-learning_rate_decay', 1e-7, 'Learning rate decay')

opt = cmd:parse(arg)

require 'data'

-- Training parameters

n_classes = #classes
n_iters = 500
n_epochs = 200
n_predictions = 100
log_every = 100

-- State parameters (for plotting)
n_iters_total = 1
n_iter = 1
n_epoch = 1
err = 0
errors = {}
predictions = {}

require 'model' -- Require later because it expects a few global parameters

criterion = nn.ClassNLLCriterion()
parameters, gradients = model:getParameters()

-- Training-related functions 
--------------------------------------------------------------------------------

-- Select a random word from the training set and return inputs as a set of
-- one-hot character vectors (word length x n_chars) and a target class vector
function makeExample()
    local item = randomChoice(all_words)
    local class = item[1]
    local word = item[2]
    local inputs = makeWordInputs(word, n_chars)
    local target = torch.LongTensor({class})
    return inputs, target, last_word
end

-- Run a test input through the network
function runTest()
    local test_input, test_target, test_word = makeExample()
    print('[test] input, target, word:', test_input, test_target, test_word)
    local test_output = model:forward(test_input)
    print('[test] output:', test_output)
end
-- runTest()

-- Make a prediction and return correctness (boolean), outputs and target
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

-- Run an iteration of the optimization
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

-- Training
--------------------------------------------------------------------------------

print("Begin training with " .. #all_words .. " words and " .. n_chars .. " chars...")

local optim_config = {
	learningRate = opt.learning_rate,
	learningRateDecay = opt.learning_rate_decay,
}

local optim_state = {}

-- Run x n_epochs
while n_epoch < n_epochs do
    n_iter = 0
    err = 0

    -- Run x n_iters
    while n_iter < n_iters do
        n_iters_total = n_iters_total + 1

        -- Run the optimization
        local _, fs = optim.adam(feval, parameters, optim_config, optim_state)
        err = err + fs[1]

        -- Plot error every log_every
        if n_iters_total % log_every == 0 then
            table.insert(errors, {n_iters_total, err / log_every})
            display.plot(errors, {win='error', title='error'})
            err = 0
        end

    end

    -- Run n_predictions and build confusion matrix
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

    -- Plot prediction % and show confusion matrix
    local prediction_percent = n_correct / n_predictions
    table.insert(predictions, {n_epoch, prediction_percent})
    print("[epoch " .. n_epoch .. "] predicted", prediction_percent)
    display.plot(predictions, {win='prediction', title='prediction'})
    display.image(renderConfusion(conf), {win='conf', title='conf'})

    -- Save model every 100 epochs
    if n_epoch % 100 == 0 then
        print("Saving...")
        torch.save('model.t7', model)
    end

    n_epoch = n_epoch + 1
end

print("Saving...")
torch.save('model.t7', model)

-- Show some prediction results
for pi = 1, 50 do
    predict(true)
end

