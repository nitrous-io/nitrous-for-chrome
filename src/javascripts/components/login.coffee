R = React.DOM
Rc = React.createElement
TimeoutTransitionGroup = React.addons.TimeoutTransitionGroup

App.Login = React.createClass
  getInitialState: ->
    errorMessage: null
    submitLabel: 'Log In'
    disabled: false
    shake: false

  handleSubmit: (e) ->
    e.preventDefault()
    @setState(disabled: true, submitLabel: 'Logging In...', errorMessage: null)

    elLogin = React.findDOMNode(@refs.login)
    elPassword = React.findDOMNode(@refs.password)
    elLogin.value = login = elLogin.value.trim()
    elPassword.value = password = elPassword.value.trim()

    fail = (jqxhr) =>
      if jqxhr.responseJSON?.error != 'invalid_grant'
        @setState(errorMessage: "#{jqxhr.status} #{jqxhr.statusText} - #{jqxhr.responseJSON?.error || 'error'}: #{jqxhr.responseJSON?.error_description || 'unknown error'}")
      @setState(shake: true, submitLabel: 'Log In')
      sleep(1001).then =>
        @setState(shake: false)
        @setState(disabled: false)

    $.ajax(
      url: App.host + '/api/v0/oauth/token'
      type: 'POST'
      dataType: 'json'
      data:
        grant_type: 'password'
        username: login
        password: password
    ).then((data) =>
      # token fetched, try fetching user
      token = new App.Token(data.access_token)
      token.fetchUser().then((user) ->
        PubSub.publish 'user.loggedIn', user: user, token: token
      , fail)
    , fail)

  handleSignUp: ->
    window.open(App.host + '/app/#/signup')

  handleResetPassword: ->
    window.open(App.host + '/app/#/forgot-password')

  render: ->
    R.div className: 'app-login',
      R.form onSubmit: @handleSubmit, className: classNames(shake: @state.shake),
        R.div className: 'logo'
        R.input ref: 'login', type: 'text', placeholder: 'Username or Email', required: true, disabled: @state.disabled
        R.input ref: 'password', type: 'password', placeholder: 'Password', required: true, disabled: @state.disabled
        R.input type: 'submit', value: @state.submitLabel, disabled: @state.disabled
      R.ul className: 'links',
        R.li {},
          R.a onClick: @handleSignUp, href: '#', 'Sign Up'
        R.li {},
          R.a onClick: @handleResetPassword, href: '#', 'Reset Password'
      Rc TimeoutTransitionGroup, transitionName: 'el', enterTimeout: 101, leaveTimeout: 101, component: 'div',
        if @state.errorMessage
          R.div className: 'error', key: 'error',
            R.p {}, @state.errorMessage
