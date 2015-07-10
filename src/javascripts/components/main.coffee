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
    PubSub.subscribe 'user.loggedIn', (msg, user) =>
      @setState user: user
      App.token.getLoginToken().then (loginToken) =>
        url = App.host + "/token_login?token=#{window.encodeURIComponent(loginToken)}"
        @setState showLogin: false, showDashboard: true, dashboardUrl: url

    @setState showSplash: true
    sleep(2000).then =>
      @setState showSplash: false, showLogin: true

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
