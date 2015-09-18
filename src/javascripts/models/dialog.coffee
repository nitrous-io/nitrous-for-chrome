class App.Dialog
  type: null
  text: null
  ok: null
  okLabel: null
  cancel: null

  constructor: (data) ->
    {@type, @text, @ok, @okLabel, @cancel} = data