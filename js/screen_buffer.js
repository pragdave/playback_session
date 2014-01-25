var ScreenBuffer,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(typeof exports !== "undefined" && exports !== null ? exports : window).ScreenBuffer = ScreenBuffer = (function() {
  var Attrs, Cell;

  ScreenBuffer.Attrs = Attrs = (function() {
    Attrs.prototype.DEFAULT_FG = 7;

    Attrs.prototype.DEFAULT_BG = 0;

    function Attrs() {
      this.reset();
    }

    Attrs.prototype.reset = function() {
      this.fg = this.DEFAULT_FG;
      this.bg = this.DEFAULT_BG;
      this.bold = false;
      this.ul = false;
      return this.inverse = false;
    };

    Attrs.prototype.update_from = function(other) {
      this.fg = other.fg;
      this.bg = other.bg;
      this.bold = other.bold;
      this.ul = other.ul;
      return this.inverse = other.inverse;
    };

    Attrs.prototype.is_equal_to = function(other) {
      return this.eq(other, "fg") && this.eq(other, "bg") && this.eq(other, "bold") && this.eq(other, "ul") && this.eq(other, "inverse");
    };

    Attrs.prototype.eq = function(other, attr) {
      var hers, mine;
      mine = this[attr];
      hers = other[attr];
      if (mine === hers) {
        return true;
      }
      return false;
    };

    return Attrs;

  })();

  ScreenBuffer.Cell = Cell = (function() {
    function Cell(char) {
      this.char = char != null ? char : " ";
      this.attrs = new Attrs();
    }

    return Cell;

  })();

  function ScreenBuffer(_arg) {
    var i;
    this.height = _arg[0], this.width = _arg[1];
    this.scroll_top = 1;
    this.scroll_bottom = this.height;
    this.primary = (function() {
      var _i, _ref, _results;
      _results = [];
      for (i = _i = 1, _ref = this.height; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        _results.push(this.create_line());
      }
      return _results;
    }).call(this);
    this.alternate = (function() {
      var _i, _ref, _results;
      _results = [];
      for (i = _i = 1, _ref = this.height; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        _results.push(this.create_line());
      }
      return _results;
    }).call(this);
    this.lines = this.primary;
    this.reset_dirty();
  }

  ScreenBuffer.prototype.create_line = function() {
    var i, _i, _ref, _results;
    _results = [];
    for (i = _i = 1, _ref = this.width; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      _results.push(new Cell());
    }
    return _results;
  };

  ScreenBuffer.prototype.put = function(chars, attr, line, col) {
    var cell, i, _i, _ref;
    line -= 1;
    col -= 1;
    if (line >= this.scroll_bottom) {
      line = this.scroll_bottom - 1;
      this.scroll_up();
    }
    for (i = _i = 0, _ref = chars.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      cell = this.lines[line][col];
      cell.char = chars.charAt(i);
      cell.attrs.update_from(attr);
      this.dirty_lines[line] = true;
      col += 1;
      if (col >= this.width) {
        col = this.width - 1;
        col = 0;
        line += 1;
      }
    }
    return [line + 1, col + 1];
  };

  ScreenBuffer.prototype.dirty = function(line) {
    return this.dirty_lines[line - 1];
  };

  ScreenBuffer.prototype.scroll_up = function() {
    var i, _i, _j, _ref, _ref1, _ref2, _ref3, _results;
    for (i = _i = _ref = this.scroll_top - 1, _ref1 = this.scroll_bottom - 1; _ref <= _ref1 ? _i < _ref1 : _i > _ref1; i = _ref <= _ref1 ? ++_i : --_i) {
      this.lines[i] = this.lines[i + 1];
    }
    this.lines[this.scroll_bottom - 1] = this.create_line();
    _results = [];
    for (i = _j = _ref2 = this.scroll_top, _ref3 = this.scroll_bottom; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; i = _ref2 <= _ref3 ? ++_j : --_j) {
      _results.push(this.dirty_lines[i - 1] = true);
    }
    return _results;
  };

  ScreenBuffer.prototype.use_primary = function() {
    this.lines = this.primary;
    return this.set_dirty();
  };

  ScreenBuffer.prototype.use_alternate = function() {
    this.lines = this.alternate;
    return this.set_dirty();
  };

  ScreenBuffer.prototype.set_scroll_region = function(scroll_top, scroll_bottom) {
    this.scroll_top = scroll_top;
    this.scroll_bottom = scroll_bottom;
  };

  ScreenBuffer.prototype.insert_lines = function(at_line, count) {
    var line, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results, _results1;
    if (__indexOf.call((function() {
      _results = [];
      for (var _i = _ref = this.scroll_top, _ref1 = this.scroll_bottom; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; _ref <= _ref1 ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this), at_line) < 0) {
      return;
    }
    if (at_line + count > this.scroll_bottom) {
      return this.clear([at_line, 1], [this.scroll_bottom, this.width]);
    } else {
      for (line = _j = _ref2 = this.scroll_bottom, _ref3 = at_line + count; _ref2 <= _ref3 ? _j <= _ref3 : _j >= _ref3; line = _ref2 <= _ref3 ? ++_j : --_j) {
        this.lines[line - 1] = this.lines[line - count - 1];
      }
      for (line = _k = at_line, _ref4 = at_line + count; at_line <= _ref4 ? _k < _ref4 : _k > _ref4; line = at_line <= _ref4 ? ++_k : --_k) {
        this.lines[line - 1] = this.create_line(this.width);
      }
      _results1 = [];
      for (line = _l = at_line, _ref5 = this.scroll_bottom; at_line <= _ref5 ? _l <= _ref5 : _l >= _ref5; line = at_line <= _ref5 ? ++_l : --_l) {
        _results1.push(this.dirty_lines[line - 1] = true);
      }
      return _results1;
    }
  };

  ScreenBuffer.prototype.each = function(_arg, _arg1, callback) {
    var col, end_col, from_col, from_line, line, line_no, start_col, to_col, to_line, _i, _results;
    from_line = _arg[0], from_col = _arg[1];
    to_line = _arg1[0], to_col = _arg1[1];
    from_line -= 1;
    from_col -= 1;
    to_line -= 1;
    to_col -= 1;
    _results = [];
    for (line_no = _i = from_line; from_line <= to_line ? _i <= to_line : _i >= to_line; line_no = from_line <= to_line ? ++_i : --_i) {
      line = this.lines[line_no];
      start_col = (line_no === from_line ? from_col : 0);
      end_col = (line_no === to_line ? to_col : this.width - 1);
      _results.push((function() {
        var _j, _results1;
        _results1 = [];
        for (col = _j = start_col; start_col <= end_col ? _j <= end_col : _j >= end_col; col = start_col <= end_col ? ++_j : --_j) {
          _results1.push(callback(line_no, line[col]));
        }
        return _results1;
      })());
    }
    return _results;
  };

  ScreenBuffer.prototype.for_each_dirty_line = function(callback) {
    var index, line, _i, _len, _ref, _results;
    _ref = this.lines;
    _results = [];
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      line = _ref[index];
      if (this.dirty_lines[index]) {
        _results.push(callback(index + 1, line));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  ScreenBuffer.prototype.fill = function(from, to, char) {
    var _this = this;
    return this.each(from, to, function(line_no, cell) {
      cell.char = char.char;
      cell.attrs.update_from(char.attrs);
      return _this.dirty_lines[line_no] = true;
    });
  };

  ScreenBuffer.prototype.clear = function(from, to) {
    return this.fill(from, to, new Cell());
  };

  ScreenBuffer.prototype.clear_all = function() {
    return this.clear([1, 1], [this.height, this.width]);
  };

  ScreenBuffer.prototype.reset_dirty = function(value) {
    var _;
    if (value == null) {
      value = false;
    }
    return this.dirty_lines = (function() {
      var _i, _len, _ref, _results;
      _ref = this.lines;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ = _ref[_i];
        _results.push(value);
      }
      return _results;
    }).call(this);
  };

  ScreenBuffer.prototype.set_dirty = function() {
    return this.reset_dirty(true);
  };

  ScreenBuffer.prototype.dump_to_console = function() {
    var cell, chars, line, _i, _len, _ref, _results;
    console.log("dump");
    _ref = this.lines;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      chars = (function() {
        var _j, _len1, _results1;
        _results1 = [];
        for (_j = 0, _len1 = line.length; _j < _len1; _j++) {
          cell = line[_j];
          _results1.push(cell.char);
        }
        return _results1;
      })();
      _results.push(console.log("|" + chars.join() + "|"));
    }
    return _results;
  };

  return ScreenBuffer;

})();
