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

  wheels.stop()
  console.log "Use the cursor keys or ASWD to move your bot. Hit escape or the spacebar to stop."
  stdin.on "keypress", (chunk, key) ->
    return  unless key
    switch key.name
      when "up", "w"
        wheels.forward()
      when "down", "s"
        wheels.back()
      when "left", "a"
        wheels.pivotLeft()
      when "right", "d"
        wheels.pivotRight()
      when "space", "escape"
        wheels.stop()

  return
