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
      window.open(e.originalEvent.targetUrl)

    $webview.on 'contentload', (e) =>
      @injectCode()
      @setState(hide: false)

    $webview.attr(partition: 'persist:nitrous-pro', src: @props.url)

    @subDashboardAccountSettings = PubSub.subscribe 'dashboard.accountSettings', =>
      App.injectJS(webview, "location.href = '#{App.host}/app/#/account';")

    @subDashboardBilling = PubSub.subscribe 'dashboard.billing', =>
      App.injectJS(webview, "location.href = '#{App.host}/app/#/billing';")

    @subDashboardSendFeedback = PubSub.subscribe 'dashboard.sendFeedback', =>
      App.injectJS(webview, "App.trigger('open-feedback-dialog');")

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'newwindow'
    $webview.off 'loadstart'
    $webview.off 'loadstop'
    $webview.off 'contentload'

    PubSub.unsubscribe @subDashboardAccountSettings
    PubSub.unsubscribe @subDashboardBilling
    PubSub.unsubscribe @subDashboardSendFeedback

  injectCode: ->
    webview = React.findDOMNode(@refs.webview)
    webview.insertCSS(file: '/stylesheets/injections/dashboard.css')
    App.injectJS(webview, """
      if (window.jQuery) {
        jQuery('html').addClass('pro-chrome-app');
      }
    """)

  render: ->
    R.div className: 'app-wrapper',
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
