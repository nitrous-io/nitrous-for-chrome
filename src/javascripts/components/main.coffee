R = React.DOM
Rc = React.createElement
TimeoutTransitionGroup = React.addons.TimeoutTransitionGroup

App.Main = React.createClass
  getInitialState: ->
    user: null
    showSplash: false
    showLogin: false
    showWebApp: false
    dashboardUrl: null
    ideSessions: []
    currentIdeSession: null # null = dashboard
    dialog: null

  componentDidMount: ->
    $(window).on 'keydown.main', (e) ->
      if App.platform.os == 'mac'
        if e.metaKey && (e.keyCode == 81 || e.keyCode == 87) # Cmd-Q / Cmd-W
          e.preventDefault()
          PubSub.publish 'app.confirmClose'
      else
        if (e.ctrlKey && e.keyCode == 87) || # Ctrl-W
           (e.altKey && e.keyCode == 115)    # Alt-F4
          e.preventDefault()
          PubSub.publish 'app.confirmClose'

    $(window).on 'focus.main', ->
      $('.app-wrapper.active > webview').focus()

    @subAppConfirmClose = PubSub.subscribe 'app.confirmClose', =>
      win = chrome.app.window.current()
      dialog = new App.Dialog
        type: 'confirm'
        text: "Are you sure you want to close Nitrous?\n\nYou will lose any unsaved work."
        ok: =>
          @quit()
      win.focus()
      PubSub.publish('ui.openDialog', dialog)

    @subUserLoggedIn = PubSub.subscribe 'user.loggedIn', (msg, data) =>
      App.token = token = data.token
      App.user = user = data.user
      token.persist()
      token.fetchLoginToken().then (loginToken) =>
        url = App.host + "/token_login?token=#{window.encodeURIComponent(loginToken)}"
        @setState user: user, showSplash: false, showLogin: false, showWebApp: true, dashboardUrl: url

    @subUserLogout = PubSub.subscribe 'user.logOut', =>
      App.Token.clear().then ->
        chrome.runtime.reload()

    @subSessionsNewIde = PubSub.subscribe 'sessions.newIde', (msg, slug) =>
      ideSessions = @state.ideSessions.slice()
      if ideSession = ideSessions.find((o) -> o.slug == slug)
        @setState currentIdeSession: ideSession
        return
      ideSession = new App.IdeSession(slug)
      ideSessions.push(ideSession)
      @setState ideSessions: ideSessions, currentIdeSession: ideSession

    @subSessionsSwitch = PubSub.subscribe 'sessions.switch', (msg, sessionId) =>
      ideSession = @state.ideSessions.find((o) -> o.id == sessionId) ? null
      @setState currentIdeSession: ideSession

    @subSessionsClose = PubSub.subscribe 'sessions.close', (msg, sessionId) =>
      ideSessions = @state.ideSessions.slice()
      i = ideSessions.findIndex (o) -> o.id == sessionId
      return if i == -1
      ideSessions.splice(i, 1)
      @setState ideSessions: ideSessions, currentIdeSession: null

    @subUiOpenDialog = PubSub.subscribe 'ui.openDialog', (msg, dialog) =>
      @setState dialog: dialog

    @subUiCloseDialog = PubSub.subscribe 'ui.closeDialog', =>
      @setState dialog: null

    @setState showSplash: true

    showLogin = =>
      App.Token.clear()
      sleep(2000).then =>
        @setState showSplash: false, showLogin: true

    App.Token.load().then((token) ->
      token.fetchUser().then((user) ->
        PubSub.publish 'user.loggedIn', user: user, token: token
      , showLogin)
    , showLogin)

  componentWillUnmount: ->
    PubSub.unsubscribe @subAppConfirmClose
    PubSub.unsubscribe @subUserLoggedIn
    PubSub.unsubscribe @subUserLogOut
    PubSub.unsubscribe @subSessionsNewIde
    PubSub.unsubscribe @subSessionsSwitch
    PubSub.unsubscribe @subSessionsClose
    PubSub.unsubscribe @subUiOpenDialog
    PubSub.unsubscribe @subUiCloseDialog
    $(window).off 'keydown.main'
    $(window).off 'focus.main'

  quit: ->
    win = chrome.app.window.current()
    win.hide()
    PubSub.publish 'app.beforeClose'
    @setState ideSessions: []
    window.setTimeout(->
      win.close()
    , 1000)

  render: ->
    R.div className: 'app-main',
      Rc App.TitleBar, username: @state.user?.username, gravatar: @state.user?.gravatar, ideSessions: @state.ideSessions, currentIdeSession: @state.currentIdeSession
      Rc TimeoutTransitionGroup, transitionName: 'el', enterTimeout: 201, leaveTimeout: 201, component: 'div', className: 'app-content',
        if @state.showSplash
          Rc App.Splash, key: 'splash', version: App.version
        if @state.showLogin
          Rc App.Login, key: 'login'
        if @state.showWebApp
          R.div key: 'web-app', className: 'app-web-app',
            Rc App.Dashboard, key: 'dashboard', url: @state.dashboardUrl, active: @state.currentIdeSession == null
            @state.ideSessions.map (ideSession) =>
              Rc App.IDE, key: ideSession.id, url: ideSession.url, ideSessionId: ideSession.id, active: @state.currentIdeSession?.id == ideSession.id
        if @state.dialog
          Rc App.DialogView, key: 'dialog', type: @state.dialog.type ? 'alert', text: @state.dialog.text, ok: @state.dialog.ok, cancel: @state.dialog.cancel
