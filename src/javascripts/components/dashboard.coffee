R = React.DOM
Rc = React.createElement

App.Dashboard = React.createClass
  mixins: [App.WrapperMixin]

  componentDidMount: ->
    webview = React.findDOMNode(@refs.webview)

    webview.request.onBeforeRequest.addListener((details) ->
      slug = details.url.match(/\/ide\/#\/(.+)$/)[1]

      PubSub.publish 'sessions.newIde', slug

      App.injectJS(webview, """
        if (window.App && App.__container__ && App.__container__.lookup) {
          var ci = App.__container__.lookup('controller:containerIndex');
          var cn = App.__container__.lookup('controller:containersNew');
          if (ci) { ci.set('openingIDE', false); }
          if (cn) { cn.set('openingIDE', false); }
        }
      """)

      return cancel: true
    , urls: [App.host + "/ide*"], ['blocking'])

    @subDashboardAccountSettings = PubSub.subscribe 'dashboard.accountSettings', =>
      App.injectJS(webview, "location.href = '#{App.host}/app/#/account';")

    @subDashboardBilling = PubSub.subscribe 'dashboard.billing', =>
      App.injectJS(webview, "location.href = '#{App.host}/app/#/billing';")

    @subDashboardSendFeedback = PubSub.subscribe 'dashboard.sendFeedback', =>
      App.injectJS(webview, "App.trigger('open-feedback-dialog');")

  componentWillUnmount: ->
    PubSub.unsubscribe @subDashboardAccountSettings
    PubSub.unsubscribe @subDashboardBilling
    PubSub.unsubscribe @subDashboardSendFeedback

  render: ->
    R.div className: classNames('app-wrapper', 'app-dashboard', active: @props.active),
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
