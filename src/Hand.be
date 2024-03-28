import math

class Hand: lv.canvas
  var buf

  def init(scr, width, hand_rad, ofs_rad, for_sec)
    super(self,lv.canvas).init(scr)

    var center_rad = width / 2
    var line_cap = width
    var thick_width = width < 1 ? 1 : width
    var thin_width = width / (for_sec ? 3 : 4)
    if thin_width < 1 thin_width = 1 end

    var height = line_cap + hand_rad + (for_sec ? ofs_rad : 0) + line_cap

    var cf = lv.COLOR_FORMAT_ARGB8888
    var bufsize = lv.color_format_get_size(cf) * width * height
    self.buf = bytes()
    self.buf.resize(bufsize)
    if size(self.buf) != bufsize
      print(f"Out of memory: Allocated {size(self.buf)} of {bufsize} bytes for the canvas buffer")
      return
    end
    self.set_buffer(self.buf, width, height, cf)

    var center_x = center_rad
    var center_y = hand_rad + line_cap

    var color = lv.color(for_sec ? lv.COLOR_RED : lv.COLOR_WHITE)

    var layer = lv.draw_layer_create(nil, cf, lv.area())
    self.init_layer(layer)

    # center
    var arc_dsc = lv.draw_arc_dsc()
    lv.draw_arc_dsc_init(arc_dsc)
    arc_dsc.color = color
    arc_dsc.width = center_rad;
    arc_dsc.center_x = center_x
    arc_dsc.center_y = center_y
    arc_dsc.start_angle = 0
    arc_dsc.end_angle = 360
    arc_dsc.radius = center_rad
    lv.draw_arc(layer, arc_dsc)

    # hand
    var line_dsc = lv.draw_line_dsc()
    lv.draw_line_dsc_init(line_dsc);
    line_dsc.color = color
    line_dsc.round_start = true
    line_dsc.round_end = true
    line_dsc.p1_x = center_x
    line_dsc.p1_y = line_cap
    line_dsc.p2_x = center_x
    line_dsc.p2_y = line_cap + hand_rad + (for_sec ? ofs_rad : -ofs_rad)

    if for_sec
      line_dsc.width = thin_width
      lv.draw_line(layer, line_dsc);
    else
      line_dsc.width = width
      lv.draw_line(layer, line_dsc);
      line_dsc.width = thin_width
      line_dsc.p1_x = center_x
      line_dsc.p1_y = center_y
      lv.draw_line(layer, line_dsc);
    end

    self.finish_layer(layer)

    var pos_x = scr.get_width() / 2 - center_x
    var pos_y = scr.get_height() / 2 - center_y
    self.set_pos(pos_x, pos_y)
    self.set_pivot(center_x, center_y)
    self.set_antialias(true)
  end

end

return Hand
