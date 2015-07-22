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

    $webview.on 'keydown.ide', (e) ->
      if App.platform.os == 'mac'
        if e.metaKey && e.keyCode == 87 # Cmd-W
          e.preventDefault()
          e.stopPropagation()
          App.injectJS e.target, "if (window.Mousetrap) { Mousetrap.trigger('command+w'); }"
      else
        if e.ctrlKey && e.keyCode == 87 # Ctrl-W
          e.preventDefault()
          e.stopPropagation()
          App.injectJS e.target, """
            if (window.jQuery && window.App && App.get && App.get('consoleFocused')) {
              var k = new CustomEvent('keydown', { detail: 0, bubbles: true, cancelable: true });
              k.keyCode=#{e.keyCode}; k.which=#{e.which}; k.shiftKey=#{e.shiftKey}; k.ctrlKey=#{e.ctrlKey}; k.metaKey=#{e.metaKey}; k.altKey=#{e.altKey};
              jQuery('.ide-console-session-view.active iframe')[0].contentWindow.NitrousTerminal.term.keyDown(k);
            } else if (window.Mousetrap) { Mousetrap.trigger('ctrl+w'); }
          """

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'dialog.ide'
    $webview.off 'keydown.ide'

  render: ->
    R.div className: classNames('app-wrapper', 'app-ide', active: @props.active),
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
