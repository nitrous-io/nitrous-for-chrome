#= require ./polyfill
#= require jquery-2.1.4
#= require jquery-ajax-native-1.0.1
#= require react-with-addons-0.13.3
#= require timeout-transition-group-d7afd09
#= require pubsub-1.5.2
#= require classnames-2.1.3
#= require_self
#= require_tree ./models
#= require_tree ./mixins
#= require_tree ./components

window.sleep = (duration) ->
  new Promise (resolve) ->
    window.setTimeout(->
      resolve()
    , duration)

# coffeescript getter/setter support - http://bl.ocks.org/joyrexus/65cb3780a24ecd50f6df
Function::getter = (prop, get) ->
  Object.defineProperty @prototype, prop, {get, configurable: yes}

Function::setter = (prop, set) ->
  Object.defineProperty @prototype, prop, {set, configurable: yes}

meta = (name) ->
  $("meta[name='#{name}']").eq(0).attr 'content'

window.App =
  name: meta('AppName')
  version: meta('AppVersion')
  host: meta('Host')
  helpUrl: meta('HelpUrl')
  token: null
  user: null

  injectJS: (webview, js, cb) ->
    webview.executeScript(code: """
      s = document.createElement('script');
      s.innerHTML = "#{js.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n')}";
      document.body.appendChild(s);
      s.parentNode.removeChild(s);
    """, cb)

$ ->
  main = React.createElement App.Main
  React.render main, $('#app')[0]
