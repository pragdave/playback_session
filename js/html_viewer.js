var HtmlViewer,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

(typeof exports !== "undefined" && exports !== null ? exports : window).HtmlViewer = HtmlViewer = (function() {
  HtmlViewer.prototype.EMPTY_ATTR = new ScreenBuffer.Attrs;

  function HtmlViewer(playback_window, screen_buffer) {
    var and_then, char, line,
      _this = this;
    this.playback_window = playback_window;
    this.screen_buffer = screen_buffer;
    this.update_line = __bind(this.update_line, this);
    this.dom = $("<pre class=\"terminal\"></pre>");
    char = $('<pre><span id="wibble">M</span></pre>');
    this.lines = (function() {
      var _i, _ref, _results;
      _results = [];
      for (line = _i = 1, _ref = this.screen_buffer.height; 1 <= _ref ? _i <= _ref : _i >= _ref; line = 1 <= _ref ? ++_i : --_i) {
        _results.push($("<pre>&nbsp;</pre>"));
      }
      return _results;
    }).call(this);
    this.dom.append(this.lines);
    this.dom.append(char);
    this.playback_window.prepend(this.dom);
    and_then = function() {
      var width;
      width = $("#wibble").width();
      _this.playback_window.css('width', (width * _this.screen_buffer.width + 48) + 'px');
      char.remove();
      return _this.update();
    };
    setTimeout(and_then, 0);
  }

  HtmlViewer.prototype.update = function() {
    return this.screen_buffer.for_each_dirty_line(this.update_line);
  };

  HtmlViewer.prototype.update_line = function(line_number, line) {
    var dom_line;
    dom_line = this.lines[line_number - 1];
    return dom_line.html(this.html_from(line));
  };

  HtmlViewer.prototype.html_from = function(line) {
    var attr, cell, result, _i, _len;
    attr = new ScreenBuffer.Attrs;
    result = ["<span>"];
    for (_i = 0, _len = line.length; _i < _len; _i++) {
      cell = line[_i];
      this.add_attributes(result, attr, cell.attrs);
      result.push(this.escape(cell.char));
      attr = cell.attrs;
    }
    result.push("</span>");
    return result.join("");
  };

  HtmlViewer.prototype.escape = function(char) {
    switch (char) {
      case "<":
        return "&lt;";
      case "&":
        return "&amp;";
      default:
        return char;
    }
  };

  HtmlViewer.prototype.add_attributes = function(result, from, to) {
    var b, css_attrs, f, _ref;
    if (from.is_equal_to(to)) {
      return;
    }
    result.push("</span>");
    css_attrs = [];
    if (to.bold) {
      css_attrs.push("b_");
    }
    if (to.ul) {
      css_attrs.push("u_");
    }
    _ref = to.inverse ? [to.bg, to.fg] : [to.fg, to.bg], f = _ref[0], b = _ref[1];
    css_attrs.push("f" + f + "_");
    css_attrs.push("b" + b + "_");
    return result.push("<span class=\"" + (css_attrs.join(' ')) + "\">");
  };

  return HtmlViewer;

})();
