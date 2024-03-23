import math

class Hand: lv.obj
  var area, line_dsc, arc_dsc

  # preset
  var line_cap
  var center_rad
  var hand_rad
  var ofs_rad
  var thick_width, thin_width
  var for_sec

  # calculated (ang)
  var hand_x, hand_y
  var ofs_x, ofs_y
  var pos_x, pos_y

  def init(parent, width, radius, ofs, for_sec)
    super(self).init(parent)

    self.center_rad = self.round(width / 2.0)
    self.hand_rad = radius
    self.ofs_rad = ofs

    self.line_cap = width

    self.thick_width = width < 1 ? 1 : width
    self.thin_width = self.round(width / (for_sec ? 3.0 : 4.0))

    if self.thin_width < 1
      self.thin_width = 1
    end

    self.for_sec = for_sec

    self.remove_flag(lv.OBJ_FLAG_CLICKABLE)
    self.remove_flag(lv.OBJ_FLAG_SCROLLABLE)
    self.add_flag(lv.OBJ_FLAG_FLOATING)

    self.pos_x = parent.get_width() / 2
    self.pos_y = parent.get_height() / 2

    self.set_angle(0)

    self.set_style_bg_opa(0, 0)
    self.set_style_border_width(0, 0)

    self.area = lv.area()

    self.line_dsc = lv.draw_line_dsc()
    lv.draw_line_dsc_init(self.line_dsc)
    self.init_draw_line_dsc(lv.PART_MAIN, self.line_dsc)

    self.arc_dsc = lv.draw_arc_dsc()
    lv.draw_arc_dsc_init(self.arc_dsc)
    self.init_draw_arc_dsc(lv.PART_MAIN, self.arc_dsc)

    self.add_event_cb(self.widget_event, lv.EVENT_DRAW_MAIN, 0)
  end

  def widget_event(event)
    if event.get_code() == lv.EVENT_DRAW_MAIN
      var arc_dsc = self.arc_dsc
      var line_dsc = self.line_dsc

      var layer = event.get_layer()

      self.get_coords(self.area)

      var center_x = self.hand_x < 0 ? self.area.x2 - self.line_cap : self.area.x1 + self.line_cap
      var center_y = self.hand_y < 0 ? self.area.y2 - self.line_cap : self.area.y1 + self.line_cap

      arc_dsc.center_x = center_x + (self.for_sec ? self.ofs_x : 0)
      arc_dsc.center_y = center_y + (self.for_sec ? self.ofs_y : 0)
      arc_dsc.start_angle = 0
      arc_dsc.end_angle = 360
      arc_dsc.radius = self.center_rad
      arc_dsc.width = self.center_rad
      arc_dsc.color = self.get_style_line_color(lv.PART_MAIN | lv.STATE_DEFAULT)
      lv.draw_arc(layer, arc_dsc)

      line_dsc.color = self.get_style_line_color(lv.PART_MAIN | lv.STATE_DEFAULT)

      if self.for_sec
        line_dsc.width = self.thin_width
        line_dsc.p1_x = center_x
        line_dsc.p1_y = center_y
        line_dsc.p2_x = center_x + self.hand_x + self.ofs_x
        line_dsc.p2_y = center_y + self.hand_y + self.ofs_y
        lv.draw_line(layer, line_dsc);
      else
        line_dsc.round_start = true
        line_dsc.round_end = true
        line_dsc.width = self.thin_width
        line_dsc.p1_x = center_x
        line_dsc.p1_y = center_y
        line_dsc.p2_x = center_x + self.ofs_x
        line_dsc.p2_y = center_y + self.ofs_y
        lv.draw_line(layer, line_dsc);
        line_dsc.width = self.thick_width
        line_dsc.p1_x += self.hand_x
        line_dsc.p1_y += self.hand_y
        lv.draw_line(layer, line_dsc);
      end

    end
  end

  def round(val)
    return real(val) - int(val) > 0.5 ? int(math.ceil(val)) : int(math.floor(val))
  end

  def set_angle(ang)
    var rad = ang * 2 * math.pi / 360.0
    var sin = math.sin(rad)
    var cos = -math.cos(rad)

    self.ofs_x = self.round(self.ofs_rad * sin)
    self.ofs_y = self.round(self.ofs_rad * cos)
    self.hand_x = self.round(self.hand_rad * sin)
    self.hand_y = self.round(self.hand_rad * cos)

    var for_sec_x = self.for_sec ? self.ofs_x : 0
    var for_sec_y = self.for_sec ? self.ofs_y : 0

    var pos_x = self.pos_x - self.line_cap - for_sec_x
    var pos_y = self.pos_y - self.line_cap - for_sec_y
    var w = self.hand_x + for_sec_x
    var h = self.hand_y + for_sec_y

    if self.hand_x < 0
      pos_x += self.hand_x + for_sec_x
      w = -w
    end
    if self.hand_y < 0
      pos_y += self.hand_y + for_sec_y
      h = -h
    end

    h += 2 * self.line_cap + 1
    w += 2 * self.line_cap + 1

    if h < self.thick_width h = self.thick_width end
    if w < self.thick_width w = self.thick_width end

    self.set_pos(pos_x, pos_y)
    self.set_size(w, h)
    # self.refresh_self_size();
    self.invalidate()
  end

end

return Hand
