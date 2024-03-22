import math

class Hand: lv.canvas
  var buf
  var rad, width, ofs
  var thinLineWidth, line_cap, height, radius, secHand

  def init(scr, width, radius, ofs, secHand)
    super(self,lv.canvas).init(scr)

    self.rad = self.round(width / 2.0)
    self.width = width
    self.ofs = ofs
    self.thinLineWidth = self.round(width / (secHand ? 3.0 : 4.0))
    self.line_cap = secHand ? self.round(width / 6.0) : self.rad

    self.height = self.line_cap + radius + (secHand ? ofs : 0) + self.line_cap
    self.radius = ((width < self.height) ? width : self.height) / 2

    self.secHand = secHand

    var bufsize = ((lv.COLOR_DEPTH / 8) + 1) * width * self.height # LV_IMG_PX_SIZE_ALPHA_BYTE * w * h
    self.buf = bytes()
    self.buf.resize(bufsize)
    if size(self.buf) != bufsize
      print(format('Out of memory: Allocated %d of %d bytes for the face buffer',size(self.buf),bufsize))
      return
    end
    self.set_buffer(self.buf, width, self.height, lv.COLOR_FORMAT_RAW)
    self.fill_bg(lv.color(lv.COLOR_BLACK), lv.OPA_TRANSP)
  end

  def widget_event(event)
    var rad = self.rad
    var width = self.width
    var ofs = self.ofs
    var thinLineWidth = self.thinLineWidth
    var line_cap = self.line_cap
    var height = self.height
    var radius = self.radius
    var secHand = self.secHand

    var code = event.get_code()
    if code == lv.EVENT_DRAW_MAIN
      var centerX = rad
      var centerY = radius + line_cap
      var posX = self.round(self.get_width() / 2.0) - centerX
      var posY = self.round(self.get_height() / 2.0) - centerY
      self.set_pos(posX, posY)
      self.set_pivot(centerX, centerY)
      self.set_antialias(true)

      var color = lv.color(secHand ? lv.COLOR_RED : lv.COLOR_WHITE)

      # center
      var arc_dsc = lv.draw_arc_dsc()
      lv.draw_arc_dsc_init(arc_dsc)
      arc_dsc.color = color
      arc_dsc.width = rad;
      #self.draw_arc(centerX, centerY, rad, 0, 360, arc_dsc)

      var line_dsc = lv.draw_line_dsc()
      lv.draw_line_dsc_init(line_dsc);
      line_dsc.color = color
      line_dsc.round_start = true
      line_dsc.round_end = true

      var p1 = lv.point()
      p1.x = centerX
      p1.y = line_cap
      var p2 = lv.point()
      p2.x = centerX
      p2.y = line_cap + radius + (secHand ? ofs : -ofs)
      var c = lv.point()
      c.x = centerX
      c.y = centerY

      if thinLineWidth < 1
        thinLineWidth = 1
      end

      if width < 1
        width = 1
      end

      if secHand
        line_dsc.width = thinLineWidth
        #self.draw_line(lv.lv_point_arr([p1, p2]), 2, line_dsc);
      else
        line_dsc.width = width
        #self.draw_line(lv.lv_point_arr([p1, p2]), 2, line_dsc);
        line_dsc.width = thinLineWidth
        #self.draw_line(lv.lv_point_arr([p2, c]), 2, line_dsc);
      end
    end
  end

  def round(val)
    return real(val) - int(val) > 0.5 ? int(math.ceil(val)) : int(math.floor(val))
  end

end

h = Hand(lv.scr_act(), 8, 140, 15, true)