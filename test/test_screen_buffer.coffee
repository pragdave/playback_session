chai.should()

HEIGHT = 8
WIDTH = 4

# Scroll region
TOP = 4
BOTTOM = 6
    

li = (i) -> 100+i

    

describe 'ScreenBuffer', ->
    beforeEach ->
        @sb = new ScreenBuffer lines: HEIGHT, columns: WIDTH
        @dc = new ScreenBuffer.Cell
        @lines = @sb.lines
        @range = [0...HEIGHT]
        (@lines[i][0].char = li(i)) for i in @range
        @check_default_cells = ->
            (@sb.lines[i][0].char.should.equal li(i)) for i in @range
            @sb.lines[2][3].should.eql  @dc
        
            
    describe 'constructor', ->
        it 'should remember the width and height', ->
            @sb.width.should.equal  WIDTH
            @sb.height.should.equal HEIGHT

        it 'should have the right number of lines', ->
            @sb.lines.should.have.length(HEIGHT)

        it 'should have lines of the correct length', ->
            @sb.lines[i].should.have.length(WIDTH) for i in @range

        it 'should have lines containing default cells', ->
            @check_default_cells()

    describe 'put', ->
        it 'should add a single character and update the cursor', ->
            @sb.put("A", @dc.attrs, 1, 1).should.eql [1, 2]
            @sb.lines[0][0].char.should.equal "A"

        it 'should add a multiple characters and update the cursor', ->
            @sb.put("AB", @dc.attrs, 1, 1).should.eql [1, 3]
            @sb.lines[0][0].char.should.equal "A"
            @sb.lines[0][1].char.should.equal "B"

        it 'should add 3 characters and update the cursor', ->
            @sb.put("ABC", @dc.attrs, 1, 1).should.eql [1, 4]
            @sb.lines[0][0].char.should.equal "A"
            @sb.lines[0][1].char.should.equal "B"
            @sb.lines[0][2].char.should.equal "C"

        it 'should move the cursor to the next line if we fill the current', ->
            @sb.put("ABCD", @dc.attrs, 1, 1).should.eql [1,4]
            @sb.lines[0][0].char.should.equal "A"
            @sb.lines[0][1].char.should.equal "B"
            @sb.lines[0][2].char.should.equal "C"
            @sb.lines[0][3].char.should.equal "D"

        it 'should support adding in the middle of a line', ->
            @sb.put("AB", @dc.attrs, 2, 2).should.eql [2,4]
            @sb.lines[1][1].char.should.equal "A"
            @sb.lines[1][2].char.should.equal "B"

        it 'should not wrap to the next line', ->
            @sb.put("ABCD", @dc.attrs, 2, 2).should.eql [2, 4]
            @sb.lines[1][1].char.should.equal "A"
            @sb.lines[1][2].char.should.equal "B"
            @sb.lines[1][3].char.should.equal "D"

        it 'should set the dirty flag on all modified lines', ->
            @sb.put("ABCD", @dc.attrs, 2, 2).should.eql [2, 4]
            @sb.dirty(1).should.equal false
            @sb.dirty(2).should.equal true
            @sb.dirty(3).should.equal false

        it 'should not scroll if we write to the last position on the screen', ->
            @sb.put("X", @dc.attrs, HEIGHT, WIDTH).should.eql [HEIGHT, WIDTH]
            @sb.lines[i][0].char.should.equal li(i) for i in [0..HEIGHT-2]
            @sb.lines[HEIGHT-1][WIDTH-1].char.should.equal "X"


        it 'should not scroll if we write to the last position of the scroll region', ->
            @sb.set_scroll_region(TOP, BOTTOM)
            @sb.put("X", @dc.attrs, BOTTOM, WIDTH).should.eql [BOTTOM, WIDTH]
            @sb.lines[i][0].char.should.equal li(i) for i in [0...HEIGHT]
            @sb.lines[BOTTOM-1][WIDTH-1].char.should.equal "X"
    
    describe 'scroll_up', ->
        describe 'with no scroll region', ->
            beforeEach ->
                @sb.scroll_up()
                
            it 'should scroll', ->
                @lines[i][0].char.should.equal li(i+1) for i in [0...HEIGHT-1]
    
            it 'should mark all lines dirty', ->
                (@sb.dirty(i).should.equal(true)) for i in [1..HEIGHT]

        describe 'with a scroll region set', ->
            beforeEach ->
                @sb.set_scroll_region(TOP, BOTTOM)
                @sb.scroll_up()
            
            it 'should scroll just the scroll region', ->
                @lines[i][0].char.should.equal li(i) for i in [0...TOP-1]
                @lines[i][0].char.should.equal li(i+1) for i in [TOP-1...BOTTOM-1]
                @lines[BOTTOM-1][0].should.eql @dc
                @lines[i][0].char.should.equal li(i) for i in [BOTTOM...HEIGHT]
    
            it 'should mark scroll region lines dirty', ->
                (@sb.dirty(i).should.equal(false)) for i in [1...TOP]
                (@sb.dirty(i).should.equal(true))  for i in [TOP...BOTTOM]
                (@sb.dirty(i).should.equal(false)) for i in [BOTTOM+1...HEIGHT]
            
    describe 'insert_lines', ->
            
        it 'should start out with lines in their right places', ->
            @lines[i][0].char.should.equal li(i) for i in @range

        it 'inserting one line at the bottom should add just one line', ->
            @sb.insert_lines(HEIGHT, 1)
            @lines[i][0].char.should.equal li(i) for i in [0...HEIGHT-1]
            @lines[HEIGHT-1][0].should.eql @dc

        it 'inserting one line at the top should add just one line', ->
            @sb.insert_lines(1, 1)
            @lines[0][0].should.eql @dc
            @lines[i][0].char.should.equal li(i)-1 for i in [1...HEIGHT-1]

        it 'inserting two lines at the top should add two lines', ->
            @sb.insert_lines(1, 2)
            @lines[i][0].should.eql @dc for i in [0...2]
            @lines[i][0].char.should.equal li(i)-2 for i in [2...HEIGHT-1]

        it 'inserting three lines at the top should add three lines', ->
            @sb.insert_lines(1, 3)
            @lines[i][0].should.eql @dc for i in [0...3]
                                                

        it 'inserting one line in the middle should make room', ->
            @sb.insert_lines(2, 1)
            @lines[1][0].should.eql @dc for i in [0...2]
            @lines[0][0].char.should.equal li(0)
            @lines[2][0].char.should.equal li(1)

        it 'inserting two lines in the middle should make room', ->
            @sb.insert_lines(2, 2)
            @lines[i][0].should.eql @dc for i in [1..2]
            @lines[0][0].char.should.equal li(0)
            @lines[3][0].char.should.equal li(1)


    describe 'insert_lines with scroll region set', ->
            
        beforeEach ->
            @sb.set_scroll_region(TOP, BOTTOM)

        it 'should start out with lines in their right places', ->
            @lines[i][0].char.should.equal li(i) for i in @range

        it 'inserting one line at the bottom of the screen should be ignored', ->
            @sb.insert_lines(HEIGHT, 1)
            @lines[i][0].char.should.equal li(i) for i in @range

        it 'inserting one line at the top of the screen should be ignored', ->
            @sb.insert_lines(1, 1)
            @lines[i][0].char.should.equal li(i) for i in @range

        it 'inserting one line at the bottom of the scroll region should add just one line', ->
            @sb.insert_lines(BOTTOM, 1)
            @lines[i][0].char.should.equal li(i) for i in [0...BOTTOM-1]
            @lines[BOTTOM-1][0].should.eql @dc
            @lines[i][0].char.should.equal li(i) for i in [BOTTOM...HEIGHT]

        it 'inserting two lines at the bottom should add just one line', ->
            @sb.insert_lines(BOTTOM, 2)
            @lines[i][0].char.should.equal li(i) for i in [0...BOTTOM-1]
            @lines[BOTTOM-1][0].should.eql @dc
            @lines[i][0].char.should.equal li(i) for i in [BOTTOM...HEIGHT]

        it 'inserting one line at the top of the scroll region should add just one line', ->
            @sb.insert_lines(TOP, 1)
            @lines[i][0].char.should.equal li(i) for i in [0...TOP-1]
            @lines[TOP-1][0].should.eql @dc
            @lines[i][0].char.should.equal li(i)-1 for i in [TOP...BOTTOM]
            @lines[i][0].char.should.equal li(i) for i in [BOTTOM...HEIGHT]

        it 'inserting two lines at the top of the scroll region should add two lines', ->
            @sb.insert_lines(TOP, 2)
            @lines[i][0].char.should.equal li(i) for i in [0...TOP-1]
            @lines[TOP-1][0].should.eql @dc
            @lines[TOP][0].should.eql @dc
            @lines[i][0].char.should.equal li(i)-2 for i in [TOP+1...BOTTOM]
            @lines[i][0].char.should.equal li(i) for i in [BOTTOM...HEIGHT]
                        
        it 'inserting three lines at the top should clear the scroll region', ->
            @sb.insert_lines(TOP, BOTTOM-TOP+1)
            @lines[i][0].char.should.equal li(i) for i in [0...TOP-1]
            @lines[i][0].should.eql @dc for i in [TOP-1...BOTTOM]
            @lines[i][0].char.should.equal li(i) for i in [BOTTOM...HEIGHT]

        it 'inserting one line in the middle should make room', ->
            @sb.insert_lines(TOP+1, 1)
            @lines[i][0].char.should.equal li(i) for i in [0...TOP]
            @lines[TOP][0].should.eql @dc
            @lines[i][0].char.should.equal li(i)-1 for i in [TOP+1...BOTTOM]
            @lines[i][0].char.should.equal li(i) for i in [BOTTOM...HEIGHT]



                                        
            
            
