React = require 'react'
ReactDOM = require 'react-dom'
somata = require './somata-stream'
KefirBus = require 'kefir-bus'

capitalize = (s) ->
    s.split(' ').map (w) ->
        w[0].toUpperCase() + w.slice(1)
    .join(' ')

Spinner = ({children}) ->
    <div className='spinner-container'>
        <div className='spinner'>
            <i className='fa fa-spin fa-circle-o-notch' />
            {if children?
                <span>{children}</span>
            }
        </div>
    </div>

Error = ({children}) ->
    <div className='error-container'>
        <div className='error'>
            <i className='fa fa-warning' />
            {if children?
                <span>{children}</span>
            }
        </div>
    </div>

normalizePredictions = (predictions) ->
    max_score = -99
    min_score = 0
    for prediction in predictions
        score = prediction.score
        if score < min_score
            min_score = score
        if score > max_score
            max_score = score

    range = max_score - min_score
    console.log 'max', max_score, 'min', min_score, 'range', range
    for prediction in predictions
        if prediction.score == max_score
            prediction.max = true
        prediction.score = (prediction.score - min_score) / range

    return predictions

asPercent = (score) -> (100 * score).toFixed(2) + '%'

scaleBetween = (min, max, p) ->
    p * (max - min) + min

App = React.createClass
    getInitialState: ->
        loading: false

    componentDidMount: ->
        @q$ = KefirBus()
        @q$.filter((q) -> q.length > 0).debounce(250).onValue(@search)
        @refs.input.focus()

    changeQ: (e) ->
        q = capitalize e.target.value
        @setState {q}
        @q$.emit q

    search: (q) ->
        @setState {loading: true}
        somata.remote('predict', 'predict', q)
            .onValue (predictions) =>
                console.log 'what', predictions
                predictions = normalizePredictions predictions
                @setState {predictions, error: null, loading: false}
            .onError (error) =>
                @setState {error, loading: false}

    render: ->
        bar_percent = 1
        if @state.predictions?
            bar_percent = 1 / (@state.predictions.length + 1)
        bar_height = bar_percent * window.innerHeight

        <div>
            <input ref='input' value=@state.q onChange=@changeQ placeholder="Enter a name..." style={height: asPercent(bar_percent)} />

            {@state.predictions?.map (prediction) =>
                # console.log '[prediction]', prediction
                <div className={'bar ' + if prediction.max then 'max' else ''} style={width: asPercent(prediction.score), height: asPercent(bar_percent), opacity: scaleBetween(0.2, 1, prediction.score)} key=prediction.class>
                    <span>{prediction.class}</span>
                </div>
            }

            {if @state.loading
                <Spinner />
            }
            {if @state.error
                <Error>{@state.error}</Error>
            }
        </div>

ReactDOM.render <App />, document.getElementById 'app'
