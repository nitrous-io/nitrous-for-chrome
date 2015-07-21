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
      App.injectJS(webview, "location.hash = '#/account';")

    @subDashboardBilling = PubSub.subscribe 'dashboard.billing', =>
      App.injectJS(webview, "location.hash = '#/billing';")

    @subDashboardSendFeedback = PubSub.subscribe 'dashboard.sendFeedback', =>
      App.injectJS(webview, "App.trigger('open-feedback-dialog');")

    @subDashboardNewContainer = PubSub.subscribe 'dashboard.newContainer', =>
      App.injectJS(webview, "location.hash = '#/containers/new';")

    @subDashboardNewWorkspace = PubSub.subscribe 'dashboard.newWorkspace', =>
      App.injectJS(webview, "location.hash = '#/workspaces/new';")

    @subDashboardGoToRoute = PubSub.subscribe 'dashboard.goToRoute', (msg, route) =>
      App.injectJS(webview, "location.hash = '##{route.replace(/'/g, "\\'")}';")

    @subUserLogout = PubSub.subscribe 'user.logOut', =>
      App.injectJS(webview, "window.localStorage.clear();")

  componentWillUnmount: ->
    PubSub.unsubscribe @subDashboardAccountSettings
    PubSub.unsubscribe @subDashboardBilling
    PubSub.unsubscribe @subDashboardSendFeedback
    PubSub.unsubscribe @subDashboardNewContainer
    PubSub.unsubscribe @subDashboardNewWorkspace
    PubSub.unsubscribe @subDashboardGoToRoute
    PubSub.unsubscribe @subUserLogout

  render: ->
    R.div className: classNames('app-wrapper', 'app-dashboard', active: @props.active),
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
