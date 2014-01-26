jQuery.fn.extend({
  playback_recording_from_file: function(options) {
    return this.each(function(_, playback_window) {
      var recording_name;
      playback_window = $(playback_window);
      recording_name = playback_window.data("from");
      return Recording.load(recording_name, function(recording_data) {
        var player;
        player = new Player(recording_data, playback_window);
        return new VcrControls(player, playback_window);
      });
    });
  },
  playback_inline_recording: function(options) {
    return this.each(function(_, playback_window) {
      playback_window = $(playback_window);
      return Recording.inline(playback_window, function(recording_data) {
        var player;
        player = new Player(recording_data, playback_window);
        return new VcrControls(player, playback_window);
      });
    });
  }
});
