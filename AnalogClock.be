import Face
import Hand
import persist
import math

class AnalogClock
  var face, hour, min, sec
  var millis_adj
  var flip

  def init()
    lv.start()
    var scr = lv.scr_act()

    var mirrored = persist.find('clock_mirrored', false)
    var fontName = persist.find('clock_font')
    var roundFace = persist.find('clock_round_face', false)
    var width = persist.find('clock_width', scr.get_width())
    var height = persist.find('clock_height', scr.get_height())

    var radius = (width < height ? width : height) / 2.0

    var mRad = Face.round(radius - (radius / 8.0))
    var hRad = Face.round(mRad * 3.0 / 5.0)
    var hmWidth = Face.round(radius / 15.0)
    var hmOfs = Face.round(radius / 6.0)
    var sRad = Face.round(radius - (radius / 20.0))
    var sWidth = Face.round(radius / 20.0)
    var sExt = Face.round(radius / 6.0)
    var fontSize = Face.round(radius / 6.0)

    var font = self.load_font(fontName, fontSize, lv.montserrat_font)

    self.face = Face(scr, width, height, roundFace, mirrored, font)
    self.hour = Hand(scr, hmWidth, hRad, hmOfs, false)
    self.min = Hand(scr, hmWidth, mRad, hmOfs, false)
    self.sec = Hand(scr, sWidth, sRad, sExt, true)
    self.millis_adj = 0
    self.flip = mirrored ? -1 : 1

    tasmota.add_driver(self)
  end

  def deinit()
    self.del()
  end

  def del()
    tasmota.remove_driver(self)
    if self.sec self.sec.del() end
    if self.min self.min.del() end
    if self.hour self.hour.del() end
    if self.face self.face.del() end
  end

  def load_font(fontName, fontSize, fallbackFont)
    var font
    if fontName
      try
        font = lv.load_freetype_font(fontName, fontSize, 0)
      except .. as e, v
        print(format('Freetype font(%s, %d) unavailable', fontName, fontSize))
      end
    end
    var fallbackSize = fontSize
    while fallbackSize > 0
      try
        font = fallbackFont(fallbackSize)
        print(format('Using fallbackFont(%d)', fallbackSize))
        break
      except .. as e, v
      end
      fallbackSize -= 1
    end
    return font
  end

  def set_time(hour, min, sec)
    self.millis_adj = tasmota.millis() % 60000 - sec * 1000
    var min_ang = 60 * min + sec
    var hour_ang = 300 * (hour % 12) + min * 5 + sec / 12
    self.min.set_angle(min_ang * self.flip)
    self.hour.set_angle(hour_ang * self.flip)
  end

  def every_second()
    var rtc = tasmota.rtc()['local']
    var now = tasmota.time_dump(rtc)
    self.set_time(now['hour'], now['min'], now['sec'])
  end

  def every_50ms()
    var millis = tasmota.millis() % 60000 - self.millis_adj
    var sec_ang = 60 * millis / 1000
    self.sec.set_angle(sec_ang * self.flip)
  end

end

return AnalogClock
