#= require jquery-2.1.4

window.App =
  name: null
  version: null
  host: null
  token: null

  main: ->
    @name = $('meta[name=AppName]').attr('content')
    @version = $('meta[name=AppVersion]').attr('content')
    @host = $('meta[name=Host]').attr('content')


    $('#login, #app').hide()

    @showSplash()
    sleep(2000).then => @showLogin()

    $login = $('#login')
    $input = $login.find('input')
    $submit = $login.find('input[type=submit]')
    $error = $login.find('.error').text('')

    $login.find('form').submit (evt) =>
      evt.preventDefault()
      $input.attr(disabled: true)
      $submit.val('Logging In...')

      @login().then (data) =>
        @token = data.access_token
        chrome.storage.local.set(token: @token)
        @openApp()

      , (jqxhr) =>
        if jqxhr.responseJSON?.error != 'invalid_grant'
          $error.text("#{jqxhr.status} #{jqxhr.statusText} - #{jqxhr.responseJSON?.error || 'error'}: #{jqxhr.responseJSON?.error_description || 'unknown error'}")

        @shakeLogin()
        $input.attr(disabled: false)
        $submit.val('Log In')
        $login.find('input[type=text]').focus().select()

  showSplash: ->
    $('#splash').addClass('show')

  showLogin: ->
    $('#splash').removeClass('show')
    $('#login').css(display: '')

    sleep(301).then ->
      $('#splash').remove()
      $('#login').addClass('show')
      $('#login input[type=text]').focus().select()

  shakeLogin: ->
    $('#login').addClass('shake')
    sleep(1000).then ->
      $('#login').removeClass('shake')

  login: ->
    $login = $('#login')
    $.ajax
      url: @host + '/api/v0/oauth/token'
      type: 'POST'
      dataType: 'json'
      data:
        grant_type: 'password'
        username: $login.find('input[name=login]').val()
        password: $login.find('input[name=password]').val()

  openApp: ->
    new Promise (resolve, reject) =>
      @obtainLoginToken().then (data) =>
        loginToken = window.encodeURIComponent(data.login_token)
        @showWebView(@host + "/token_login?token=#{loginToken}")
        resolve.apply(this, arguments)
      , (jqxhr) ->
        reject.apply(this, arguments)

  obtainLoginToken: ->
    $.ajax
      url: @host + '/api/v0/user/login_token'
      type: 'GET'
      dataType: 'json'
      headers:
        Authorization: "Bearer #{@token}"

  showWebView: (url) ->
    $('#login').removeClass('show')
    sleep(201).then ->
      $('#login').hide()
      $('#app').css(display: '')
      $('<webview>').attr(src: url).appendTo($('#app'))

sleep = (duration) ->
  new Promise (resolve) ->
    window.setTimeout(->
      resolve()
    , duration)

document.fonts.ready.then ->
  App.main()
