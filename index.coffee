five = require("johnny-five")
board = new five.Board()
board.on "ready", ->

  # Create an Led on pin 13
  led = new five.Led(13)

  # Strobe the pin on/off, defaults to 100ms phases
  led.strobe()
  return
