require 'nn'
require 'rnn'

local lstm = nn.Sequential()
    :add(nn.FastLSTM(n_chars, opt.hidden_size))

model = nn.Sequential()
    :add(nn.Sequencer(lstm))
    :add(nn.Select(1, -1))
    :add(nn.Linear(opt.hidden_size, n_classes))
    :add(nn.LogSoftMax())

