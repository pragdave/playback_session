jQuery.fn.extend({
  playback_recording: function(options) {
    var recording_name;
    return this.each(function(_, playback_window) {
      return playback_window = $(playback_window);
    });
    recording_name = playback_window.data("from");
    return Recording.load(recording_name, function(recording_data) {
      var player;
      player = new Player(recording_data, playback_window);
      return new VcrControls(player, playback_window);
    });
  }
});
