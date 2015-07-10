R = React.DOM
Rc = React.createElement
TimeoutTransitionGroup = React.addons.TimeoutTransitionGroup

App.TitleBar = React.createClass
  getDefaultProps: ->
    username: null
    gravatar: null

  getInitialState: ->
    focused: false
    minimized: false
    maximized: false
    gravatarImage: 'none'
    accountDropdownOpen: false

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
        image = "url(#{URL.createObjectURL(blob)})"
        @setState(gravatarImage: image)

  handleMinimize: ->
    chrome.app.window.current().minimize()

  handleRestore: ->
    chrome.app.window.current().restore()

  handleMaximize: ->
    chrome.app.window.current().maximize()

  handleClose: ->
    chrome.app.window.current().close()

  handleAccountButton: ->
    @setState accountDropdownOpen: !@state.accountDropdownOpen

  handleAccountMenuAccountSettings: ->
    PubSub.publish('dashboard.accountSettings')
    @setState accountDropdownOpen: false

  handleAccountMenuBilling: ->
    PubSub.publish('dashboard.billing')
    @setState accountDropdownOpen: false

  handleAccountMenuSendFeedback: ->
    PubSub.publish('dashboard.sendFeedback')
    @setState accountDropdownOpen: false

  handleAccountMenuHelp: ->
    window.open(App.helpUrl)
    @setState accountDropdownOpen: false

  handleAccountMenuLogOut: ->
    PubSub.publish('user.logOut')
    @setState accountDropdownOpen: false

  render: ->
    R.div className: classNames('app-title-bar', focused: @state.focused),
      R.div className: 'content',
        if @props.username
          R.div className: classNames('account-dropdown', open: @state.accountDropdownOpen),
            Rc TimeoutTransitionGroup, transitionName: 'el', enterTimeout: 101, leaveTimeout: 101, component: 'div',
              if @state.accountDropdownOpen
                R.ul key: 'account-dropdown', className: 'dropdown below',
                  R.li onClick: @handleAccountMenuAccountSettings, 'Account Settings'
                  R.li onClick: @handleAccountMenuBilling, 'Billing'
                  R.li className: 'separator'
                  R.li onClick: @handleAccountMenuSendFeedback, 'Send Feedback'
                  R.li onClick: @handleAccountMenuHelp, 'Help'
                  R.li className: 'separator'
                  R.li onClick: @handleAccountMenuLogOut, 'Log Out'
            R.button onClick: @handleAccountButton, tabIndex: '-1',
              R.div className: 'gravatar', style: { backgroundImage: @state.gravatarImage }
              R.span className: 'username', @props.username
              R.span className: 'triangle'

      R.div className: 'window-controls',
        R.button onClick: @handleMinimize, className: 'minimize', tabIndex: '-1'
        if @state.maximized
          R.button onClick: @handleRestore, className: 'restore', tabIndex: '-1'
        else
          R.button onClick: @handleMaximize, className: 'maximize', tabIndex: '-1'
        R.button onClick: @handleClose, className: 'close', tabIndex: '-1'
