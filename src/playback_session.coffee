jQuery.fn.extend
  recording_playback: (options) ->
    return @each (_, playback_window) ->
      console.log(playback_window)
      playback_window = $(playback_window)
      recording_name = playback_window.data("from")
      Recording.load recording_name, (recording_data) ->
          player = new Player(recording_data, playback_window)
          new VcrControls(player, playback_window)
          

jQuery.ajaxPrefilter "json script", (options) ->
      options.crossDomain = true

$(".playback").recording_playback()



