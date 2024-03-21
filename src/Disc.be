class Disc : lv.obj
  var area, arc_dsc       # instances of objects kept to avoid re-instanciating at each call

  def init(parent)
    super(self).init(parent)

    self.remove_flag(lv.OBJ_FLAG_CLICKABLE)

    self.set_style_bg_opa(0, 0)         # transparent background
    self.set_style_border_width(0, 0)   # remove border
    self.set_style_pad_all(0,0)

    self.area = lv.area()
    self.arc_dsc = lv.draw_arc_dsc()

    self.add_event_cb(self.widget_event, lv.EVENT_DRAW_MAIN, 0)
  end

  def widget_event(event)
    var code = event.get_code()

    var height = self.get_height()
    var width = self.get_width()
    var radius = ((width < height) ? width : height) / 2

    if code == lv.EVENT_DRAW_MAIN
      var arc_dsc = self.arc_dsc
      self.get_coords(self.area)
      lv.draw_arc_dsc_init(arc_dsc)
      self.init_draw_arc_dsc(lv.PART_MAIN, arc_dsc)
      arc_dsc.center_x = self.area.x1 + width / 2
      arc_dsc.center_y =self.area.y1 + height / 2
      arc_dsc.start_angle = 0
      arc_dsc.end_angle = 360
      arc_dsc.color = self.get_style_line_color(lv.PART_MAIN | lv.STATE_DEFAULT)
      arc_dsc.rounded = 1
      arc_dsc.radius = radius
      arc_dsc.width = radius
      lv.draw_arc(event.get_layer(), arc_dsc)
    end
  end

end

return Disc
