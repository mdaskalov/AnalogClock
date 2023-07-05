import Face
import Hand
import persist

class AnalogClock
  var face, hour, min, sec
  var millis_adj
  var flip

  def init()
    lv.start()
    var scr = lv.scr_act()

    self.flip = persist.find('clock_mirrored', false) ? -1 : 1
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

    var font = self.load_font(fontName, fontSize)

    var mirrored = self.flip < 0
    self.face = Face(lv.scr_act(), width, height, roundFace, mirrored, font)
    self.hour = Hand(self.face, hmWidth, hRad, hmOfs, false)
    self.min = Hand(self.face, hmWidth, mRad, hmOfs, false)
    self.sec = Hand(self.face, sWidth, sRad, sExt, true)
    self.millis_adj = 0

    self.face.center()

    #self.set_time(10, 10, 0)

    tasmota.add_driver(self)
  end

  def deinit()
    self.del()
  end

  def del()
    tasmota.remove_driver(self)
    if self.face
      self.face.del()
    end
  end

  def load_font(fontName, fontSize)
    var font
    if fontName
      try
        font = lv.load_freetype_font(fontName, fontSize, 0)
      except .. as e, v
        print(format('Freetype font(%s, %d) load failed',fontName, fontSize))
      end
    end
    var montserratSize = 0
    var montserratSizes = [10, 14, 20, 28]
    for i:0..size(montserratSizes)-1
      if montserratSizes[i] <= fontSize
        montserratSize = montserratSizes[i]
      else
        break
      end
    end
    print(format('use montserrat_font(%d)', montserratSize))
    if montserratSize != 0
      font = lv.montserrat_font(montserratSize)
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
