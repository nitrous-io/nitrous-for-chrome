R = React.DOM
Rc = React.createElement
TimeoutTransitionGroup = React.addons.TimeoutTransitionGroup

App.TitleBar = React.createClass
  getDefaultProps: ->
    username: null
    gravatar: null
    currentIdeSession: null

  getInitialState: ->
    focused: false
    minimized: false
    maximized: false
    gravatarImage: 'none'
    openMenu: null

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

  handleMaximize: (e) ->
    if e.altKey
      chrome.app.window.current().fullscreen()
    else
      chrome.app.window.current().maximize()

  handleClose: ->
    chrome.app.window.current().close()

  handleMenuButton: (e) ->
    $currentTarget = $(e.currentTarget)
    return if $currentTarget.is('.disabled')
    menu = $currentTarget.data('dropdown-menu')
    if e.type == 'click'
      @setState openMenu: toggleMenu(@state.openMenu, menu)
      @handleBgClick()
    else if e.type == 'mouseover'
      if @state.openMenu != null && @state.openMenu != menu
        @setState openMenu: menu

  handleBgClick: ->
    $('body').one 'click', (e) =>
      if $(e.target).closest('.dropdown button').length == 0 || $(e.target).is('.dropdown button.disabled')
        @setState openMenu: null

  handleAccountMenuAccountSettings: ->
    PubSub.publish('sessions.switch', null)
    PubSub.publish('dashboard.accountSettings')

  handleAccountMenuBilling: ->
    PubSub.publish('sessions.switch', null)
    PubSub.publish('dashboard.billing')

  handleAccountMenuSendFeedback: ->
    PubSub.publish('sessions.switch', null)
    PubSub.publish('dashboard.sendFeedback')

  handleAccountMenuHelp: ->
    window.open(App.helpUrl)

  handleAccountMenuLogOut: ->
    PubSub.publish('user.logOut')

  handleSessionsMenuDashboard: ->
    PubSub.publish('sessions.switch', null)

  handleSessionsMenuIDE: (e) ->
    ideSessionId = $(e.currentTarget).data('session-id')
    PubSub.publish('sessions.switch', ideSessionId)

  handleSessionsMenuCloseIDE: (e) ->
    $parent = $(e.currentTarget).parent()
    ideSessionId = $parent.data('session-id')
    slug = $parent.data('slug')
    dialog = new App.Dialog
      type: 'confirm'
      text: "Are you sure you want to close the IDE session for “#{slug}”?\n\nYou will lose any unsaved work."
      ok: ->
        PubSub.publish('sessions.close', ideSessionId)
    PubSub.publish('ui.openDialog', dialog)

  handleNewContainer: ->
    PubSub.publish('sessions.switch', null)
    PubSub.publish('dashboard.newContainer')

  handleNewWorkspace: ->
    PubSub.publish('sessions.switch', null)
    PubSub.publish('dashboard.newWorkspace')

  render: ->
    R.div className: classNames('app-title-bar', focused: @state.focused),
      R.div className: 'content',
        if @props.username
          R.div className: 'menu',
            R.div className: classNames('account', 'dropdown', open: @state.openMenu == 'account'),
              Rc TimeoutTransitionGroup, transitionName: 'el', enterTimeout: 101, leaveTimeout: 101, component: 'div',
                if @state.openMenu == 'account'
                  R.ul key: 'account', className: 'ui-dropdown-menu below',
                    R.li onClick: @handleAccountMenuAccountSettings, 'Account Settings'
                    R.li onClick: @handleAccountMenuBilling, 'Billing'
                    R.li className: 'separator'
                    R.li onClick: @handleAccountMenuSendFeedback, 'Send Feedback'
                    R.li onClick: @handleAccountMenuHelp, 'Help'
                    R.li className: 'separator'
                    R.li onClick: @handleAccountMenuLogOut, 'Log Out'
              R.button onClick: @handleMenuButton, onMouseOver: @handleMenuButton, 'data-dropdown-menu': 'account', tabIndex: '-1',
                R.div className: 'gravatar', style: { backgroundImage: @state.gravatarImage }
                R.span className: 'username', @props.username
            R.div className: classNames('new', 'dropdown', open: @state.openMenu == 'new'),
              Rc TimeoutTransitionGroup, transitionName: 'el', enterTimeout: 101, leaveTimeout: 101, component: 'div',
                if @state.openMenu == 'new'
                  R.ul key: 'new', className: 'ui-dropdown-menu below',
                    R.li onClick: @handleNewContainer, 'New Container...'
                    R.li onClick: @handleNewWorkspace, 'New Workspace...'
              R.button onClick: @handleMenuButton, onMouseOver: @handleMenuButton, 'data-dropdown-menu': 'new', tabIndex: '-1'
            R.div className: classNames('sessions', 'dropdown', open: @state.openMenu == 'sessions'),
              Rc TimeoutTransitionGroup, transitionName: 'el', enterTimeout: 101, leaveTimeout: 101, component: 'div',
                if @state.openMenu == 'sessions'
                  R.ul key: 'sessions', className: 'ui-dropdown-menu below',
                    R.li onClick: @handleSessionsMenuDashboard, 'Dashboard'
                    R.li className: 'separator'
                    @props.ideSessions.map (ideSession) =>
                      R.li onClick: @handleSessionsMenuIDE, key: ideSession.id, 'data-session-id': ideSession.id, 'data-slug': ideSession.slug,
                        ideSession.slug
                        R.a onClick: @handleSessionsMenuCloseIDE, className: 'close-ide', href: '#', tabIndex: '-1'
              R.button onClick: @handleMenuButton, onMouseOver: @handleMenuButton, 'data-dropdown-menu': 'sessions', className: classNames(disabled: @props.ideSessions.length == 0), tabIndex: '-1',
                @props.currentIdeSession?.slug ? 'Dashboard'

      R.div className: 'window-controls',
        R.button onClick: @handleMinimize, className: 'minimize', tabIndex: '-1'
        if @state.maximized
          R.button onClick: @handleRestore, className: 'restore', tabIndex: '-1'
        else
          R.button onClick: @handleMaximize, className: 'maximize', tabIndex: '-1'
        R.button onClick: @handleClose, className: 'close', tabIndex: '-1'

toggleMenu = (state, name) ->
  if state == name then null else name
