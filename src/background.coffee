chrome.app.runtime.onLaunched.addListener ->
  chrome.app.window.create 'index.html',
    bounds:
      width: 1150
      height: 650
      left: 0
      top: 0
    frame: 'none'
    minWidth: 800
    minHeight: 600
