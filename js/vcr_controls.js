var VcrControls,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

(typeof exports !== "undefined" && exports !== null ? exports : window).VcrControls = VcrControls = (function() {
  function VcrControls(player, playback_window) {
    this.player = player;
    this.playback_window = playback_window;
    this.create_editor = __bind(this.create_editor, this);
    this.add_controls();
  }

  VcrControls.prototype.add_controls = function() {
    var edit, fast1, fast2, fast3, nav, play, rewind, slow, step, stop,
      _this = this;
    rewind = this.button("↩", this.player.rewind);
    stop = this.button("||", this.player.pause);
    slow = this.button("½ ▶", this.player.play, 2);
    play = this.button("▶", this.player.play, 1);
    fast1 = this.button("▶▶", this.player.play, 0.5, "compress");
    fast2 = this.button("▶▶▶", this.player.play, 0.25, "compress");
    fast3 = this.button("▶▶▶▶", this.player.play, 0.01, "compress");
    step = this.button("↷", this.player.step);
    rewind.prop('disabled', true);
    stop.prop('disabled', true);
    nav = $("<nav class=\"vcr-buttons\"></nav>");
    nav.append(rewind, step, stop, slow, play, fast1, fast2, fast3);
    if (typeof Editor === "function") {
      edit = this.button("EDIT", this.create_editor);
      nav.append(edit);
    }
    this.progress = $("<progress class=\"vcr-progress\"></progress>");
    this.playback_window.append(nav);
    this.playback_window.append(this.progress);
    this.progress.attr("max", max_time);
    this.progress.val(this.player.current_time + 1);
    $(document).on(Player.EV_PLAYING, function() {
      rewind.prop('disabled', false);
      return stop.prop('disabled', false);
    });
    $(document).on(Player.EV_IDLE, function() {
      play.prop('disabled', false);
      return stop.prop('disabled', true);
    });
    return $(document).on(Player.EV_STEP, function(x) {
      return _this.progress.animate({
        val: _this.player.current_time + 1
      }, {
        queue: false,
        easing: 'linear',
        duration: 500
      });
    });
  };

  VcrControls.prototype.create_editor = function() {
    return new Editor(this.player);
  };

  VcrControls.prototype.button = function(label, on_click, arg, klass) {
    var _this = this;
    if (klass) {
      klass = " class=\"" + klass + "\"";
    }
    return $("<input type=\"button\" value=\"" + label + "\"" + klass + "/>").on("click", function(e) {
      e.preventDefault();
      return on_click(arg);
    });
  };

  return VcrControls;

})();
