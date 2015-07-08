class App.Token
  token: null

  constructor: (@token) ->

  ajax: (settings={}) ->
    settings.headers ?= {}
    settings.headers.Authorization = "Bearer #{@token}"
    $.ajax(settings)
