class App.Dialog
  type: null
  text: null
  okLabel: null
  ok: null
  cancel: null

  constructor: (data) ->
    {@type, @text, @ok, @okLabel, @cancel} = data