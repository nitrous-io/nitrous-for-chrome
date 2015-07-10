class App.Token
  token: null

  constructor: (@token) ->

  ajax: (settings={}) ->
    settings.headers ?= {}
    settings.headers.Authorization = "Bearer #{@token}"
    $.ajax(settings)

  getLoginToken: ->
    new Promise (resolve, reject) =>
      @ajax(
        url: App.host + '/api/v0/user/login_token'
        type: 'GET'
        dataType: 'json'
      ).then (data) ->
        resolve(data.login_token)
      , (jqxhr) ->
        reject(jqxhr)
