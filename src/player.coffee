(exports ? window).Player =
class Player

   @event_name: (name) ->
       "evPlayer_#{name}"        

    @EV_IDLE    = Player.event_name("idle")
    @EV_STEP    = Player.event_name("step")
    @EV_PLAYING = Player.event_name("playing")
    
    constructor: (@recording, @playback_window) ->
        @stream = recording.stream
        @max_time = Recording.calculate_times(@recording)
        @sb    = new ScreenBuffer(recording.size)
        @html  = new HtmlViewer(@playback_window, @sb)
        @new_emulator()
        @state = 'idle'
        @popup_div = $("<div class=\"popup\"></div>")
#        @popup_div.dialog(
#            show: 600
#            hide: 600
#            autoOpen: false
#            modal: false
#        )
        
    play: (factor= -1, end_position = @stream.length) =>
        @pause()
        @playhead = 0 if @playhead >= @stream.length
        @change_state('playing')
        @source = Rx.Observable.generateWithRelativeTime(
                     @playhead,                 # initial state
                     (n) -> n < end_position,   # termination
                     (n) -> n + 1,              # step function
                     (n) -> n,                  # value returned
                     (n) => factor*@stream[n].d) # and the time

        @playback = @source.subscribe(
            (n)    => @step(),
            (err)  => console.log('Error: ' + err),
            ()     => @finish_play())

    pause: =>
        @playback.dispose() if @playback
        @change_state('idle')

    step: =>
        data = @stream[@playhead]

        switch data.t
            when "snapshot"
                @load_from(data.val)
            when "op"
                @fsm.accept_string(data.val)
            when "popup"
                @handle_popup(data.val)
            when "popdown"
                @handle_popdown(data.val)
            else
                console.log("Invalid data imported")
                console.log(data)
            
        @current_time += data.d
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
            @move_to(position)
        else
            @trigger_update()

    # called by the editor to move as fast as possible to a particular
    # playback position if position > playhead, look backward from
    # position for a saved snapshot, and play forward from it. If not
    # found, play forward from the playhead. Otherwise, look backwards
    # from the playhead for a snapshot we can use, playing forward either from
    # it or from the 

    move_to: (position) ->
        return if position == @playhead
        @playhead = 0 if position < @playhead
        @playhead = @find_last_snapshot_between(@playhead, position)
        finish = position
        @current_time = @stream[@playhead].elapsed
        if position == 0
            @sb.clear_all()
            @new_emulator()
            @emulator.update()
            
        @step() while @playhead <= finish
            

    find_last_snapshot_between: (start, finish) ->
        finish -= 1 while finish > start && @stream[finish].t != "snapshot"
        finish
        
    # called when the data is manually edited
    data_updated: (to_row) ->
        @playhead = to_row
        @max_time = Recording.calculate_times(@recording)
        @current_time = @stream[@playhead].elapsed
        @trigger_update()

    trigger_update: ->
        $(document).triggerHandler(Player.EV_STEP, @playhead)
        
    
    finish_play: ->
        @change_state('idle')
        @playback = null

    new_emulator: ->
        @emulator = new Emulator(@playback_window, @sb, @html)
        @fsm  = new AnsiFSM(@emulator)
        @playhead = 0
        @current_time = 0

    handle_popup: (popup) ->
        @popup_div.html(markdown.toHTML(popup))
        @popup_div.closest(".ui-dialog").find(".ui-dialog-titlebar").hide()
        @popup_div.bPopup(modal: false)
        
    handle_popdown: (popup) ->
        @popup_div.bPopup().close()
                
    change_state: (new_state) ->
        if @state != new_state
            @state = new_state
            $(document).triggerHandler
                type: Player.event_name(new_state)

    # serialization of all state

    load_from: (state) ->
        @sb.load_from(state.sb_dump)
        @fsm.load_from(state.fsm_dump)
        @emulator.load_from(state.emulator_dump)
        #
        @state    = state.player.state
        @playhead = state.player.playhead
        @current_time = state.player.current_time
        @emulator.update() 
        @trigger_update()
            
    save_state: -> 
        state = 
            sb_dump:       @sb.save(),
            fsm_dump:      @fsm.save(),
            emulator_dump: @emulator.save(),
            #
            player:
                state:        @state,
                playhead:     @playhead,
                current_time: @current_time
            
