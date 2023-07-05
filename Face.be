import math

class Face: lv.canvas
  var buf
  var ofsX, ofsY

  def init(scr, width, height, roundFace, mirrored, font)
    super(self,lv.canvas).init(scr)

    var bufsize = (lv.COLOR_DEPTH / 8) * width * height # 16bit
    self.buf = bytes()
    self.buf.resize(bufsize)
    if size(self.buf) != bufsize
      print(format('Out of memory: Allocated %d of %d bytes for the face buffer',size(self.buf),bufsize))
      return
    end
    self.set_buffer(self.buf, width, height, lv.IMG_CF_TRUE_COLOR)
    self.fill_bg(lv.color(lv.COLOR_BLACK), lv.OPA_COVER)
    self.update_layout()

    self.ofsX = self.get_width() / 2.0
    self.ofsY = self.get_height() / 2.0

    var radius = (width < height ? width : height) / 2.0

    var shortLineLen = self.round(radius / 25.0)
    var shortLineWidth = self.round(radius / 125.0)
    var longLineLen = self.round(radius / 10.0)
    var longLineWidth = self.round(radius / 50.0)
    var digitsOfs = self.round(radius / 4.0)

    var faceRadius = self.round(radius - radius / 50.0)
    var faceWidth = self.round(width / 2.0 - radius / 50.0)
    var faceHeight = self.round(height / 2.0 - radius / 50.0)

    var horOfs = roundFace ? faceRadius : faceHeight
    var verOfs = roundFace ? faceRadius : faceWidth

    var line_dsc = lv.draw_line_dsc()
    lv.draw_line_dsc_init(line_dsc)
    line_dsc.color = lv.color(lv.COLOR_WHITE)

    self.drawLine(line_dsc, 0, -horOfs, 0, longLineLen - horOfs, longLineWidth)
    self.drawLine(line_dsc, 0, horOfs, 0, horOfs - longLineLen, longLineWidth)
    self.drawLine(line_dsc, verOfs, 0, verOfs - longLineLen, 0, longLineWidth)
    self.drawLine(line_dsc, -verOfs, 0, longLineLen - verOfs, 0, longLineWidth)

    if font
      self.drawNumber(0, digitsOfs - horOfs, 12, mirrored, font)
      self.drawNumber(0, horOfs - digitsOfs, 6, mirrored, font)
      self.drawNumber(verOfs - digitsOfs, 0, 3, mirrored, font)
      self.drawNumber(digitsOfs - verOfs, 0, 9, mirrored, font)
    end

    var inc = math.pi / 30.0
    var ang = inc
    for i: 1..14
      var atHour = (i % 5 == 0)
      var lineLen = atHour ? longLineLen : shortLineLen
      var lineWidth = atHour ? longLineWidth : shortLineWidth

      var startPtX, startPtY
      var endPtX, endPtY
      var digitPosX, digitPosY

      if roundFace
        var c = math.cos(ang)
        var s = math.sin(ang)
        startPtX = c * faceRadius
        startPtY = s * faceRadius
        endPtX = c * (faceRadius - lineLen)
        endPtY = s * (faceRadius - lineLen)
        digitPosX = c * (faceRadius - digitsOfs)
        digitPosY = s * (faceRadius - digitsOfs)
      else
        var t = math.tan(ang)
        startPtX = self.intersectX(t, faceWidth, faceHeight)
        startPtY = self.intersectY(t, faceWidth, faceHeight)
        endPtX = self.intersectX(t, faceWidth - lineLen, faceHeight - lineLen)
        endPtY = self.intersectY(t, faceWidth - lineLen, faceHeight - lineLen)
        digitPosX = self.intersectX(t, faceWidth - digitsOfs, faceHeight - digitsOfs)
        digitPosY = self.intersectY(t, faceWidth - digitsOfs, faceHeight - digitsOfs)
      end

      self.drawLine(line_dsc, startPtX, startPtY, endPtX, endPtY, lineWidth)
      self.drawLine(line_dsc, -startPtX, startPtY, -endPtX, endPtY, lineWidth)
      self.drawLine(line_dsc, startPtX, -startPtY, endPtX, -endPtY, lineWidth)
      self.drawLine(line_dsc, -startPtX, -startPtY, -endPtX, -endPtY, lineWidth)

      # print(format("i: %d ang: %f point: %d,%d - %d,%d", i, ang, rightBottomStart.getX(), rightBottomStart.getY(), leftTopStart.getX(), leftTopStart.getY() ))

      if font && atHour
        var hour = i / 5
        self.drawNumber(digitPosX, digitPosY, hour + 3, mirrored, font)
        self.drawNumber(-digitPosX, digitPosY, 9 - hour, mirrored, font)
        self.drawNumber(digitPosX, -digitPosY, 3 - hour, mirrored, font)
        self.drawNumber(-digitPosX, -digitPosY, hour + 9, mirrored, font)
      end
      ang += inc
    end
  end

  static def round(val)
    return real(val) - int(val) > 0.5 ? int(math.ceil(val)) : int(math.floor(val))
  end

  def intersectX(tan, width, height)
    var x = height / tan
    return x > width ? width : x
  end

  def intersectY(tan, width, height)
    var y = width * tan
    return y > height ? height : y
  end

  def point(x, y)
    var p = lv.point()
    p.x = self.round(x + self.ofsX)
    p.y = self.round(y + self.ofsY)
    return p
  end

  def drawLine(dsc, x1, y1, x2, y2, width)
    dsc.width = width < 1 ? 1 : width
    self.draw_line(lv.lv_point_arr([self.point(x1,y1), self.point(x2,y2)]), 2, dsc)
  end

  def drawNumber(x, y, num, mirrored, font)
    var label = lv.label(self)
    label.add_flag(lv.OBJ_FLAG_FLOATING)
    label.align(lv.ALIGN_CENTER, self.round(x), self.round(y))
    if font
      label.set_style_text_font(font, lv.PART_MAIN | lv.STATE_DEFAULT)
    end
    label.set_style_text_color(lv.color(lv.COLOR_WHITE), lv.PART_MAIN | lv.STATE_DEFAULT)
    var txt = str(mirrored ? 12 -num : num)
    if mirrored
      if num == 12 txt = "21" end
      if num == 2 txt = "01" end
    end
    label.set_text(txt)
  end

end

return Face