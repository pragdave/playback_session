var Player,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

(typeof exports !== "undefined" && exports !== null ? exports : window).Player = Player = (function() {
  Player.event_name = function(name) {
    return "evPlayer_" + name;
  };

  Player.EV_IDLE = Player.event_name("idle");

  Player.EV_STEP = Player.event_name("step");

  Player.EV_PLAYING = Player.event_name("playing");

  function Player(recording, playback_window) {
    this.recording = recording;
    this.playback_window = playback_window;
    this.rewind = __bind(this.rewind, this);
    this.step = __bind(this.step, this);
    this.pause = __bind(this.pause, this);
    this.play = __bind(this.play, this);
    this.stream = recording.stream;
    this.max_time = Recording.calculate_times(this.recording);
    this.sb = new ScreenBuffer(recording.size);
    this.html = new HtmlViewer(this.playback_window, this.sb);
    this.new_emulator();
    this.state = 'idle';
    this.popup_div = $("<div class=\"popup\"></div>");
  }

  Player.prototype.play = function(factor, end_position) {
    var _this = this;
    if (factor == null) {
      factor = -1;
    }
    if (end_position == null) {
      end_position = this.stream.length;
    }
    this.pause();
    if (this.playhead >= this.stream.length) {
      this.playhead = 0;
    }
    this.change_state('playing');
    this.source = Rx.Observable.generateWithRelativeTime(this.playhead, function(n) {
      return n < end_position;
    }, function(n) {
      return n + 1;
    }, function(n) {
      return n;
    }, function(n) {
      return factor * _this.stream[n].d;
    });
    return this.playback = this.source.subscribe(function(n) {
      return _this.step();
    }, function(err) {
      return console.log('Error: ' + err);
    }, function() {
      return _this.finish_play();
    });
  };

  Player.prototype.pause = function() {
    if (this.playback) {
      this.playback.dispose();
    }
    return this.change_state('idle');
  };

  Player.prototype.step = function() {
    var data;
    data = this.stream[this.playhead];
    switch (data.t) {
      case "op":
        this.fsm.accept_string(data.val);
        break;
      case "popup":
        this.handle_popup(data.val);
        break;
      case "popdown":
        this.handle_popdown(data.val);
        break;
      default:
        console.log("Invalid data imported");
        console.log(data);
    }
    this.current_time += data.d;
    this.trigger_update();
    return this.playhead += 1;
  };

  Player.prototype.rewind = function(position) {
    if (position == null) {
      position = 0;
    }
    this.pause();
    this.playhead = 0;
    this.current_time = 0;
    this.sb.clear_all();
    this.new_emulator();
    this.emulator.update();
    if (position > 0) {
      if (position > 0) {
        return this.fast_forward(0, position);
      }
    } else {
      return this.trigger_update();
    }
  };

  Player.prototype.data_updated = function(to_row) {
    this.playhead = to_row;
    this.max_time = Recording.calculate_times(this.recording);
    this.current_time = this.stream[this.playhead].elapsed;
    return this.trigger_update();
  };

  Player.prototype.trigger_update = function() {
    return $(document).triggerHandler(Player.EV_STEP, this.playhead);
  };

  Player.prototype.finish_play = function() {
    this.change_state('idle');
    return this.playback = null;
  };

  Player.prototype.new_emulator = function() {
    this.emulator = new Emulator(this.playback_window, this.sb, this.html);
    this.fsm = new AnsiFSM(this.emulator);
    this.playhead = 0;
    return this.current_time = 0;
  };

  Player.prototype.handle_popup = function(popup) {
    this.popup_div.html(markdown.toHTML(popup));
    this.popup_div.closest(".ui-dialog").find(".ui-dialog-titlebar").hide();
    return this.popup_div.bPopup({
      modal: false
    });
  };

  Player.prototype.handle_popdown = function(popup) {
    return this.popup_div.bPopup().close();
  };

  Player.prototype.change_state = function(new_state) {
    if (this.state !== new_state) {
      this.state = new_state;
      return $(document).triggerHandler({
        type: Player.event_name(new_state)
      });
    }
  };

  return Player;

})();
