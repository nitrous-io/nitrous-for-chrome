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

    $webview.on 'dialog.ide', (e) =>
      e.preventDefault()
      e.originalEvent.dialog.ok()

    $webview.on 'contentload.ide', (e) =>
      App.injectJS webview, """
        (function() {
          var source = null;
          if (window.jQuery) {
            jQuery(window).on('message', function(e) {
              if (e.originalEvent.data === 'chrome-app-hello') {
                source = e.originalEvent.source;
              }
            });
          }
          if (window.App && App.IdeMainMenuView) {
            var fn = App.IdeMainMenuView.prototype.didInsertElement;
            App.IdeMainMenuView.prototype.didInsertElement = function() {
              var $close = $('<li><a href="#" title="Close IDE"><i class="fa fa-times"></i></a></li>');
              $close.on('click', function(e) {
                e.preventDefault();
                source.postMessage('close-#{@id}', '*');
              });
              this.$('.topnav .secondary-nav ul.nav li.ui.dropdown').before($close);
              if (fn) {
                return fn.apply(this, arguments);
              }
            };
          }
        }());
      """, =>
        webview.contentWindow.postMessage('chrome-app-hello', App.host)
        $(window).on "message.ide-#{@id}", (e) =>
          if e.originalEvent.data == "close-#{@id}"
            PubSub.publish 'sessions.close', @props.ideSessionId

  componentWillUnmount: ->
    $webview = $(React.findDOMNode(@refs.webview))
    $webview.off 'contentload.ide'
    $webview.off 'dialog.ide'
    $(window).off "message.ide-#{@id}"

  render: ->
    R.div className: classNames('app-wrapper', 'app-ide', active: @props.active),
      Rc 'webview', ref: 'webview', className: classNames(hide: @state.hide)
