R = React.DOM

App.Splash = React.createClass
  getDefaultProps: ->
    version: '0.0.0'

  componentDidMount: ->
    chrome.app.window.current().show()

  render: ->
    R.div className: 'app-splash',
      R.div className: 'logo'
      R.div className: 'version', "Version #{@props.version}"
