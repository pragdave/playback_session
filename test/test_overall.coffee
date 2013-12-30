chai.should()

# class TestEmulatorHelper
#     @validate_all: (sb, from, to, char) ->
#         sb.each from, to, (line_no, screen_char) =>
#             screen_char.should.eql char

#     @validate_dirty: (sb, dirty=[]) ->
#         clean = [1..sb.height]
#         for line_no in dirty
#             sb.dirty(line_no).should.equal true
#             clean[line_no-1] = null
#         for line_no in clean when line_no
#             sb.dirty(line_no).should.equal false
            
        

describe 'Integration', ->
    beforeEach ->
        mock_dom =
            html: (content) ->
                @content = content

        @sb   = new ScreenBuffer([86, 25])
        @html = new HtmlViewer(mock_dom, @sb)
        @emu = new Emulator(mock_dom, @sb, @html)
        # @helper = TestEmulatorHelper
        @fsm = new AnsiFSM(@emu)

    describe "a complex sequence", ->
        beforeEach ->
            @seq = "\r\u001b[m\u001b[27m\u001b[24m\u001b[J\u001b[mdave\u001b[34m\u001b[32m[Play/playback_session" +
                   "\u001b[31m\u001b[32m] \u001b[37m\u001b[1m\u001b[K\u001b[56C\u001b[39m \u001b[37m\u001b[57D"
            @fsm.accept_string(@seq)
            @line = @sb.lines[0]

        # it 'should result in the correct text', ->
        #     chars = (cell.char for cell in @line).join("")
        #     chars.should.contain "dave[Play/playback_session]"

        it 'should have the correct attributes', ->
            attrs = (cell.attrs for cell in @line)
            white = new ScreenBuffer.Attrs
            green = new ScreenBuffer.Attrs; green.fg = 2

            (attr.is_equal_to(white).should.be.true for attr in attrs[0..3])
            (attr.should.eql green for attr in attrs[4..26])
            

