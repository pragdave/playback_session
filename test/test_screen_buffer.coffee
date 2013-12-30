chai.should()

describe 'ScreenBuffer', ->
    beforeEach ->
        @sb = new ScreenBuffer([4,3])
        @dc = ScreenBuffer.Cell.default_cell()
            
    describe 'constructor', ->
        it 'should remember the width and height', ->
            @sb.width.should.equal 4
            @sb.height.should.equal 3

        it 'should have the right number of lines', ->
            @sb.lines.should.have.length(3)

        it 'should have lines of the correct length', ->
            @sb.lines[i].should.have.length(4) for i in [0..2]

        it 'should have lines containing default cells', ->
            @sb.lines[0][0].should.eql @dc
            @sb.lines[2][3].should.eql @dc
    

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
            @sb.put("ABCD", @dc.attrs, 1, 1).should.eql [2, 1]
            @sb.lines[0][0].char.should.equal "A"
            @sb.lines[0][1].char.should.equal "B"
            @sb.lines[0][2].char.should.equal "C"
            @sb.lines[0][3].char.should.equal "D"

        it 'should support adding in the middle of a line', ->
            @sb.put("AB", @dc.attrs, 2, 2).should.eql [2,4]
            @sb.lines[1][1].char.should.equal "A"
            @sb.lines[1][2].char.should.equal "B"

        it 'should wrap to the next line', ->
            @sb.put("ABCD", @dc.attrs, 2, 2).should.eql [3, 2]
            @sb.lines[1][1].char.should.equal "A"
            @sb.lines[1][2].char.should.equal "B"
            @sb.lines[1][3].char.should.equal "C"
            @sb.lines[2][0].char.should.equal "D"

        it 'should set the dirty flag on all modified lines', ->
            @sb.put("ABCD", @dc.attrs, 2, 2).should.eql [3, 2]
            @sb.dirty(1).should.equal false
            @sb.dirty(2).should.equal true
            @sb.dirty(3).should.equal true

        it 'should not set the dirty flag on a line it wraps to without altering', ->
            @sb.put("ABC", @dc.attrs, 2, 2).should.eql [3, 1]
            @sb.dirty(1).should.equal false
            @sb.dirty(2).should.equal true
            @sb.dirty(3).should.equal false


            
            
