# rnn-name-classifier

Learns to classify names by country of origin with a LSTM RNN, using Torch and ElementResearch's [rnn package](https://github.com/Element-Research/rnn).

Creates a simple one-layer LSTM network and feeds in each character in sequence, outputting the log likielihood of each class (in this case, ethnic origin).

## Usage

Create a folder `names` with a text file for each class, where the name of each file is `[Class].txt`, e.g.:

```
names/
    Italian.txt
    Arabic.txt
```

Train the network with `th train.lua`. After every 100 epochs, the network will be saved as `net.t7` so you can make predictions with `th predict.lua`:

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
