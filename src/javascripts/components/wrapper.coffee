R = React.DOM
Rc = React.createElement

App.Wrapper = React.createClass
  getInitialState: ->
    hide: true

  componentDidMount: ->
    webview = React.findDOMNode(@refs.webview)
    webview.setUserAgentOverride(navigator.userAgent + " NitrousProForChrome/#{App.version}")

    $webview = $(webview)

    # make target=_blank work
    $webview.on 'newwindow', (e) ->
      window.open e.originalEvent.targetUrl

    $webview.on 'loadstart', (e) ->

    $webview.on 'loadstop', (e) =>

    $webview.on 'contentload', (e) =>
      @injectCode()
      @setState(hide: false)

    $webview.attr(partition: 'persist:nitrous-pro', src: @props.url)

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'newwindow'
    $webview.off 'loadstart'
    $webview.off 'loadstop'
    $webview.off 'contentload'

  injectCode: ->
    webview = React.findDOMNode(@refs.webview)
    webview.insertCSS(file: '/stylesheets/injections/dashboard.css')
    webview.executeScript(file: '/javascripts/injections/dashboard.js')

  render: ->
    R.div className: 'app-wrapper',
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
