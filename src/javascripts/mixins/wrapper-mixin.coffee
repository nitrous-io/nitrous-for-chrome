App.WrapperMixin =
  getDefaultProps: ->
    active: false
    url: null

  getInitialState: ->
    hide: true

  componentDidMount: ->
    webview = React.findDOMNode(@refs.webview)
    webview.setUserAgentOverride(navigator.userAgent + " NitrousProForChrome/#{App.version}")

    $webview = $(webview)

    # make target=_blank work
    $webview.on 'newwindow.wrapper', (e) ->
      window.open(e.originalEvent.targetUrl)

    $webview.on 'contentload.wrapper', (e) =>
      @injectCode()
      @setState(hide: false)

    $webview.attr(partition: 'persist:nitrous-pro', src: @props.url, allowtransparency: 'on')

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'newwindow.wrapper'
    $webview.off 'contentload.wrapper'

  injectCode: ->
    webview = React.findDOMNode(@refs.webview)
    webview.insertCSS(file: '/stylesheets/inject.css')
    App.injectJS(webview, """
      (function() {
        if (window.jQuery) {
          jQuery('html').addClass('chrome-app');
        }
        if (window.App && App.set) {
          App.set('chromeApp', true);
        }
      }());
    """)
