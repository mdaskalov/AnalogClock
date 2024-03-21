import math
import Disc

class Hand
  var center, ofs, hand
  var line_center, line_ofs, line_hand
  var disc
  var sec_hand

  var rad_hand, rad_ofs

  def init(parent, side, radius, ofs, sec_hand)
    var sin = math.sin(0.5)
    var cos = -math.cos(0.5)

    var rad = self.round(side / 2.0)
    var thick_width = side < 1 ? 1 : side
    var thin_width = self.round(side / (sec_hand ? 3.0 : 4.0))
    var line_cap = sec_hand ? self.round(side / 6.0) : rad

    if thin_width < 1
      thin_width = 1
    end

    self.center = lv.point()
    self.center.x = parent.get_width() / 2
    self.center.y = parent.get_height() / 2

    self.ofs = lv.point()
    self.hand = lv.point()
    self.line_ofs = lv.line(parent)
    self.line_hand = lv.line(parent)
    self.disc = Disc(parent)
    self.disc.set_width(side)
    self.disc.set_height(side)
    self.disc.center()

    self.sec_hand = sec_hand

    if self.sec_hand
      self.rad_hand = radius - line_cap
      self.rad_ofs = line_cap - ofs
      self.hand.x = self.center.x + self.round(self.rad_hand * sin)
      self.hand.y = self.center.y + self.round(self.rad_hand * cos)
      self.ofs.x = self.center.x  + self.round(self.rad_ofs * sin)
      self.ofs.y = self.center.y + self.round(self.rad_ofs * cos)
      self.line_hand.set_style_line_width(thin_width, lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_hand.set_style_line_color(lv.color(lv.COLOR_RED), lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_hand.set_style_line_rounded(true, lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_hand.set_points(lv.point_arr([self.ofs, self.hand]),2)
      self.disc.set_style_line_color(lv.color(lv.COLOR_RED), lv.PART_MAIN | lv.STATE_DEFAULT)
    else
      self.rad_hand = radius - line_cap
      self.rad_ofs = ofs + line_cap
      self.hand.x = self.center.x + self.round(self.rad_hand * sin)
      self.hand.y = self.center.y + self.round(self.rad_hand * cos)
      self.ofs.x = self.center.x + self.round(self.rad_ofs * sin)
      self.ofs.y = self.center.y + self.round(self.rad_ofs * cos)
      self.line_ofs.set_style_line_width(thin_width, lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_ofs.set_style_line_color(lv.color(lv.COLOR_WHITE), lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_ofs.set_style_line_rounded(true, lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_ofs.set_points(lv.point_arr([self.center, self.ofs]),2)
      self.line_hand.set_style_line_width(thick_width, lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_hand.set_style_line_color(lv.color(lv.COLOR_WHITE), lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_hand.set_style_line_rounded(true, lv.PART_MAIN | lv.STATE_DEFAULT)
      self.line_hand.set_points(lv.point_arr([self.ofs, self.hand]),2)
      self.disc.set_style_line_color(lv.color(lv.COLOR_WHITE), lv.PART_MAIN | lv.STATE_DEFAULT)
    end
  end

  def deinit()
    self.del()
  end

  def del()
    tasmota.remove_driver(self)
    if self.line_ofs self.line_ofs.del() end
    if self.line_hand self.line_hand.del() end
    if self.disc self.disc.del() end
  end

  def round(val)
    return real(val) - int(val) > 0.5 ? int(math.ceil(val)) : int(math.floor(val))
  end

  def set_angle(ang)
    var rad = ang * 2 * math.pi / 360.0
    var sin = math.sin(rad)
    var cos = -math.cos(rad)
    if self.center && self.hand && self.ofs && self.line_hand && self.line_ofs
      self.hand.x = self.center.x + self.round(self.rad_hand * sin)
      self.hand.y = self.center.y + self.round(self.rad_hand * cos)
      self.ofs.x = self.center.x  + self.round(self.rad_ofs * sin)
      self.ofs.y = self.center.y + self.round(self.rad_ofs * cos)
      self.line_hand.set_points(lv.point_arr([self.ofs, self.hand]),2)
      if !self.sec_hand
        self.line_ofs.set_points(lv.point_arr([self.center, self.ofs]),2)
      end
    end
  end

end

return Hand
