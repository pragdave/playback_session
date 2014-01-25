var Emulator,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

(typeof exports !== "undefined" && exports !== null ? exports : window).Emulator = Emulator = (function() {
  function Emulator(dom_terminal, sb, html) {
    var _ref;
    this.dom_terminal = dom_terminal;
    this.sb = sb;
    this.html = html;
    _ref = this.primary_cursor = [1, 1], this.line = _ref[0], this.col = _ref[1];
    this.alternate_cursor = [1, 1];
    this.use_primary_cursor();
    this.attr = new ScreenBuffer.Attrs();
  }

  Emulator.prototype.update = function() {
    return this.html.update();
  };

  Emulator.prototype.echo_char = function(char, args) {
    var _ref;
    return _ref = this.sb.put(char, this.attr, this.line, this.col), this.line = _ref[0], this.col = _ref[1], _ref;
  };

  Emulator.prototype.bs = function(_char, _args) {
    this.col -= 1;
    return this.normalize_col();
  };

  Emulator.prototype.cr = function(_char, _args) {
    return this.col = 1;
  };

  Emulator.prototype.nl = function(_char, _args) {
    return this.newline(1);
  };

  Emulator.prototype.ht = function(_char, _args) {
    this.col = 8 * (((this.col - 1) / 8) >> 0) + 9;
    return this.normalize_col();
  };

  Emulator.prototype.ich = function(_char, args) {
    var count,
      _this = this;
    count = args[0] || 1;
    this.preserve_cursor(function() {
      var i, _i, _results;
      _results = [];
      for (i = _i = 1; 1 <= count ? _i <= count : _i >= count; i = 1 <= count ? ++_i : --_i) {
        _results.push(_this.echo_char(" ", _this.attr));
      }
      return _results;
    });
    return this.update();
  };

  Emulator.prototype.cuu = function(_char, args) {
    this.line -= args[0] || 1;
    return this.normalize_line();
  };

  Emulator.prototype.cud = function(_char, args) {
    return this.newline(args[0] || 1);
  };

  Emulator.prototype.cuf = function(_char, args) {
    this.col += args[0] || 1;
    return this.normalize_col();
  };

  Emulator.prototype.cub = function(_char, args) {
    this.col -= args[0] || 1;
    return this.normalize_col();
  };

  Emulator.prototype.cnl = function(char, args) {
    this.col = 1;
    return this.cud(char, args);
  };

  Emulator.prototype.cpl = function(char, args) {
    this.col = 1;
    return this.cuu(char, args);
  };

  Emulator.prototype.cha = function(_char, args) {
    this.col = args[0] || this.col;
    return this.normalize_col();
  };

  Emulator.prototype.cup = function(_char, args) {
    this.line = args[0] || 1;
    this.col = args[1] || 1;
    this.normalize_line();
    return this.normalize_col();
  };

  Emulator.prototype.vpa = function(_char, args) {
    this.line = args[0] || 1;
    return this.normalize_line;
  };

  Emulator.prototype.ed = function(_char, args) {
    var arg;
    arg = args[0] || 0;
    if (arg === 0) {
      this.sb.clear([this.line, this.col], [this.sb.height, this.sb.width]);
    } else if (arg === 1) {
      this.sb.clear([1, 1], [this.line, this.col]);
    } else {
      this.sb.clear([1, 1], [this.sb.height, this.sb.width]);
    }
    return this.update();
  };

  Emulator.prototype.el = function(_char, args) {
    var arg;
    arg = args[0] || 0;
    if (arg === 0) {
      this.sb.clear([this.line, this.col], [this.line, this.sb.width]);
    } else if (arg === 1) {
      this.sb.clear([this.line, 1], [this.line, this.col]);
    } else {
      this.sb.clear([this.line, 1], [this.line, this.sb.width]);
    }
    return this.update();
  };

  Emulator.prototype.il = function(_char, args) {
    var count;
    count = args[0] || 1;
    this.sb.insert_lines(this.line, count);
    this.col = 0;
    return this.update();
  };

  Emulator.prototype.su = function(_char, args) {
    return console.log("su(" + args + ")");
  };

  Emulator.prototype.sd = function(_char, args) {
    return console.log("sd(" + args + ")");
  };

  Emulator.prototype.sgr = function(_char, args) {
    var _results;
    if (args.length === 0) {
      args = [0];
    }
    _results = [];
    while (args.length > 0) {
      _results.push(args = this.set_graphic_rendition(args));
    }
    return _results;
  };

  Emulator.prototype.decstbm = function(_char, args) {
    this.scroll_top = args[0] || 1;
    this.scroll_bottom = args[1] || this.sb.height;
    return this.sb.set_scroll_region(this.scroll_top, this.scroll_bottom);
  };

  Emulator.prototype.dsr = function(_char, args) {
    return console.log("dsr(" + args + ")");
  };

  Emulator.prototype.scp = function(_char, args) {
    return console.log("scp(" + args + ")");
  };

  Emulator.prototype.rsp = function(_char, args) {
    return console.log("rsp(" + args + ")");
  };

  Emulator.prototype.rm = function(_char, args) {
    switch (args[0]) {
      case 1:
        return null;
      case 12:
        return null;
      case 25:
        return null;
      case 47:
        return this.use_primary_buffer();
      case 1048:
        return this.use_primary_cursor();
      case 1049:
        this.use_primary_cursor();
        return this.use_primary_buffer();
      default:
        return console.log("Unsupported rm " + args[0]);
    }
  };

  Emulator.prototype.sm = function(_char, args) {
    switch (args[0]) {
      case 1:
        return null;
      case 12:
        return null;
      case 25:
        return null;
      case 47:
        return this.use_alternate_buffer();
      case 1048:
        return this.use_alternate_cursor();
      case 1049:
        this.use_alternate_cursor();
        return this.use_alternate_buffer();
      default:
        return console.log("Unsupported sm " + args[0]);
    }
  };

  Emulator.prototype.newline = function(count) {
    var _results;
    _results = [];
    while (count > 0) {
      count -= 1;
      this.line += 1;
      if (this.line >= this.sb.height) {
        this.line -= 1;
        _results.push(this.sb.scroll_up());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Emulator.prototype.preserve_cursor = function(func) {
    var c, l, _ref, _ref1;
    _ref = [this.line, this.col], l = _ref[0], c = _ref[1];
    func();
    return _ref1 = [l, c], this.line = _ref1[0], this.col = _ref1[1], _ref1;
  };

  Emulator.prototype.normalize_col = function() {
    if (this.col < 1) {
      this.col = 1;
    }
    if (this.col > this.sb.width) {
      return this.col = this.sb.width;
    }
  };

  Emulator.prototype.normalize_line = function() {
    if (this.line < 1) {
      this.line = 1;
    }
    if (this.line > this.sb.height) {
      return this.line = this.sb.height;
    }
  };

  Emulator.prototype.use_primary_buffer = function() {
    this.sb.use_primary();
    return this.update();
  };

  Emulator.prototype.use_alternate_buffer = function() {
    this.sb.use_alternate();
    return this.update();
  };

  Emulator.prototype.use_alternate_cursor = function() {
    var _ref;
    console.log([this.line, this.col]);
    this.primary_cursor = [this.line, this.col];
    _ref = this.alternate_cursor, this.line = _ref[0], this.col = _ref[1];
    return console.log([this.line, this.col]);
  };

  Emulator.prototype.use_primary_cursor = function() {
    var _ref;
    this.alternate_cursor = [this.line, this.col];
    return _ref = this.primary_cursor, this.line = _ref[0], this.col = _ref[1], _ref;
  };

  Emulator.prototype.set_graphic_rendition = function(args) {
    var arg, color, flag;
    arg = args.shift();
    switch (arg) {
      case 0:
        this.attr.reset();
        break;
      case 1:
        this.attr.bold = true;
        break;
      case 2:
        this.attr.bold = false;
        break;
      case 4:
        this.attr.ul = true;
        break;
      case 7:
        this.attr.inverse = true;
        break;
      case 22:
        this.attr.bold = false;
        break;
      case 24:
        this.attr.ul = false;
        break;
      case 27:
        this.attr.inverse = false;
        break;
      case 39:
        this.attr.fg = this.attr.DEFAULT_FG;
        break;
      case 49:
        this.attr.bg = this.attr.DEFAULT_BG;
        break;
      case 38:
      case 48:
        flag = args.shift();
        if (flag !== 5) {
          console.log("Expecting 5 after csi 38/48, got " + flag);
        }
        color = args.shift();
        if (arg === 38) {
          this.attr.fg = color;
        } else {
          this.attr.bg = color;
        }
        break;
      default:
        switch (false) {
          case __indexOf.call([30, 31, 32, 33, 34, 35, 36, 37], arg) < 0:
            this.attr.fg = arg - 30;
            break;
          case __indexOf.call([40, 41, 42, 43, 44, 45, 46, 47], arg) < 0:
            this.attr.bg = arg - 40;
            break;
          default:
            console.log("Unknown sgr " + arg);
        }
    }
    return args;
  };

  return Emulator;

})();
