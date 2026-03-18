import math

class Face
  var scr
  var points, lines, labels
  var ofsX, ofsY

  def init(scr, width, height, roundFace, digits, mirrored, font)
    self.scr = scr
    self.points = []
    self.lines = []
    self.labels = []
    self.ofsX = scr.get_width() / 2.0
    self.ofsY = scr.get_height() / 2.0

    var radius = (width < height ? width : height) / 2.0

    var longLineLen = self.round(radius / 4.0)
    var shortLineLen = self.round(longLineLen / 3.0)
    var digitLineLen = self.round(radius / 5.0)
    var longLineWidth = self.round(radius / 50.0)
    var shortLineWidth = self.round(radius / 125.0)
    var digitsOfs = self.round(radius / 3.0)

    var faceRadius = self.round(radius - (radius / 40.0))
    var faceWidth = self.round(width / 2.0 - (radius / 40.0))
    var faceHeight = self.round(height / 2.0 - (radius / 40.0))

    var horOfs = roundFace ? faceRadius : faceHeight
    var verOfs = roundFace ? faceRadius : faceWidth

    self.drawLine(0, -horOfs, 0, (digits > 0 ? digitLineLen : longLineLen) - horOfs, longLineWidth)
    self.drawLine(0, horOfs, 0, horOfs - (digits > 1 ? digitLineLen : longLineLen), longLineWidth)
    self.drawLine(verOfs, 0, verOfs - (digits == 3 || digits > 5 ? digitLineLen : longLineLen), 0, longLineWidth)
    self.drawLine(-verOfs, 0, (digits == 3 || digits > 5 ? digitLineLen : longLineLen) - verOfs, 0, longLineWidth)

    if font
      if digits > 0
        self.drawNumber(0, digitsOfs - horOfs, 12, mirrored, font)
      end
      if digits > 1
        self.drawNumber(0, horOfs - digitsOfs, 6, mirrored, font)
      end
      if digits == 3 || digits > 5
        self.drawNumber(verOfs - digitsOfs, 0, 3, mirrored, font)
        self.drawNumber(digitsOfs - verOfs, 0, 9, mirrored, font)
      end
    end

    var inc = math.pi / 30.0
    var ang = inc
    for i: 1..14
      var hour = i / 5
      var atHour = (i % 5 == 0)
      var withDigit = (hour == 1 && digits > 3) || (hour == 2 && digits > 4)
      var lineLen = atHour ? (withDigit ? digitLineLen : longLineLen) : shortLineLen
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

      self.drawLine(startPtX, startPtY, endPtX, endPtY, lineWidth)
      self.drawLine(-startPtX, startPtY, -endPtX, endPtY, lineWidth)
      self.drawLine(startPtX, -startPtY, endPtX, -endPtY, lineWidth)
      self.drawLine(-startPtX, -startPtY, -endPtX, -endPtY, lineWidth)

      # print(format("i: %d ang: %f point: %d,%d - %d,%d", i, ang, rightBottomStart.getX(), rightBottomStart.getY(), leftTopStart.getX(), leftTopStart.getY() ))

      if font && atHour && withDigit
        self.drawNumber(digitPosX, digitPosY, hour + 3, mirrored, font)   # 4  5
        self.drawNumber(-digitPosX, digitPosY, 9 - hour, mirrored, font)  # 8  7
        self.drawNumber(digitPosX, -digitPosY, 3 - hour, mirrored, font)  # 2  1
        self.drawNumber(-digitPosX, -digitPosY, hour + 9, mirrored, font) # 10 11
      end
      ang += inc
    end
  end

  def deinit()
    self.del()
  end

  def del()
    if self.lines
      for i:0..size(self.lines)-1
        self.lines[i].del()
      end
      self.lines = nil
    end
    if self.labels
      for i:0..size(self.labels)-1
        self.labels[i].del()
      end
      self.labels = nil
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

  def drawLine(x1, y1, x2, y2, width)
    var line = lv.line(self.scr)
    var p1 = lv.point()
    p1.x = self.round(x1 + self.ofsX)
    p1.y = self.round(y1 + self.ofsY)
    var p2 = lv.point()
    p2.x = self.round(x2 + self.ofsX)
    p2.y = self.round(y2 + self.ofsY)
    var pa = lv.lv_point_arr([p1, p2])
    self.points.push(pa)
    line.set_style_line_width(width < 1 ? 1 : width, lv.PART_MAIN | lv.STATE_DEFAULT)
    line.set_style_line_color(lv.color(lv.COLOR_WHITE), lv.PART_MAIN | lv.STATE_DEFAULT)
    line.set_points(pa, 2)
    self.lines.push(line)
  end

  def drawNumber(x, y, num, mirrored, font)
    var label = lv.label(self.scr)
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
    self.labels.push(label)
  end

end

return Face