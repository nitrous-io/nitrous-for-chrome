R = React.DOM

App.Login = React.createClass
  getInitialState: ->
    errorMessage: null
    submitLabel: 'Log In'
    disabled: false
    shake: false

  handleSubmit: (e) ->
    e.preventDefault()
    @setState(disabled: true, submitLabel: 'Logging In...')

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

  render: ->
    R.div className: 'app-login',
      R.form onSubmit: @handleSubmit, className: classNames(shake: @state.shake),
        R.div className: 'logo'
        R.input ref: 'login', type: 'text', placeholder: 'Username or Email', required: true, disabled: @state.disabled
        R.input ref: 'password', type: 'password', placeholder: 'Password', required: true, disabled: @state.disabled
        R.input type: 'submit', value: @state.submitLabel, disabled: @state.disabled
        R.div className: 'error', @state.errorMessage
