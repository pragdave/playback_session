chai.should()

class TestEmulatorHelper
    @validate_all: (sb, from, to, char) ->
        sb.each from, to, (line_no, screen_char) =>
            screen_char.should.eql char

    @validate_dirty: (sb, dirty=[]) ->
        clean = [1..sb.height]
        for line_no in dirty
            sb.dirty(line_no).should.equal true
            clean[line_no-1] = null
        for line_no in clean when line_no
            sb.dirty(line_no).should.equal false
            
        

describe 'Emulator', ->
    beforeEach ->
        mock_dom =
            html: (content) ->
                @content = content

        @sb     = new ScreenBuffer([10, 10])
        @html   = new HtmlViewer(mock_dom, @sb)
        @emu    = new Emulator(mock_dom, @sb, @html)
        @dc     = new ScreenBuffer.Cell
        @helper = TestEmulatorHelper
        
    describe 'constructor', ->
        it 'should have a cursor at (1,1) and default attributes', ->
            @emu.line.should.equal 1
            @emu.col.should.equal 1
            @emu.attr.should.eql @dc.attrs
            @helper.validate_dirty @sb, []
            
    describe 'adding characters', ->
        it 'should add characters and update the cursor position', ->
            @emu.echo_char("A", null)
            @sb.lines[0][0].char.should.equal "A"
            @emu.line.should.equal 1
            @emu.col.should.equal 2
            @helper.validate_dirty([1])

        it 'should add multiple characters', ->
            @emu.echo_char("A", null)
            @emu.echo_char("b", null)
            @emu.echo_char("c", null)
            
            @sb.lines[0][0].char.should.equal "A"
            @sb.lines[0][1].char.should.equal "b"
            @sb.lines[0][2].char.should.equal "c"
            @emu.line.should.equal 1
            @emu.col.should.equal 4
            @helper.validate_dirty([1])

    describe 'backspace', ->
        it 'should move the cursor back', ->
            @emu.echo_char("A", null)
            @sb.lines[0][0].char.should.equal "A"
            @emu.line.should.equal 1
            @emu.col.should.equal 2
            @emu.bs()
            @sb.lines[0][0].char.should.equal "A"
            @emu.line.should.equal 1
            @emu.col.should.equal 1
            @emu.echo_char("B", null)
            @sb.lines[0][0].char.should.equal "B"
            @emu.line.should.equal 1
            @emu.col.should.equal 2
            @helper.validate_dirty [1]

    describe 'carriage return', ->
        it 'should move the cursor to column 1', ->
            @emu.col.should.equal 1
            @emu.cr()
            @emu.col.should.equal 1
            @emu.echo_char("A", null)            
            @emu.col.should.equal 2
            @emu.cr()
            @emu.col.should.equal 1

    describe 'newline', ->
        it 'should move the cursor down one line', ->
            @emu.line.should.equal 1
            @emu.nl()
            @emu.line.should.equal 2
            @helper.validate_dirty []

    describe 'cursor up', ->
        beforeEach ->
            @emu.line = 6
            
        it 'should default to 1 line', ->
            @emu.line.should.equal 6
            @emu.cuu(null, [])
            @emu.line.should.equal 5
            @helper.validate_dirty []


        it 'should accept a count', ->
            @emu.line.should.equal 6
            @emu.cuu(null, [2])
            @emu.line.should.equal 4
            @helper.validate_dirty []

    describe 'cursor down', ->
        beforeEach ->
            @emu.line = 6
            
        it 'should default to 1 line', ->
            @emu.line.should.equal 6
            @emu.cud(null, [])
            @emu.line.should.equal 7
            @helper.validate_dirty []

        it 'should accept a count', ->
            @emu.line.should.equal 6
            @emu.cud(null, [2])
            @emu.line.should.equal 8
            @helper.validate_dirty []

    describe 'cursor back', ->
        beforeEach ->
            @emu.col = 6
            
        it 'should default to 1 column', ->
            @emu.col.should.equal 6
            @emu.cub(null, [])
            @emu.col.should.equal 5
            @helper.validate_dirty []

        it 'should accept multiple columns', ->
            @emu.col.should.equal 6
            @emu.cub(null, [3])
            @emu.col.should.equal 3
            @helper.validate_dirty []

    describe 'cursor forward', ->
        beforeEach ->
            @emu.col = 6
            
        it 'should default to 1 column', ->
            @emu.col.should.equal 6
            @emu.cuf(null, [])
            @emu.col.should.equal 7
            @helper.validate_dirty []

        it 'should accept multiple columns', ->
            @emu.col.should.equal 6
            @emu.cuf(null, [3])
            @emu.col.should.equal 9
            @helper.validate_dirty []

    describe 'cursor next line', ->
        beforeEach ->
            @emu.col = @emu.line = 5

        it 'should set the column to 1 and default to one line', ->
            @emu.cnl(null, [])
            @emu.col.should.equal 1
            @emu.line.should.equal 6
            @helper.validate_dirty []

        it 'should accept an argument', ->
            @emu.cnl(null, [2])
            @emu.col.should.equal 1
            @emu.line.should.equal 7
            @helper.validate_dirty []
            
    describe 'cursor previous line', ->
        beforeEach ->
            @emu.col = @emu.line = 5

        it 'should set the column to 1 and default to one line', ->
            @emu.cpl(null, [])
            @emu.col.should.equal 1
            @emu.line.should.equal 4
            @helper.validate_dirty []

        it 'should accept an argument', ->
            @emu.cpl(null, [2])
            @emu.col.should.equal 1
            @emu.line.should.equal 3
            @helper.validate_dirty []
            
    describe 'cursor horizontal absolute', ->
        beforeEach ->
            @emu.col = @emu.line = 5

        it 'should set the column to its argument', ->
            @emu.cha(null, [9])
            @emu.col.should.equal 9
            @emu.cha(null, [1])
            @emu.col.should.equal 1
            @helper.validate_dirty []

        it 'should set limit the excursion to the screen width', ->
            @emu.cha(null, [1])
            @emu.col.should.equal 1
            @emu.cha(null, [100])
            @emu.col.should.equal 10
            @helper.validate_dirty []

    describe 'cursor position', ->
        beforeEach ->
            @emu.col = @emu.line = 5

        it 'should set the cursor position if valid', ->
            @emu.cup(null,[3, 4])
            @emu.line.should.equal 3
            @emu.col.should.equal 4
            @helper.validate_dirty []

        it 'should default missing arguments to 1', ->
            @emu.cup(null,[3])
            @emu.line.should.equal 3
            @emu.col.should.equal 1
            @emu.cup(null, [0, 6])
            @emu.line.should.equal 1
            @emu.col.should.equal 6
            @helper.validate_dirty []
            
            
    describe 'erase display', ->
        beforeEach ->
            @star = new ScreenBuffer.Cell("*")
            @sb.fill([1,1], [@sb.height, @sb.width], @star)
            @sb.reset_dirty()
            
        it 'should clear from cursor to EOS when given no argument', ->
            @emu.cup(null, [5, 5])
            @emu.ed(null, [])
            @helper.validate_all(@sb, [1,1], [5, 4], @star)
            @helper.validate_all(@sb, [5,5], [@sb.height, @sb.width], @dc)
            @helper.validate_dirty [5..@sb.height]

        it 'should clear from cursor to EOS when given 0', ->
            @emu.cup(null, [5, 5])
            @emu.ed(null, [0])
            @helper.validate_all(@sb, [1,1], [5, 4], @star)
            @helper.validate_all(@sb, [5,5], [@sb.height, @sb.width], @dc)
            @helper.validate_dirty [5..@sb.height]

        it 'should clear from BOS to cursor when given 1', ->
            @emu.cup(null, [5, 5])
            @emu.ed(null, [1])
            @helper.validate_all(@sb, [1,1], [5, 5], @dc)
            @helper.validate_all(@sb, [5,6], [@sb.height, @sb.width], @star)
            @helper.validate_dirty [1..5]

        it 'should clear all the screen when given 2', ->
            @emu.cup(null, [5, 5])
            @emu.ed(null, [2])
            @helper.validate_all(@sb, [1,1], [@sb.height, @sb.width], @dc)
            @helper.validate_dirty [1..@sb.height]

    describe "erase line", ->
        beforeEach ->
            @star = new ScreenBuffer.Cell("*")
            @sb.fill([1,1], [@sb.height, @sb.width], @star)
            @sb.reset_dirty()
            
        it 'should clear to end of line given no argument', ->
            @emu.cup(null, [5, 5])
            @emu.el(null, [])
            @helper.validate_all(@sb, [1,1], [5, 4], @star)
            @helper.validate_all(@sb, [5,5], [5, @sb.width], @dc)
            @helper.validate_all(@sb, [6,1], [@sb.height, @sb.width], @star)
            @helper.validate_dirty [5]
            
        it 'should clear to end of line given 0', ->
            @emu.cup(null, [5, 5])
            @emu.el(null, [0])
            @helper.validate_all(@sb, [1,1], [5, 4], @star)
            @helper.validate_all(@sb, [5,5], [5, @sb.width], @dc)
            @helper.validate_all(@sb, [6,1], [@sb.height, @sb.width], @star)
            @helper.validate_dirty [5]
            
        it 'should clear to start of line given 1', ->
            @emu.cup(null, [5, 5])
            @emu.el(null, [1])
            @helper.validate_all(@sb, [1,1], [4, @sb.width], @star)
            @helper.validate_all(@sb, [5,1], [5, 5], @dc)
            @helper.validate_all(@sb, [5,6], [@sb.height, @sb.width], @star)
            @helper.validate_dirty [5]
            
        it 'should clear the whole line given 2', ->
            @emu.cup(null, [5, 5])
            @emu.el(null, [2])
            @helper.validate_all(@sb, [1,1], [4, @sb.width], @star)
            @helper.validate_all(@sb, [5,1], [5, @sb.width], @dc)
            @helper.validate_all(@sb, [6,1], [@sb.height, @sb.width], @star)
            @helper.validate_dirty [5]
            
    describe "set graphic rendition", ->
        it 'with no argument should do a reset', ->
            @emu.attr.fg = 3
            @emu.attr.bg = 4
            @emu.bold = @emu.ul = @emu.inverse = true
            @emu.sgr(null, [])
            @emu.attr.should.eql @dc.attrs

        it 'with argument 0 should do a reset', ->
            @emu.attr.fg = 3
            @emu.attr.bg = 4
            @emu.bold = @emu.ul = @emu.inverse = true
            @emu.sgr(null, [0])
            @emu.attr.should.eql @dc.attrs

        it 'with argument 1 should set bold', ->
            @emu.attr.bold = false
            @emu.sgr(null, [1])
            @emu.attr.bold.should.equal true

        it 'with argument 2 should reset bold', ->
            @emu.attr.bold = true
            @emu.sgr(null, [2])
            @emu.attr.bold.should.equal false

        it 'with argument 4 should set underline', ->
            @emu.attr.ul = false
            @emu.sgr(null, [4])
            @emu.attr.ul.should.equal true

        it 'with argument 7 should set inverse', ->
            @emu.attr.inverse = false
            @emu.sgr(null, [7])
            @emu.attr.inverse.should.equal true

        it 'with argument 22 should reset bold', ->
            @emu.attr.bold = true
            @emu.sgr(null, [22])
            @emu.attr.bold.should.equal false

        it 'with argument 24 should reset underline', ->
            @emu.attr.ul = true
            @emu.sgr(null, [24])
            @emu.attr.ul.should.equal false

        it 'with argument 27 should reset inverse', ->
            @emu.attr.inverse = true
            @emu.sgr(null, [27])
            @emu.attr.inverse.should.equal false

        it 'with argument 39 should reset fg', ->
            @emu.attr.fg = 4
            @emu.sgr(null, [39])
            @emu.attr.fg.should.equal 7

        it 'with argument 49 should reset bg', ->
            @emu.attr.bg = 4
            @emu.sgr(null, [49])
            @emu.attr.bg.should.equal 0

        it 'with argumemt 34 sets fg to 4', ->
            @emu.attr.fg = 0
            @emu.sgr(null, [34])
            @emu.attr.fg.should.equal 4
            
        it 'with argumemt 44 sets bg to 4', ->
            @emu.attr.bg = 0
            @emu.sgr(null, [44])
            @emu.attr.bg.should.equal 4
            

        it 'with multiple arguments honors them all', ->
            @emu.sgr(null, [1,44,32,7])
            @emu.attr.bold.should.equal true
            @emu.attr.bg.should.equal   4
            @emu.attr.fg.should.equal   2
            @emu.attr.inverse.should.equal true

