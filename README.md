# torch-rnn-word-classifier

Learns to classify words with a LSTM RNN, using Torch and ElementResearch's [rnn package](https://github.com/Element-Research/rnn).

This is a simple network which takes as input each character in sequence, and outputs the likelihood of each class. Here's the entire model:

```lua
local lstm = nn.Sequential()
    :add(nn.FastLSTM(n_chars, hidden_size))

model = nn.Sequential()
    :add(nn.Sequencer(lstm))
    :add(nn.Select(1, -1)) -- Select the last output
    :add(nn.Linear(hidden_size, n_classes))
    :add(nn.LogSoftMax())
```

It generalizes well to stereotypical sounding (but fake) words that don't exist in the training set:

```
$ th predict.lua Minski
Minski  Polish          -0.056591876014212

$ th predict.lua "O'Flay"
O'Flay  Irish           -2.9700686354772e-12

$ th predict.lua Kagos
Kagos   Greek           -0.051732114586811
```

## Training

Create a folder `data` with a text file for each class, where the name of each file is `[Class].txt`, e.g.:

```
data/
    Arabic.txt
    Italian.txt
    Polish.txt
    ...
```

Train the network with `th train.lua`. Use [display](https://github.com/szym/display) to watch training progress:

![](https://i.imgur.com/9K00huH.png)

Configure training with these options:

```
-data_dir            Data directory [data]
-hidden_size         Hidden LSTM size [200]
-learning_rate       Learning rate [0.001]
-learning_rate_decay Learning rate decay [1e-07]
```

## Prediction

Every 100 epochs, the network is saved as `model.t7`. As soon as one is saved you can make predictions with `th predict.lua`. Here's an example after 200 epochs &times; 500 iterations with `-hidden_size 200` (around 15.301 minutes on a recent MacBook Pro CPU):

```
Nguyen  Vietnamese      -0.017714772153594
Elbehri German          -1.0591273696905
Regeni  Italian         -8.5895138120407e-05
Nahas   Arabic          -0.038654345426878
Johnson Scottish        -0.16454122826935
Assad   Arabic          -0.00038677237605178
Pierre  French          -0.028914776216562
Picasso Spanish         -0.2477778249217
Oliver  French          -0.85550814788721
Gomez   Spanish         -0.091491903900953
Putin   Russian         -0.46674656825426
Xiang   Chinese         -1.8310353091522e-06
Satoshi Japanese        -0.098698586910634
O'Flay  Irish           -2.9700686354772e-12
Minski  Polish          -0.056591876014212
Kagos   Greek           -0.051732114586811
```

Comparable results with `-hidden_size 50` (around 6.5575 minutes):

```
Nguyen  Russian         -0.85408548852095
Elbehri Russian         -0.53221673444937
Regeni  Italian         -0.058978010859797
Nahas   Arabic          -0.026778837455653
Johnson English         -0.66698060454329
Assad   Arabic          -0.0028616608223935
Pierre  French          -0.54068725516554
Picasso Italian         -0.69621622215468
Oliver  English         -0.81392586982945
Olivier French          -0.039913656191247
Gomez   Spanish         -0.1590194483273
Putin   Russian         -0.54890581159907
Xiang   Chinese         -0.00083850093507465
Satoshi Japanese        -0.0055069694551833
O'Flay  Irish           -2.8715339585261e-05
Minski  Polish          -0.06606271896492
Kagos   Greek           -0.57052942499604
```

Or use `th predict.lua [word]` to predict a specific word:

```
$ th predict.lua Kanamaki
Kanamaki        Japanese        -0.21953438368209
```

