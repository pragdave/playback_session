(exports ? window).ScreenBuffer =
class ScreenBuffer

    ############################################################

    @Attrs: class Attrs

        DEFAULT_FG: 7
        DEFAULT_BG: 0

        constructor: ->
            @reset()

        reset: ->
            @fg      = @DEFAULT_FG
            @bg      = @DEFAULT_BG
            @bold    = false
            @ul      = false
            @inverse = false

        update_from: (other) ->
            @fg      = other.fg
            @bg      = other.bg
            @bold    = other.bold
            @ul      = other.ul
            @inverse = other.inverse

        is_equal_to: (other) ->
            @eq(other, "fg")   &&
            @eq(other, "bg")   &&
            @eq(other, "bold") &&
            @eq(other, "ul")   &&
            @eq(other, "inverse")

        eq: (other, attr) ->
            mine = @[attr]
            hers = other[attr]
            return true if mine == hers
#            console.log("Attribute mismatch: #{attr} -> #{mine} vs. #{hers}")
            false
        
    ############################################################

    @Cell: class Cell
        constructor: (@char = " ") ->
            @attrs = new Attrs()

    ############################################################

    constructor: ([@height, @width]) ->
        @lines = (@create_line(@width) for i in [1..@height])
        @reset_dirty()

    create_line: (width) ->
        ((c = new Cell(); c.attrs.fg = i; c) for i in [1..width])

    put: (chars, attr, line, col) ->
        line -= 1
        col  -= 1

        c0 = @lines[line][0]
        c10 = @lines[line][10]
        
        for i in [0...chars.length]
            cell = @lines[line][col]
            cell.char = chars.charAt(i)
            cell.attrs.update_from(attr)
        
            @dirty_lines[line] = true
            col += 1
            if col >= @width
                col = 0
                line += 1
                if line >= @height
                    line = @height - 1
                    @scroll_up

        [ line+1, col+1 ]

    dirty: (line) ->
        @dirty_lines[line-1]
        
    scroll_up: ->
        @lines.shift()
        @lines.push(create_line())


    each: ([from_line, from_col], [to_line, to_col], callback) ->
        from_line -= 1; from_col -= 1; to_line -= 1; to_col -= 1
        for line_no in [from_line..to_line]
            line = @lines[line_no]
            start_col = (if line_no == from_line then from_col else 0)
            end_col   = (if line_no == to_line   then to_col else @width-1)
            for col in [start_col..end_col]
                callback(line_no, line[col])

    for_each_dirty_line: (callback) ->
        for line, index in @lines
            callback(index+1, line) if @dirty_lines[index]
        
    fill: (from, to, char) ->
        @each from, to, (line_no, cell) =>
          cell.char  = char.char
          cell.attrs.update_from(char.attrs)
          @dirty_lines[line_no] = true

    clear: (from, to) ->
        @fill(from, to, new Cell())

    reset_dirty: -> 
        @dirty_lines = (false for i in @lines)
       

    dump_to_console: ->
        console.log("dump")
        for line in @lines
            chars = (cell.char for cell in line)
            console.log("|" + chars.join() + "|")
