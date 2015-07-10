R = React.DOM

App.Splash = React.createClass
  getDefaultProps: ->
    version: '0.0.0'

  render: ->
    R.div className: 'app-splash',
      R.div className: 'logo'
      R.div className: 'version', "Version #{@props.version}"
