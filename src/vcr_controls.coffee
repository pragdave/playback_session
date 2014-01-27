(exports ? window).VcrControls =
class VcrControls

        constructor: (@player, @playback_window) ->
            @add_controls()

        add_controls: ->
            rewind = @button("↩",   @player.rewind)
            stop   = @button("||",   @player.pause)
            slow   = @button("½ ▶",  @player.play, 2)
            play   = @button("▶",    @player.play, 1)
            fast1  = @button("▶▶",   @player.play, 0.5,  "compress")
            fast2  = @button("▶▶▶",  @player.play, 0.25, "compress")
            fast3  = @button("▶▶▶▶", @player.play, 0.01, "compress")
            step   = @button("↷",    @player.step)


            rewind.prop('disabled', true)
            stop.prop('disabled',   true)

            nav    = $("<nav class=\"vcr-buttons\"></nav>")
            nav.append rewind, step, stop, slow, play, fast1, fast2, fast3

            if typeof(Editor) == "function"            
                edit   = @button("EDIT",   @create_editor)
                nav.append edit
                
            @progress = $("<div class=\"vcr-progress\"></div>")
            @progress_value = $("<div class=\"vcr-progress-value\"></div>")
            @progress.append @progress_value
            @playback_window.append @progress
            @playback_window.append nav
            
            @progress.attr("max", @player.max_time)
            @progress.val(@player.current_time + 1)

            $(document).on(Player.EV_PLAYING, ->
                rewind.prop('disabled', false)
                stop.prop('disabled',   false))
                
            $(document).on(Player.EV_IDLE, ->
                play.prop('disabled', false)
                stop.prop('disabled', true))
            
            $(document).on(Player.EV_STEP, (x) =>
                percent = 100*(@player.current_time+1)/@player.max_time
                @progress
                .animate(
                    width: "#{percent}%"
                  ,
                    queue: false
                    easing: 'linear'
                    duration: 500))


        create_editor: =>
            new Editor(@player)
            

        button: (label, on_click, arg, klass) ->
            klass = " class=\"#{klass}\"" if klass
            $("<input type=\"button\" value=\"#{label}\"#{klass}/>")
            .on("click", (e) =>
                             e.preventDefault()
                             on_click(arg))
