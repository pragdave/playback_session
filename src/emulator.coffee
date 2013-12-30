(exports ? window).Emulator =
class Emulator              
    constructor: (@dom_terminal, @sb, @html) ->
      @line = @col = 1
      @attr = new ScreenBuffer.Attrs()
      console.log "Screen is #{@sb.width} x #{@sb.height}"
      
    update: ->
        @html.update()
        
    echo_char: (char, args) ->
        [@line, @col] = @sb.put(char, @attr, @line, @col)
        
    bs: (char, args) ->
        @col -= 1
        @normalize_col()

    cr: (char, args) ->
        @col = 1
                
    nl: (char, args) ->
        @newline(1)

    ht: (char, args) ->
        @col = 8*(((@col-1)/8) >> 0) + 9
        @normalize_col()

        
    cuu: (char, args) ->
        @line -= (args[0] || 1)
        @normalize_line()
        
    cud: (char, args) ->
        @newline(args[0] || 1)

    cuf: (char, args) ->
        @col += (args[0] || 1)
        @normalize_col()
        
    cub: (char, args) ->
        @col -= (args[0] || 1)
        @normalize_col()
        
    cnl: (char, args) ->
        @col = 1
        @cud(char, args)

    cpl: (char, args) ->
        @col = 1
        @cuu(char, args)

        
    cha: (char, args) ->
        @col = args[0] || @col
        @normalize_col()

    cup: (char, args) ->
        @line = args[0] || 1
        @col  = args[1] || 1
        @normalize_line()
        @normalize_col()
        

        
    ed:  (char, args) ->
        arg = args[0] || 0
        if arg == 0
            @sb.clear([@line, @col], [@sb.height, @sb.width])
        else if arg == 1
            @sb.clear([1, 1], [@line, @col])
        else
            @sb.clear([1,1], [@sb.height, @sb.width])
            
    el:  (char, args) ->
        arg = args[0] || 0
        if arg == 0
            @sb.clear([@line, @col], [@line, @sb.width])
        else if arg == 1
            @sb.clear([@line, 1], [@line, @col])
        else
            @sb.clear([@line,1], [@line, @sb.width])
            
        
    su:  (char, args) -> console.log("su(#{args})")
    sd:  (char, args) -> console.log("sd(#{args})")

    sgr: (char, args) ->
        args = [0] if args.length == 0
        for arg in args
            @set_graphic_rendition(arg)
        
    dsr: (char, args) -> console.log("dsr(#{args})")
    scp: (char, args) -> console.log("scp(#{args})")
    rsp: (char, args) -> console.log("rsp(#{args})")
    

    # Helpers

    newline: (count) ->
        while count > 0
            count -= 1
            @line += 1
            if @line > @sb.height
                @line -= 1
                @sb.scroll
        

    normalize_col: ->
        @col = 1 if @col < 1
        @col = @sb.width if @col > @sb.width

    normalize_line: ->
        @line = 1 if @line < 1
        @line = @sb.height if @line > @sb.height
                

    set_graphic_rendition: (arg) ->
        switch (arg)
            when  0 then @attr.reset()
            when  1 then @attr.bold    = true
            when  2 then @attr.bold    = false
            when  3 then @attr.ul      = true
            when  7 then @attr.inverse = true
            when 22 then @attr.bold    = false
            when 24	then @attr.ul      = false
            when 27 then @attr.inverse = false
            when 39 then @attr.fg      = @attr.DEFAULT_FG
            when 49 then @attr.bg      = @attr.DEFAULT_BG
            else switch 
                    when arg in [30..37] then @attr.fg = arg - 30
                    when arg in [40..47] then @attr.bg = arg - 40
