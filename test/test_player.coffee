chai.should()

describe 'save state', ->

    beforeEach ->
        @mock_recording = {}
        @mock_recording.size = { lines: 3, columns: 4 } 
        @mock_recording.stream = [ { d: 0 } ]

        @mock_window = {}
        @mock_window.prepend = (data) ->
        @mock_window.css     = (css) ->
            

    it 'should save an empty state', ->
        @player = new Player(@mock_recording, @mock_window)
        state = @player.save_state()
        state.player.current_time.should.eql 0
        state.player.playhead.should.eql     0
        state.player.state.should.eql        'idle'

        state.sb_dump.use_primary.should.eql true
        state.sb_dump.scroll_top.should.eql  1
        state.sb_dump.scroll_bottom.should.eql 3

        state.fsm_dump.state.should.eql 'plain'

        state.emulator_dump.line.should.eql 1
        state.emulator_dump.col.should.eql  1
        state.emulator_dump.attr.should.eql new ScreenBuffer.Attrs()

    it 'should save a nonempty state', ->
        @mock_recording.stream = [
            d: 0, t: "op", val: "a\u001b[31mb\u001b[3"
        ]
        @player = new Player(@mock_recording, @mock_window)
        @player.step()
        state = @player.save_state()
        state.player.current_time.should.eql 0
        state.player.playhead.should.eql     1
        state.player.state.should.eql        'idle'

        state.sb_dump.use_primary.should.eql true
        state.sb_dump.scroll_top.should.eql  1
        state.sb_dump.scroll_bottom.should.eql 3

        state.fsm_dump.state.should.eql 'csi_seen'

        state.emulator_dump.line.should.eql 1
        state.emulator_dump.col.should.eql  3
        
        state.emulator_dump.primary_cursor.should.eql [1, 1]
        state.emulator_dump.alternate_cursor.should.eql [1, 1]
        attr = new ScreenBuffer.Attrs()
        attr.fg = 1
        state.emulator_dump.attr.should.eql attr

    it 'should be able to recover from a save', ->
        @mock_recording.stream = [
            { d: 0, t: "op", val: "hello" },
            { d: 0, t: "op", val: "\u001b[H\u001b[2J" }, # clear screen
            { d: 0, t: "op", val: "bye" }
        ]
        @player = new Player(@mock_recording, @mock_window)
        @player.step()
        state = @player.save_state()
        @player.step()
        @player.step()
        
        @player.playhead.should.eql 3
        first_line = (cell.char for cell in @player.sb.lines[0]).join("")
        first_line.should.eql "bye "
        @player.emulator.line.should.eql 1
        @player.emulator.col.should.eql  4
        
        @player.load_from(state)
        first_line = (cell.char for cell in @player.sb.lines[0]).join("")
        first_line.should.eql "helo"
        @player.emulator.line.should.eql 1
        @player.emulator.col.should.eql  4
        

    it 'should handle interrupted escape sequences', ->
        @mock_recording.stream = [
            { d: 0, t: "op", val: "X\u001b[31" },
            { d: 0, t: "op", val: "mY" },                 # end set fg and 'Y'
            { d: 0, t: "op", val: "\u001b[H\u001b[2J" }, # clear screen
            { d: 0, t: "op", val: "bye" }
        ]
        @player = new Player(@mock_recording, @mock_window)
        @player.step()
        state = @player.save_state()
        @player.step()
        @player.step()
        @player.step()
        
        @player.playhead.should.eql 4
        first_line = (cell.char for cell in @player.sb.lines[0]).join("")
        first_line.should.eql "bye "
        @player.emulator.line.should.eql 1
        @player.emulator.col.should.eql  4
        
        @player.load_from(state)
        @player.step()
        first_line = (cell.char for cell in @player.sb.lines[0]).join("")
        first_line.should.eql "XY  "
        @player.emulator.line.should.eql 1
        @player.emulator.col.should.eql  3
        @player.sb.lines[0][0].attrs.fg.should.eql 7
        @player.sb.lines[0][1].attrs.fg.should.eql 1
                
