five = require("johnny-five")
fs = require("fs")
_ = require("lodash")
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

  calibrationFile = "calibration.json"

  init = ->
    eyes.enable()
    wheels.stop()
    calibrate(drive)

  calibrate = (callback) ->
    savedCalibration = undefined
    calibrating = true
    if fs.existsSync(calibrationFile)
      eyes.loadCalibration JSON.parse(fs.readFileSync(calibrationFile))
      console.log "Loaded calibration file. Press any key to begin..."
    else
      console.log "Calibrating.  Press any key when finished..."
      eyes.calibrateUntil ->
        not calibrating

    stdin.once "keypress", ->
      calibrating = false
      console.log "Go!"
      fs.writeFile calibrationFile, JSON.stringify(eyes.calibration)
      callback()
      return
    return

  drive = ->
    running = true
    lastLineTime = Date.now()

    onLine = ->
      now = Date.now()
      if now - lastLineTime >= 1000
        running = false
        wheels.stop()
      else
        lastLineTime = now

    stdin.on "keypress", (chunk, key) ->
      return if not key or key.name isnt "space"
      calibrating = false
      running = not running
      lastLineTime = Date.now()
      unless running
        wheels.stop()
        console.log "Stopped running. Press the spacebar to start again..."
      return

    eyes.on "data", (err, data) ->
      maxes = eyes.calibration.max
      sensorsOnLine = _.filter(data, (sensor, i) ->
        sensor > maxes[i] - 100
      )
      if sensorsOnLine.length == maxes.length
        onLine()

    eyes.on "line", (err, line) ->
      return  unless running
      if line < 2100
        wheels.pivotLeft()
      else if line > 3100
        wheels.pivotRight()
      else
        wheels.forward()
      stopAtNextLine = true
      return


  init()
  return
