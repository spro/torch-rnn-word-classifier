require 'nn'
require 'rnn'

rn = nn.Sequential()
    :add(nn.FastLSTM(n_chars, hidden_size))

net = nn.Sequential()
    :add(nn.Sequencer(rn))
    :add(nn.Select(1, -1))
    :add(nn.Linear(hidden_size, n_origins))
    :add(nn.LogSoftMax())

