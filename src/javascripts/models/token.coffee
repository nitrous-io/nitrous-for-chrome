class App.Token
  token: null

  constructor: (@token) ->

  ajax: (settings={}) ->
    settings.headers ?= {}
    settings.headers.Authorization = "Bearer #{@token}"
    $.ajax(settings)

  fetchUser: ->
    new Promise (resolve, reject) =>
      @ajax(
        url: App.host + '/api/v0/user'
        type: 'GET'
        dataType: 'json'
      ).then (data, jqxhr) ->
        reject(jqxhr) unless data.user?
        resolve(new App.User(data.user))
      , (jqxhr) ->
        reject(jqxhr)

  fetchLoginToken: ->
    new Promise (resolve, reject) =>
      @ajax(
        url: App.host + '/api/v0/user/login_token'
        type: 'GET'
        dataType: 'json'
      ).then (data) ->
        resolve(data.login_token)
      , (jqxhr) ->
        reject(jqxhr)

  persist: ->
    new Promise (resolve) =>
      chrome.storage.local.set token: @token, ->
        resolve()

  @clear: ->
    new Promise (resolve) ->
      chrome.storage.local.remove 'token', ->
        resolve()

  @load: ->
    new Promise (resolve, reject) ->
      chrome.storage.local.get 'token', (data) ->
        if token = data.token
          resolve(new App.Token(token))
        else
          reject()
