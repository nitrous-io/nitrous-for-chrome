R = React.DOM

App.TitleBar = React.createClass
  getDefaultProps: ->
    username: null
    gravatar: null

  getInitialState: ->
    focused: false
    minimized: false
    maximized: false
    gravatarImage: null

  componentDidMount: ->
    $(window).focus =>
      @setState(focused: true)
    $(window).blur =>
      @setState(focused: false)
    @setState(focused: document.hasFocus())
    chrome.app.window.current().onFullscreened.addListener =>
      @setState(maximized: true)
    chrome.app.window.current().onMaximized.addListener =>
      @setState(maximized: true)
    chrome.app.window.current().onMinimized.addListener =>
      @setState(minimized: true)
    chrome.app.window.current().onRestored.addListener =>
      if @state.minimized
        @setState(minimized: false)
      else if @state.maximized
        @setState(maximized: false)

  componentDidUpdate: (prevProps, prevState) ->
    if prevProps.gravatar != @props.gravatar
      $.ajax(
        type: 'GET'
        url: @props.gravatar
        dataType: 'native'
        xhrFields:
          responseType: 'blob'
      ).then (blob) =>
        @setState(gravatarImage: URL.createObjectURL(blob))

  handleMinimize: ->
    chrome.app.window.current().minimize()

  handleRestore: ->
    chrome.app.window.current().restore()

  handleMaximize: ->
    chrome.app.window.current().maximize()

  handleClose: ->
    chrome.app.window.current().close()

  render: ->
    R.div className: classNames('app-title-bar', focused: @state.focused),
      R.div className: 'content',
        if @props.username
          R.button className: 'account-btn', tabIndex: '-1',
            R.div className: 'gravatar', style: { backgroundImage: "url(#{@state.gravatarImage})" }
            R.span className: 'username', @props.username
            R.span className: 'triangle'
      R.div className: 'window-controls',
        R.button onClick: @handleMinimize, className: 'minimize', tabIndex: '-1'
        if @state.maximized
          R.button onClick: @handleRestore, className: 'restore', tabIndex: '-1'
        else
          R.button onClick: @handleMaximize, className: 'maximize', tabIndex: '-1'
        R.button onClick: @handleClose, className: 'close', tabIndex: '-1'
