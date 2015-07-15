R = React.DOM
Rc = React.createElement

nextId = 1

App.IDE = React.createClass
  mixins: [App.WrapperMixin]

  getDefaultProps: ->
    ideSessionId: null

  componentDidMount: ->
    @id = nextId++
    webview = React.findDOMNode(@refs.webview)
    $webview = $(webview)

    $webview.on 'dialog.ide', (e) ->
      e.preventDefault()
      oe = e.originalEvent
      dialog = new App.Dialog
        type: oe.messageType
        text: oe.messageText
        ok: (str) ->
          oe.dialog?.ok?(str)
        cancel: ->
          oe.dialog?.cancel?()
      PubSub.publish 'ui.openDialog', dialog

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'dialog.ide'

  render: ->
    R.div className: classNames('app-wrapper', 'app-ide', active: @props.active),
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
