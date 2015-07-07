R = React.DOM
Rc = React.createElement
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

App.Main = React.createClass
  getInitialState: ->
    showSplash: false
    showLogin: false

  componentDidMount: ->
    @setState showSplash: true
    sleep(2000).then =>
      @setState showSplash: false, showLogin: true

  render: ->
    R.div className: 'app-main',
      Rc App.TitleBar
      Rc ReactCSSTransitionGroup, transitionName: 'el', component: 'div', className: 'app-content',
        if @state.showSplash
          Rc App.Splash, key: 'splash', version: App.version
        if @state.showLogin
          Rc App.Login, key: 'login'
