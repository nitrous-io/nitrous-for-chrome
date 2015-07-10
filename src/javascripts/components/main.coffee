R = React.DOM
Rc = React.createElement
TimeoutTransitionGroup = React.addons.TimeoutTransitionGroup

App.Main = React.createClass
  getInitialState: ->
    user: null
    showSplash: false
    showLogin: false
    dashboardUrl: null

  componentDidMount: ->
    @subUserLoggedIn = PubSub.subscribe 'user.loggedIn', (msg, data) =>
      App.token = token = data.token
      App.user = user = data.user
      token.persist()
      token.fetchLoginToken().then (loginToken) =>
        url = App.host + "/token_login?token=#{window.encodeURIComponent(loginToken)}"
        @setState user: user, showSplash: false, showLogin: false, showDashboard: true, dashboardUrl: url

    @subUserLogout = PubSub.subscribe 'user.logOut', =>
      App.Token.clear().then ->
        chrome.runtime.reload()

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
    PubSub.unsubscribe @subUserLoggedIn

  render: ->
    R.div className: 'app-main',
      Rc App.TitleBar, username: @state.user?.username, gravatar: @state.user?.gravatar
      Rc TimeoutTransitionGroup, transitionName: 'el', enterTimeout: 201, leaveTimeout: 201, component: 'div', className: 'app-content',
        if @state.showSplash
          Rc App.Splash, key: 'splash', version: App.version
        if @state.showLogin
          Rc App.Login, key: 'login'
        if @state.showDashboard
          Rc App.Wrapper, key: 'dashboard', url: @state.dashboardUrl
