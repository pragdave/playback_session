(exports ? window).Player =
class Player

   @event_name: (name) ->
       "evPlayer_#{name}"        

    @EV_IDLE    = Player.event_name("idle")
    @EV_STEP    = Player.event_name("step")
    @EV_PLAYING = Player.event_name("playing")
    
    constructor: (recording, @playback_window) ->
        @data = recording.data
        @max_time = @calc_max_time()
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
        @trigger_update()
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
            @trigger_update()

    # called when the data is manually edited
    data_updated: (to_row) ->
        @playhead = to_row
        console.log("Before: current: #{@current_time}, max = #{@max_time}")
        @max_time = @calc_max_time()
        @current_time = 0
        @current_time += (delay ? 0) for [delay, _] in @data[0...@playhead]
        console.log("After: current: #{@current_time}, max = #{@max_time}")
        @trigger_update()

    trigger_update: ->
        $(document).triggerHandler(Player.EV_STEP, @playhead)
        
    
    calc_max_time: ->
        @data.reduce(((acc, [delay,_]) -> acc + (delay ? 0)), 0)
        
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
        
            
