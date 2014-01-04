(exports ? window).VcrControls =
class VcrControls

        constructor: (@player, @playback_window) ->
            @add_controls()

        add_controls: ->
            rewind = @button("rewind", @player.rewind)
            stop   = @button("pause",  @player.pause)
            slow   = @button("½ &gt;",           @player.play, 2)
            play   = @button("play",             @player.play, 1)
            fast1  = @button("&gt;&gt;",         @player.play, 0.5)
            fast2  = @button("&gt;&gt;&gt;",     @player.play, 0.25)
            fast3  = @button("&gt;&gt;&gt;&gt;", @player.plat, 0.01)

            rewind.prop('disabled', true)
            stop.prop('disabled',   true)

            nav    = $("<nav class=\"vcr-buttons\"></nav>")
            nav.append rewind, stop, slow, play, fast1, fast2, fast3

            progress = $("<div class=\"vcr-progress\"></div>")
            progress.append nav
            
            @playback_window.append progress
            
            progress.progressbar
                value: @player.current_time + 1
                max: @player.max_time

            $(document).on(Player.EV_PLAYING, ->
                rewind.prop('disabled', false)
                stop.prop('disabled',   false))
                
            $(document).on(Player.EV_IDLE, ->
                play.prop('disabled', false)
                stop.prop('disabled', true))
            
            $(document).on(Player.EV_STEP, =>
                percent = 100.0*@player.current_time / @player.max_time
                progress
                .find(".ui-progressbar-value")
                .animate(
                    width: "#{percent}%"
                  ,
                   queue: false
                   easing: 'linear'
                   duration: 600))
                

        button: (label, on_click, arg) ->
            $("<input type=\"button\" value=\"#{label}\"/>")
            .on("click",
                (e) =>
                    e.preventDefault()
                    on_click(arg))
