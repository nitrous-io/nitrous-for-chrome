R = React.DOM
Rc = React.createElement

App.Wrapper = React.createClass
  render: ->
    Rc 'webview', partition: 'persist:nitrous-pro-chrome'
