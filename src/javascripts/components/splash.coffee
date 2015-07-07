R = React.DOM

App.Splash = React.createClass
  getDefaultProps: ->
    version: '0.0.0'

  getInitialState: ->
    show: false

  render: ->
    R.div className: classNames('app-splash', show: @state.show),
      R.div className: 'logo'
      R.div className: 'version', "Version #{@props.version}"
