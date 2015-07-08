#= require md5

class App.User
  id: null
  username: null
  email: null
  name: null
  admin: false

  constructor: (data) ->
    {@id, @username, @email, @name, @admin} = data

  @getter 'gravatar', ->
    return unless @email
    "https://secure.gravatar.com/avatar/#{md5(@email)}?default=retro&secure=true&size=36"
