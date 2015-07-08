R = React.DOM
Rc = React.createElement
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

App.Main = React.createClass
  getInitialState: ->
    user: null
    showSplash: false
    showLogin: false

  componentDidMount: ->
    PubSub.subscribe 'user.loggedIn', (msg, user) =>
      @setState user: user

    @setState showSplash: true
    sleep(2000).then =>
      @setState showSplash: false, showLogin: true

  render: ->
    R.div className: 'app-main',
      Rc App.TitleBar, username: @state.user?.username, gravatar: @state.user?.gravatar
      Rc ReactCSSTransitionGroup, transitionName: 'el', component: 'div', className: 'app-content',
        if @state.showSplash
          Rc App.Splash, key: 'splash', version: App.version
        if @state.showLogin
          Rc App.Login, key: 'login'
