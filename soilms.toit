
import gpio
import gpio.adc
import serial.protocols.i2c as i2c
import i2c

import font show *
import font.x11_100dpi.sans.sans_24_bold as sans_24_bold
import pixel_display show *
import pixel_display.texture show *
import pixel_display.two_color show *

import ssd1306 show *

MOISTURE_SENSOR ::= 32

SCL ::= 22
SDA ::= 21

main:
  // Set up the I2C bus for the OLED display.
  bus := i2c.Bus
      --sda=gpio.Pin SDA
      --scl=gpio.Pin SCL

  devices := bus.scan
  if not devices.contains SSD1306_ID: throw "No SSD1306 display found"

  oled :=
    TwoColorPixelDisplay
      SSD1306 (bus.device SSD1306_ID)

  oled.background = BLACK
  sans := Font.get "sans10"
  sans24b := Font [sans_24_bold.ASCII]
  sans_context := oled.context --landscape --font=sans --color=WHITE //--color=BLACK
  sans24b_context := sans_context.with --font=sans24b --alignment=TEXT_TEXTURE_ALIGN_RIGHT
  oled_text := (oled as any).text sans24b_context 130 55 "0.0" //"oled as any" is a hack

  pin := gpio.Pin MOISTURE_SENSOR
  sensor := adc.Adc pin

  while true:
    val := sensor.get
    per := (-41.66666667*val) + 145.833333334 // Linear conversion to percentage.
    oled.text sans_context 10 20 "Moisture Reading"
    print "Moisture: $(%.2f per) %"
    oled_text.text = "$(%.2f per)%"
    oled.draw
    sleep --ms=500
