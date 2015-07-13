nextId = 0

class App.IdeSession
  id: null
  slug: null

  constructor: (@slug) ->
    @id = "ide-session-#{nextId++}"

  @getter 'url', ->
    return unless @slug
    "#{App.host}/ide/#/#{@slug}"
