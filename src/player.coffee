(exports ? window).Player =
class Player

   @event_name: (name) ->
       "evPlayer_#{name}"        

    @EV_IDLE    = Player.event_name("idle")
    @EV_STEP    = Player.event_name("step")
    @EV_PLAYING = Player.event_name("playing")
    
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
        @max_time = @data.reduce(((acc, value) -> acc + value[0]), 0)
        @sb    = new ScreenBuffer(recording.size)
        @html  = new HtmlViewer(@playback_window, @sb)
        @new_emulator()
        @state = 'idle'
        
    play: (factor= -1, end_position = @data.length) =>
        @pause()
        @playhead = 0 if @playhead >= @data.length
        @change_state('playing')
        @source = Rx.Observable.generateWithRelativeTime(
                     @playhead,                 # initial state
                     (n) -> n < end_position,   # termination
                     (n) -> n + 1,              # step function
                     (n) -> n,                  # value returned
                     (n) => factor*@data[n][0]) # and the time

        @playback = @source.subscribe(
            (n)    => @step(),
            (err)  => console.log('Error: ' + err),
            ()     => @finish_play())
            
    pause: =>
        @playback.dispose() if @playback
        @change_state('idle')

    step: =>
        [ delay, string ] = @data[@playhead]
        @fsm.accept_string(string)
        @current_time += delay
        $(document).triggerHandler(Player.EV_STEP, @current_time)
        @playhead += 1
        
    rewind: (position = 0) =>
        @pause()
        @playhead = 0
        @current_time = 0
        @sb.clear_all()
        @new_emulator()
        @emulator.update()
        if position > 0
            @fast_forward(0, position) if position > 0
        else
            $(document).triggerHandler(Player.EV_STEP, @current_time)



    finish_play: ->
        @change_state('idle')
        @playback = null

    new_emulator: ->
        @emulator = new Emulator(@playback_window, @sb, @html)
        @fsm  = new AnsiFSM(@emulator)
        @playhead = 0
        @current_time = 0
                
    change_state: (new_state) ->
        if @state != new_state
            @state = new_state
            $(document).triggerHandler
                type: Player.event_name(new_state)
        
            
