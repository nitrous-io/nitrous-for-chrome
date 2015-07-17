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
      url = e.originalEvent.targetUrl
      prefix = App.host + '/app/#'
      if url.startsWith(prefix)
        route = url.slice(prefix.length)
        PubSub.publish('dashboard.goToRoute', route)
        PubSub.publish('sessions.switch', null)
      else
        window.open(url)

    $webview.on 'contentload.wrapper', (e) =>
      @injectCode()
      @setState(hide: false)

    $webview.on 'permissionrequest.wrapper', (e) ->
      oe = e.originalEvent
      if oe.permission == 'download'
        window.open(oe.url)
      e.originalEvent.request.deny()

    $webview.attr(partition: 'persist:nitrous-pro', src: @props.url, allowtransparency: 'on')

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'newwindow.wrapper'
    $webview.off 'contentload.wrapper'
    $webview.off 'permissionrequest.wrapper'

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
