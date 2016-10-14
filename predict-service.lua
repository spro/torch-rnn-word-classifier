somata = require 'somata'
require 'predict'

predict_service = somata.Service.create('predict', {
    predict=function(message, cb)
        if #message < 1 then
            cb("Input is too short")
        elseif #message > 20 then
            cb("Input is too long")
        else
            local prediction, scores = predict(message)
            print('scores', scores)
            cb(nil, scores)
        end
    end
}, {heartbeat=2000})

predict_service:register()
