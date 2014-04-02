chai.should()

chai.Assertion.addMethod 'look_like', (expected) ->
    actual = @_obj


    this.assert actual.length == expected.length,
                'wrong number of rows: expected #{act} to be #{exp}',
                'wrong number of rows: expected #{act} not to be #{exp}',
                expected.length,
                actual.length

    for i in [0...expected.length]
        expected_chars = expected[i]
        actual_chars   = (cell.char for cell in actual[i]).join("")
        this.assert expected_chars == actual_chars,
                    "line #{i+1}, expected \#{exp} to be \#{act}",
                    "line #{i+1}, expected \#{exp} not to be \#{act}",
                    expected_chars,
                    actual_chars

describe 'Character patterns', ->
    beforeEach ->
        mock_dom =
            html: (@content) ->
            prepend: (dom) ->
            css:     (_) ->

        @lines   = 4
        @columns = 5
        @sb   = new ScreenBuffer lines: @lines, columns: @columns
        @html = new HtmlViewer(mock_dom, @sb)
        @emu  = new Emulator(mock_dom, @sb, @html)
        @fsm  = new AnsiFSM(@emu)

    it 'starts empty', ->
        @sb.lines.should.look_like [
            "     "
            "     "
            "     "
            "     " ]

    it 'accepts characters', ->
        @fsm.accept_string "hi\r\ndave\r\n\n:)"
        @sb.lines.should.look_like [
            "hi   "
            "dave "
            "     "
            ":)   " ]

    it 'does basic scrolling', ->
        @fsm.accept_string "1\r\n2\r\n3\r\n4\r\n"
        @sb.lines.should.look_like [
            "2    "
            "3    "
            "4    "
            "     " ]

    it 'does basic scrolling with data on last line', ->
        @fsm.accept_string "1\r\n2\r\n3\r\n4\r\nabcde"
        @sb.lines.should.look_like [
            "2    "
            "3    "
            "4    "
            "abcde" ]
                                

    it 'honors the scroll region (1)', ->
        @fsm.accept_string "\u001b[1;3r"
        @fsm.accept_string "1\r\n2\r\n3\r\n4"
        @sb.lines.should.look_like [
            "2    "
            "3    "
            "4    "
            "     " ]
                        
    it 'honors the scroll region (2)', ->
        @fsm.accept_string "\u001b[2;3r"
        @fsm.accept_string "\u001b[1;1H1\u001b[2;1H"
        @fsm.accept_string "2\r\n3\r\n4\r\n5"
        console.dir(@sb.lines)
                
        @sb.lines.should.look_like [
            "1    "
            "4    "
            "5    "
            "     " ]

    it 'honors the scroll region (3)', ->
        @fsm.accept_string "\u001b[1;4r"
        @fsm.accept_string "\u001b[1;1H1\u001b[2;1H"
        @fsm.accept_string "2\r\n3\r\n4\r\n5"
        console.dir(@sb.lines)
                
        @sb.lines.should.look_like [
            "2    "
            "3    "
            "4    "
            "5    " ]

describe 'Actual Sequence', ->
    beforeEach ->
        mock_dom =
            html: (@content) ->
            prepend: (dom) ->
            css:     (_) ->

        @sb   = new ScreenBuffer lines: 25, columns: 86
        @html = new HtmlViewer(mock_dom, @sb)
        @emu  = new Emulator(mock_dom, @sb, @html)
        @fsm  = new AnsiFSM(@emu)

    describe "a complex sequence", ->
        beforeEach ->
            @seq = "\r\u001b[m\u001b[27m\u001b[24m\u001b[J\u001b[mdave\u001b[34m\u001b[32m[Play/playback_session" +
                   "\u001b[31m\u001b[32m] \u001b[37m\u001b[1m\u001b[K\u001b[56C\u001b[39m \u001b[37m\u001b[57D"
            @fsm.accept_string(@seq)
            @line = @sb.lines[0]

        it 'should result in the correct text', ->
            chars = (cell.char for cell in @line).join("")
            chars.should.contain "dave[Play/playback_session]"

        it 'should have the correct attributes', ->
            attrs = (cell.attrs for cell in @line)
            white = new ScreenBuffer.Attrs
            green = new ScreenBuffer.Attrs; green.fg = 2

            (attr.is_equal_to(white).should.be.true for attr in attrs[0..3])
            (attr.should.eql green for attr in attrs[4..26])
            

