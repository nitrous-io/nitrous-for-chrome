R = React.DOM
Rc = React.createElement

App.DialogView = React.createClass
  getDefaultProps: ->
    type: null
    text: null
    controller: null

  componentDidMount: ->
    @previouslyFocusedElement = document.activeElement
    if @refs.input
      $(React.findDOMNode(@refs.input)).select().focus()
    else
      $(React.findDOMNode(@refs.ok)).focus()

  componentWillUnmount: ->
    @previouslyFocusedElement?.focus?()

  handleKeyDown: (e) ->
    switch e.nativeEvent.keyCode
      when 13 then @handleOK()
      when 27 then @handleCancel()
    true

  handleCancel: ->
    @props.controller?.cancel()
    PubSub.publish 'ui.closeDialog'
    true

  handleOK: ->
    @props.controller?.ok(React.findDOMNode(@refs.input)?.value)
    PubSub.publish 'ui.closeDialog'
    true

  render: ->
    R.div className: 'app-dialog',
      R.div className: 'backdrop'
      R.div className: 'window', onKeyDown: @handleKeyDown,
        R.div className: 'content',
          R.p {}, @props.text
          if @props.type == 'prompt'
            R.input ref: 'input', type: 'text'
        R.div className: 'buttons',
          if @props.type != 'alert'
            R.button onClick: @handleCancel, 'Cancel'
          R.button ref: 'ok', onClick: @handleOK, className: 'primary', 'OK'
