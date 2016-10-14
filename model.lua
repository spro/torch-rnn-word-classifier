require 'nn'
require 'rnn'

rn = nn.Sequential()
    :add(nn.FastLSTM(embed_size, hidden_size))

net = nn.Sequential()
    :add(nn.LookupTable(n_chars, embed_size))
    :add(nn.Sequencer(rn))
    :add(nn.Select(1, -1))
    :add(nn.Linear(hidden_size, n_origins))
    :add(nn.LogSoftMax())

