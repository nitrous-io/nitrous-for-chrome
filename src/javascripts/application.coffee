#= require jquery-2.1.4
#= require react-with-addons-0.13.3
#= require classnames-2.1.3
#= require_self
#= require_tree ./components

window.sleep = (duration) ->
  new Promise (resolve) ->
    window.setTimeout(->
      resolve()
    , duration)

meta = (name) ->
  $("meta[name='#{name}']").eq(0).attr 'content'

window.App =
  name: meta('AppName')
  version: meta('AppVersion')
  host: meta('Host')
  token: null

$ ->
  main = React.createElement App.Main
  React.render main, $('#app')[0]
