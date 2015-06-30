#= require jquery-2.1.4

window.App =
  main: ->
    @setupEventHandlers()
    @showSplash()
    @showLogin()

  showSplash: ->
    $('#splash').addClass('show')

  showLogin: ->
    window.setTimeout(->
      $('#splash').removeClass('show')
      window.setTimeout(->
        $('#login').addClass('show')
        $('#login input[type=text]').focus().select()
      , 300)
    , 2000)

  shakeLogin: ->
    $('#login').addClass('shake')
    new Promise (resolve, reject) ->
      window.setTimeout(->
        $('#login').removeClass('shake')
        resolve()
      , 1000)

  setupEventHandlers: ->
    $login = $('#login')
    $input = $login.find('input')
    $submit = $login.find('input[type=submit]')
    $login.find('form').submit =>
      $input.attr(disabled: true)
      $submit.val('Logging In...')
      @shakeLogin().then ->
        $input.attr(disabled: false)
        $submit.val('Log In')
        $login.find('input[type=text]').focus().select()
      false

document.fonts.ready.then ->
  App.main()
