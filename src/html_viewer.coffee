(exports ? window).HtmlViewer =
class HtmlViewer

    EMPTY_ATTR: new ScreenBuffer.Attrs
    
    constructor: (@dom, @screen_buffer) ->
        @lines = ($("<pre>&nbsp;</pre>") for line in [1..@screen_buffer.height])
        @dom.html(@lines)
        @update()

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
            result.push cell.char
            attr = cell.attrs
        result.push("</span>")
        result.join("")

    add_attributes: (result, from, to) ->
        return if from == to
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

