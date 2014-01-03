(exports ? window).Player =
class Player

    @load_recording: (recording_name, callback) ->
        console.log("loading #{recording_name}")
        jQuery.ajax
            url: recording_name
            dataType: "jsonp"
            jsonpCallback: "the_recording_data"
        .done((recording_data, textStatus) -> callback(recording_data))
        .fail((jqxhr, settings, exception) -> console.log(exception))

    constructor: (recording, @playback_window) ->
        @data = recording.data
        @sb    = new ScreenBuffer(recording.size)
        @html  = new HtmlViewer(@playback_window, @sb)
        @new_emulator()
        @state = 'idle'
        
    play: (end_position = @data.length, interval = -1) =>
        @change_state('playing')
        @source = Rx.Observable.generateWithRelativeTime(
                     @playhead,                                  # initial state
                     (n) -> n < end_position,                    # termination
                     (n) -> n + 1,                               # step function
                     (n) -> n,                                   # value returned
                     (n) => if interval < 0 then @data[n][0] else interval) # and the time

        @playback = @source.subscribe(
            (n)    => @step(),
            (err)  => console.log('Error: ' + err),
            ()     => @finish_play())
            
    pause: =>
        @playback.dispose() if @playback
        @change_state('idle')

    step: =>
        @fsm.accept_string(@data[@playhead][1])
        @playhead += 1
        
    fast_forward: (interval=0, end_position = 999999999) =>
        @pause()
        @play(end_position, interval)

    rewind: (position = 0) =>
        @pause()
        @playhead = 0
        @sb.clear_all()
        @new_emulator()
        @emulator.update()
        @fast_forward(0, position) if position > 0


    finish_play: ->
        @change_state('idle')
        @playback = null

    new_emulator: ->
        @emulator = new Emulator(@playback_window, @sb, @html)
        @fsm  = new AnsiFSM(@emulator)
        @playhead = 0
                
    change_state: (new_state) ->
        if @state != new_state
            @state = new_state
        
            
