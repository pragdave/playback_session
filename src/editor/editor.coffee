(exports ? window).Editor =
class Editor

    json_validator = (value, callback) ->
        result = try
                    JSON.parse(value)
                    true
                 catch e
                    console.log(value)
                    console.log(e) 
                    false
        callback(result)

    handle_update: (changes, reason) =>
        return if reason is "loadData" or reason is "default"
        for [ row, col, oldVal, newVal ] in changes
            if col == 1
                 newVal = JSON.parse(newVal) if col == 1
                 @stream[row].val = newVal
             else
                 @stream[row].d = newVal
                 
        @player.data_updated(changes[changes.length-1][0])  # row number of last change
    handle_supply_defaults: (changes, reason) =>
        return if reason == "loadData"
        for [ row, col, oldVal, newVal ], i in changes
            changes[i][2] = 0    if col is 0 and not oldVal
            changes[i][2] = '""' if col is 1 and not oldVal
        
        
    handle_remove_row: (row, count) =>
        @stream.splice(row, count)
        @player.data_updated(row)
        
    handle_create_row: (row, count) =>
        @stream.splice(row, 0, { d: 0, op: "" }) for _ in [1..count]
        @handson.setDataAtCell(row, 0, 0,    "default")
        @handson.setDataAtCell(row, 1, '""', "default")
        @player.data_updated(row)
        
    constructor: (@player) ->
        @stream = @player.stream
        @editor = $("#editor")
        @editor.show()
        @table = @editor.find("#editor-table")

        mapped_stream = ([data.d, JSON.stringify(data.val)] for data in @stream)
        
        @table.handsontable
            allowInvalid: true
            contextMenu: ['row_above', 'row_below', 'remove_row' ]
            colHeaders:  [ 'Delay', 'Content' ]
            colWidths:   [ null, 400 ]
            data:        mapped_stream
            height:      @table.height()
            beforeCreateRow: @handle_supply_defaults
            afterChange:     @handle_update
            afterRemoveRow:  @handle_remove_row
            afterCreateRow:  @handle_create_row
            currentRowClassName: 'current-row'
            columns: [
                { type: 'numeric' }
              ,
                { type: 'text', validator: json_validator }
            ]

        @handson = @table.handsontable('getInstance')
        
        $(document).on(Player.EV_STEP, (event, n) =>
            @handson.selectCell n, 0
        )
        

