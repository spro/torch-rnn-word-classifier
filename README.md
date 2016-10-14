# rnn-word-classifier

Learns to classify words with a LSTM RNN, using Torch and ElementResearch's [rnn package](https://github.com/Element-Research/rnn).

This is a very simple one-layer LSTM network which reads each character in sequence, outputting the likelihood of each class (in my example, origins of a last name). Here's the entire model:

```lua
local lstm = nn.Sequential()
    :add(nn.FastLSTM(n_chars, hidden_size))

model = nn.Sequential()
    :add(nn.Sequencer(lstm))
    :add(nn.Select(1, -1)) -- Select the last output
    :add(nn.Linear(hidden_size, n_classes))
    :add(nn.LogSoftMax())
```

It generalizes well to stereotypical sounding words that don't exist in the training set:

```
$ th predict.lua Minski
Minski  Polish          3.1654921235668

$ th predict.lua "O'Flanger"
O'Flanger       Irish           1.8031927640596
```

## Training

Create a folder `data` with a text file for each class, where the name of each file is `[Class].txt`, e.g.:

```
data/
    Italian.txt
    Arabic.txt
```

Train the network with `th train.lua`. Use [display](https://github.com/szym/display) to watch training progress:

![](https://i.imgur.com/cR5FHBJ.png)

## Prediction

After every 100 epochs, the network will be saved as `model.t7` so you can make predictions with `th predict.lua`:

```
Nguyen  Vietnamese      2.1702328850916
Elbehri Italian         1.201187053048
Regeni  Italian         5.892642153394
Nahas   Arabic          5.9739377609982
Johnson Scottish        2.2350572387259
Assad   Arabic          5.1543209636233
Pierre  French          2.4321968760373
Picasso Italian         0.74093441832084
Oliver  Czech           -0.15565618004683
Olivier French          1.8174058021735
Gomez   Spanish         2.1184743665551
Putin   Russian         0.27808427539134
Xiang   Chinese         2.4248418092877
Satoshi Japanese        7.1128723492929
```

Or use `th predict.lua [word]` to predict a specific word:

```
$ th predict.lua "Kanamaki"
Kanamaki        Japanese        10.728770311279
```

