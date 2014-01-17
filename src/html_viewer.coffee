(exports ? window).HtmlViewer =
class HtmlViewer

    EMPTY_ATTR: new ScreenBuffer.Attrs
    
    constructor: (@playback_window, @screen_buffer) ->
        @dom = $("<pre class=\"terminal\"></pre>")
        char = $('<pre><span id="wibble">M</span></pre>')
        @lines = ($("<pre>&nbsp;</pre>") for line in [1..@screen_buffer.height])
        @dom.append(@lines)
        @dom.append(char)
        @playback_window.prepend(@dom)
        and_then = =>
                width = $("#wibble").width()
                @playback_window.css('width', (width * @screen_buffer.width + 48) + 'px')
                char.remove()
                @update()
        setTimeout(and_then, 0)

    update: ->
        @screen_buffer.for_each_dirty_line @update_line

    update_line: (line_number, line) =>
        dom_line = @lines[line_number - 1]
        dom_line.html(@html_from(line))

    html_from: (line) ->
        attr = new ScreenBuffer.Attrs
        result = [ "<span>" ]
        for cell in line
            @add_attributes(result, attr, cell.attrs)
            result.push @escape(cell.char)
            attr = cell.attrs
        result.push("</span>")
        result.join("")

    escape: (char) ->
        switch char
            when "<" then "&lt;"
            when "&" then "&amp;"
            else char
            
    add_attributes: (result, from, to) ->
        return if from.is_equal_to(to)
        result.push("</span>")
        css_attrs = []
        css_attrs.push("b_") if to.bold
        css_attrs.push("u_") if to.ul

        [ f, b ] = if to.inverse
            [ to.bg, to.fg ]
        else
            [ to.fg, to.bg ]

        css_attrs.push "f#{f}_"
        css_attrs.push "b#{b}_"

        result.push "<span class=\"#{css_attrs.join(' ')}\">"

