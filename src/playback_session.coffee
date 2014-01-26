jQuery.fn.extend
  playback_recording_from_file: (options) ->
    return @each (_, playback_window) ->
      playback_window = $(playback_window)
      recording_name = playback_window.data("from")
      Recording.load recording_name, (recording_data) ->
          player = new Player(recording_data, playback_window)
          new VcrControls(player, playback_window)

  playback_inline_recording: (options) ->
    return @each (_, playback_window) ->
      playback_window = $(playback_window)
      Recording.inline playback_window, (recording_data) ->
          player = new Player(recording_data, playback_window)
          new VcrControls(player, playback_window)
  
#jQuery.ajaxPrefilter "json script", (options) ->
#      options.crossDomain = true

# $(".playback").playback_recording()



