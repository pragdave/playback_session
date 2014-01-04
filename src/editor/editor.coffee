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
        
    constructor: (@player) ->
        @data = @player.data
        @editor = $("#editor")
        @editor.show()
        @table = @editor.find("#editor-table")
        
        data = ([ delay, JSON.stringify(string) ] for [delay,string] in @data)
                         
        @table.handsontable
            allowInvalid: true
#            contextMenu: ['row_above', 'row_below', 'remove_row' ]
            colHeaders:  [ 'Delay', 'Content' ]
            colWidths:   [ null, 400 ]
            currentRowClassName: 'current-row'
            data: data
            height:  @table.height()
            columns: [
                { type: 'numeric' }
              ,
                { type: 'text', validator: @json_validator }
            ]

        @handson = @table.handsontable('getInstance')
        
        $(document).on(Player.EV_STEP, (event, n) =>
            @handson.selectCell n, 0
        )
        

