(exports ? window).VcrControls =
class VcrControls

        constructor: (@player, @playback_window) ->
            @add_controls()

        add_controls: ->
            rewind = @button("rewind", @player.rewind)
            stop   = @button("pause",  @player.pause)
            play   = @button("play",   @player.play)
            fast1  = @button("&gt;&gt;",   @player.fast_forward, 100)
            fast2  = @button("&gt;&gt;&gt;",   @player.fast_forward, 50)
            fast3  = @button("&gt;&gt;&gt;&gt;",   @player.fast_forward, 5)
            nav    = $("<nav class=\"vcr-buttons\"></nav>")
            nav.append rewind, stop, play, fast1, fast2, fast3
            @playback_window.append nav

        button: (label, on_click, arg) ->
            $("<input type=\"button\" value=\"#{label}\"/>")
            .on("click", => on_click(arg))
