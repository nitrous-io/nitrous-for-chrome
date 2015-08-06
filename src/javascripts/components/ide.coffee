R = React.DOM
Rc = React.createElement

nextId = 1

zoomLevels = [.25, .33, .50, .67, .75, .90, 1.0, 1.1, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 4.0, 5.0]
defaultZoomLevel = zoomLevels.indexOf(1.0)

App.IDE = React.createClass
  mixins: [App.WrapperMixin]

  getDefaultProps: ->
    ideSessionId: null

  componentDidMount: ->
    @id = nextId++
    webview = React.findDOMNode(@refs.webview)
    $webview = $(webview)

    @zoomLevel = defaultZoomLevel

    $webview.on 'contentload.ide', (e) =>
      webview.setZoomMode 'per-view', =>
        webview.getZoom (zoom) =>
          level = zoomLevels.indexOf(zoom)
          if level != -1
            @zoomLevel = level
          webview.setZoom(zoomLevels[@zoomLevel])

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

    $webview.on 'keydown.ide', (e) =>
      if App.platform.os == 'mac'
        if e.metaKey && e.keyCode == 87 # Cmd-W
          e.preventDefault()
          e.stopPropagation()
          App.injectJS e.target, "if (window.Mousetrap) { Mousetrap.trigger('command+w'); }"
        else if e.metaKey && e.keyCode == 187 # Cmd-equal(=)
          @zoomIn()
        else if e.metaKey && e.keyCode == 189 # Cmd-dash(-)
          @zoomOut()
        else if e.metaKey && e.keyCode == 48  # Cmd-0
          @restoreZoom()
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
        else if e.ctrlKey && e.altKey && e.keyCode == 187 # Ctrl-Alt-equal(=)
          @zoomIn()
        else if e.ctrlKey && e.altKey && e.keyCode == 189 # Ctrl-Alt-dash(-)
          @zoomOut()
        else if e.ctrlKey && e.altKey && e.keyCode == 48  # Ctrl-Alt-0
          @restoreZoom()

  zoomIn: ->
    @zoomLevel = Math.min(@zoomLevel + 1, zoomLevels.length - 1)
    React.findDOMNode(@refs.webview).setZoom(zoomLevels[@zoomLevel])

  zoomOut: ->
    @zoomLevel = Math.max(@zoomLevel - 1, 0)
    React.findDOMNode(@refs.webview).setZoom(zoomLevels[@zoomLevel])

  restoreZoom: ->
    @zoomLevel = defaultZoomLevel
    React.findDOMNode(@refs.webview).setZoom(zoomLevels[@zoomLevel])

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'dialog.ide'
    $webview.off 'keydown.ide'

  render: ->
    R.div className: classNames('app-wrapper', 'app-ide', active: @props.active),
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
