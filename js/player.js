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
    }, (function(_this) {
      return function(n) {
        return factor * _this.stream[n].d;
      };
    })(this));
    return this.playback = this.source.subscribe((function(_this) {
      return function(n) {
        return _this.step();
      };
    })(this), (function(_this) {
      return function(err) {
        return console.log('Error: ' + err);
      };
    })(this), (function(_this) {
      return function() {
        return _this.finish_play();
      };
    })(this));
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
      case "snapshot":
        this.load_from(data.val);
        break;
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
      return this.move_to(position);
    } else {
      return this.trigger_update();
    }
  };

  Player.prototype.move_to = function(position) {
    var finish, _results;
    if (position === this.playhead) {
      return;
    }
    if (position < this.playhead) {
      this.playhead = 0;
    }
    this.playhead = this.find_last_snapshot_between(this.playhead, position);
    finish = position;
    this.current_time = this.stream[this.playhead].elapsed;
    if (position === 0) {
      this.sb.clear_all();
      this.new_emulator();
      this.emulator.update();
    }
    _results = [];
    while (this.playhead <= finish) {
      _results.push(this.step());
    }
    return _results;
  };

  Player.prototype.find_last_snapshot_between = function(start, finish) {
    while (finish > start && this.stream[finish].t !== "snapshot") {
      finish -= 1;
    }
    return finish;
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

  Player.prototype.load_from = function(state) {
    this.sb.load_from(state.sb_dump);
    this.fsm.load_from(state.fsm_dump);
    this.emulator.load_from(state.emulator_dump);
    this.state = state.player.state;
    this.playhead = state.player.playhead;
    this.current_time = state.player.current_time;
    this.emulator.update();
    return this.trigger_update();
  };

  Player.prototype.save_state = function() {
    var state;
    return state = {
      sb_dump: this.sb.save(),
      fsm_dump: this.fsm.save(),
      emulator_dump: this.emulator.save(),
      player: {
        state: this.state,
        playhead: this.playhead,
        current_time: this.current_time
      }
    };
  };

  return Player;

})();
