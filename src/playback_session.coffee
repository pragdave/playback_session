jQuery.fn.extend
  emulate: (options) ->
    return @each (_, terminal) ->
      console.log(terminal)
      dom_terminal = $(terminal)
      recording_name = dom_terminal.data("from")
      (new Driver).for_recording(recording_name, dom_terminal)

jQuery.ajaxPrefilter "json script", (options) ->
      options.crossDomain = true

$(".terminal").emulate()



