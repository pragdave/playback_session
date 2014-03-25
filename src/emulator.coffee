(exports ? window).Emulator =
class Emulator              
    constructor: (@dom_terminal, @sb, @html) ->
      [@line, @col] = @primary_cursor = [1, 1]
      @alternate_cursor = [1, 1]
      @use_primary_cursor()
      @attr = new ScreenBuffer.Attrs()

    save: ->
        primary_cursor:   @primary_cursor.slice(0)  # force new copy
        alternate_cursor: @alternate_cursor.slice(0)
        line:             @line
        col:              @col
        attr:             @attr

    load_from: (state) ->
        @line = state.line
        @col  = state.col
        @primary_cursor = state.primary_cursor
        @alternate_cursor = state.alternate_cursor
        @attr = state.attr

    update: ->
        @html.update()
        
    echo_char: (char, args) ->
        [@line, @col] = @sb.put(char, @attr, @line, @col)
        
    bs: (_char, _args) ->
        @col -= 1
        @normalize_col()

    cr: (_char, _args) ->
        @col = 1
                
    nl: (_char, _args) ->
        @newline(1)

    ht: (_char, _args) ->
        @col = 8*(((@col-1)/8) >> 0) + 9
        @normalize_col()

    ich: (_char, args) ->
        count = args[0] || 1
        @preserve_cursor =>
            (@echo_char(" ", @attr) for i in [1..count])
        @update()
                
    cuu: (_char, args) ->
        @line -= (args[0] || 1)
        @normalize_line()
        
    cud: (_char, args) ->
        @newline(args[0] || 1)

    cuf: (_char, args) ->
        @col += (args[0] || 1)
        @normalize_col()
        
    cub: (_char, args) ->
        @col -= (args[0] || 1)
        @normalize_col()
        
    cnl: (char, args) ->
        @col = 1
        @cud(char, args)

    cpl: (char, args) ->
        @col = 1
        @cuu(char, args)

        
    cha: (_char, args) ->
        @col = args[0] || @col
        @normalize_col()

    cup: (_char, args) ->
        @line = args[0] || 1
        @col  = args[1] || 1
        @normalize_line()
        @normalize_col()
        
    vpa: (_char, args) ->
        @line = args[0] || 1
        @normalize_line
        
    ed:  (_char, args) ->
        arg = args[0] || 0
        if arg == 0
            @sb.clear([@line, @col], [@sb.height, @sb.width])
        else if arg == 1
            @sb.clear([1, 1], [@line, @col])
        else
            @sb.clear([1,1], [@sb.height, @sb.width])
        @update()
            
    el:  (_char, args) ->
        arg = args[0] || 0
        if arg == 0
            @sb.clear([@line, @col], [@line, @sb.width])
        else if arg == 1
            @sb.clear([@line, 1], [@line, @col])
        else
            @sb.clear([@line,1], [@line, @sb.width])
        @update()
            
    il: (_char, args) ->
        count = args[0] || 1
        @sb.insert_lines(@line, count)
        @col = 0
        @update()
                
    su:  (_char, args) -> console.log("su(#{args})")
    sd:  (_char, args) -> console.log("sd(#{args})")

    sgr: (_char, args) ->
        args = [0] if args.length == 0
        while args.length > 0
            args = @set_graphic_rendition(args)

    decstbm: (_char, args) ->
        @scroll_top    = args[0] || 1
        @scroll_bottom = args[1] || @sb.height
        @sb.set_scroll_region(@scroll_top, @scroll_bottom)
        
    dsr: (_char, args) -> console.log("dsr(#{args})")
    scp: (_char, args) -> console.log("scp(#{args})")
    rsp: (_char, args) -> console.log("rsp(#{args})")

    # private mode

    rm: (_char, args) ->
        switch args[0]
            when    1 then null   # application cursor keys
            when   12 then null   # blinking cursor
            when   25 then null   # show/hide cursor
            when   47 then @use_primary_buffer()
            when 1048 then @use_primary_cursor()              

            when 1049
                @use_primary_cursor()
                @use_primary_buffer()
                                                 
            else console.log("Unsupported rm #{args[0]}")

    sm: (_char, args) ->
        switch args[0]
            when    1 then null   # application cursor keys
            when   12 then null   # blinking cursor
            when   25 then null   # show/hide cursor
            when   47 then @use_alternate_buffer()
            when 1048 then @use_alternate_cursor()
            when 1049
                @use_alternate_cursor()
                @use_alternate_buffer()
                
            else console.log("Unsupported sm #{args[0]}")

    # Helpers


    newline: (count) ->
        while count > 0
            count -= 1
            @line += 1
            if @line >= @sb.height
                @line -= 1
                @sb.scroll_up()
        
    preserve_cursor: (func) ->
        [l, c] = [@line, @col]
        func()
        [@line, @col] = [l, c]
        
    normalize_col: ->
        @col = 1 if @col < 1
        @col = @sb.width if @col > @sb.width

    normalize_line: ->
        @line = 1 if @line < 1
        @line = @sb.height if @line > @sb.height
                
    use_primary_buffer: ->
        @sb.use_primary()
        @update()

    use_alternate_buffer: ->
        @sb.use_alternate()
        @update()

    use_alternate_cursor: ->
        @primary_cursor = [ @line, @col ]
        [ @line, @col ] = @alternate_cursor
        
    use_primary_cursor: ->
        @alternate_cursor = [ @line, @col ]
        [ @line, @col ] = @primary_cursor
        
        
    set_graphic_rendition: (args) ->
        arg = args.shift()
        switch arg
            when  0 then @attr.reset()
            when  1 then @attr.bold    = true
            when  2 then @attr.bold    = false
            when  4 then @attr.ul      = true
            when  7 then @attr.inverse = true
            when 22 then @attr.bold    = false
            when 24	then @attr.ul      = false
            when 27 then @attr.inverse = false
            when 39 then @attr.fg      = @attr.DEFAULT_FG
            when 49 then @attr.bg      = @attr.DEFAULT_BG
            when 38, 48
                flag = args.shift()
                if flag != 5
                    console.log("Expecting 5 after csi 38/48, got #{flag}")
                color = args.shift()
                if arg == 38
                    @attr.fg = color
                else
                    @attr.bg = color

            else switch 
                    when arg in [30..37] then @attr.fg = arg - 30
                    when arg in [40..47] then @attr.bg = arg - 40
                    else console.log("Unknown sgr #{arg}")
        args



        
