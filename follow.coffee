five = require("johnny-five")
board = new five.Board()
stdin = process.stdin
stdin.setRawMode true
stdin.resume()
board.on "ready", ->
  wheels =
    left: new five.Servo(
      pin: 9
      type: "continuous"
    )
    right: new five.Servo(
      pin: 10
      type: "continuous"
    )
    stop: ->
      wheels.left.center()
      wheels.right.center()
      return

    back: ->
      wheels.left.ccw()
      wheels.right.cw()
      console.log "goForward"
      return

    pivotLeft: ->
      wheels.left.cw()
      wheels.right.cw()
      console.log "turnLeft"
      return

    pivotRight: ->
      wheels.left.ccw()
      wheels.right.ccw()
      console.log "turnRight"
      return

    forward: ->
      wheels.left.cw()
      wheels.right.ccw()
      return


  eyes = new five.IR.Reflect.Array(
    emitter: 13
    pins: [
      "A0"
      "A1"
      "A2"
      "A3"
      "A4"
      "A5"
    ]
  )
  calibrating = true
  running = false
  wheels.stop()

  # Start calibration
  # All sensors need to see the extremes so they can understand what a line is,
  # so move the eyes over the materials that represent lines and not lines during calibration.
  eyes.calibrateUntil ->
    not calibrating

  console.log "Press the spacebar to end calibration and start running..."
  stdin.on "keypress", (chunk, key) ->
    return  if not key or key.name isnt "space"
    calibrating = false
    running = not running
    unless running
      wheels.stop()
      console.log "Stopped running. Press the spacebar to start again..."
    return

  eyes.on "line", (err, line) ->
    return  unless running
    if line < 2100
      wheels.pivotLeft()
    else if line > 3500
      wheels.pivotRight()
    else
      wheels.forward()
    console.log line
    return

  eyes.enable()
  return
