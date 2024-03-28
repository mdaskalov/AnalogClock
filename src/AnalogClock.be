import Face
import Hand
import persist
import math

class AnalogClock
  var face, h_hand, m_hand, s_hand
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
    self.h_hand = Hand(scr, hmWidth, hRad, hmOfs, false)
    self.m_hand = Hand(scr, hmWidth, mRad, hmOfs, false)
    self.s_hand = Hand(scr, sWidth, sRad, sExt, true)
    self.millis_adj = 0
    self.flip = mirrored ? -1 : 1

    tasmota.add_driver(self)
  end

  def deinit()
    self.del()
  end

  def del()
    tasmota.remove_driver(self)
    if self.s_hand self.s_hand.del() end
    if self.m_hand self.m_hand.del() end
    if self.h_hand self.h_hand.del() end
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
    if font != nil
      return font
    end
    self.flip = 1
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

  def every_second()
    var rtc = tasmota.rtc()['local']
    var now = tasmota.time_dump(rtc)
    var hour = now['hour']
    var min = now['min']
    var sec = now['sec']
    self.millis_adj = tasmota.millis() % 60000 - sec * 1000
    # 3600/12h + 3600/12/60m + 3600/12/60/60s + 3600/12/60/60/1000ms
    var h_ang = (hour % 12) * 300 + min * 5  + sec / 12
    # 3600/60m + 3600/60/60s + 3600/60/60/1000ms
    var m_ang = min * 60 + sec
    self.h_hand.set_angle(h_ang * self.flip)
    self.m_hand.set_angle(m_ang * self.flip)
  end

  def every_50ms()
    var millis = tasmota.millis() % 60000 - self.millis_adj
    # 3600/60s + 3600/60/1000ms
    var s_ang = millis * 6 / 100
    self.s_hand.set_angle(s_ang * self.flip)
  end

end

return AnalogClock
