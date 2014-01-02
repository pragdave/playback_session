(exports ? window).Editor =
class Editor

    json_validator: (value, callback) ->
        result = try
                    JSON.parse(value)
                    console.log("ok")
                    true
                 catch e
                    console.log(value)
                    console.log(e) 
                    false
        callback(result)
        
    constructor: (@edit_button) ->
        @editor = $("#editor")
        @edit_button.on "click", (e) =>
            e.preventDefault()
            what_we_are_editing = $($(e.target).data("for"))
            @start_editor(what_we_are_editing)

    start_editor: (what_we_are_editing) ->
        @edit_button.hide()
        source = what_we_are_editing.data("from")
        console.log(source)
        (new Driver()).load_recording source, (recording) =>
            @editor.show()
            console.log("loaded")
            console.log(recording)
            data = ( [ delay, JSON.stringify(string) ] for [delay,string] in recording.data)
            $("#editor-table").handsontable
                allowInvalid: true
                contextMenu: ['row_above', 'row_below', 'remove_row' ]
                colHeaders:  [ 'Delay', 'Content' ]
                colWidths:   [ null, 400 ]
                currentRowClassName: 'current-row'
                data: data
                nativeScrollbars: true
                columns: [
                    { type: 'numeric' }
                  ,
                    { type: 'text', validator: @json_validator }
                ]

        
$ ->
    console.log($(".edit-button"))
    $(".edit-button").each (_, button) ->
        console.log button
        new Editor($(button))
            
