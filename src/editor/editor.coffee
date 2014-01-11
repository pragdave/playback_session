(exports ? window).Editor =
class Editor

    @context_menu = $("""
    <ul id="popup-menu">
      <li id="pu-insert">Insert row</li>
      <li id="pu-delete">Delete row</li>
    </ul>
    """)

    @type_select_menu = $("""
    <select tabIndex='0' class='type-select-menu'>
        <option value='op'>Session output</option>
        <option value='popup'>Popup-window</option>
        <option value='popdown'>Close popup</option>
    </select>");
    """)

    @value_formatter = (row, cell, value, columnDef, dataContext) ->
        switch dataContext.t
            when "op"
                str = JSON.stringify(value)
                str.substr(1, str.length-2)
            else
                value
    
                                
    @columns = [
            id: "type"
            name: "Type"
            field: "t"
            editor: (args) => new RowTypeEditor(args)
          ,
            id: "delay"
            name: "Delay"
            field: "d"
            editor: Slick.Editors.Integer
          ,
            id: "val"
            name: "Value"
            field: "val"
            editor: Slick.Editors.LongText
            formatter: Editor.value_formatter
            width: 200
            
    ]
    
    @options =
        editable: true,
        enableAddRow: true,
        enableCellNavigation: true,
        asyncEditorLoading: false,
        autoEdit: false    
        enableColumnReorder:  false
        fullWidthRows: true
        
    json_validator = (value, callback) ->
        result = try
                    JSON.parse(value)
                    true
                 catch e
                    console.log(value)
                    console.log(e) 
                    false
        callback(result)

    constructor: (@player) ->
        @stream = @player.stream
        @editor = $("#editor")
        @editor.show()
        @table = @editor.find("#editor-table")

        @grid = new Slick.Grid("#editor-table",
                               @stream,
                               Editor.columns,
                               Editor.options)

        @setup_right_click(@grid)

    setup_right_click: (grid) ->
        menu = Editor.context_menu
        grid.onContextMenu.subscribe (e) =>
          e.preventDefault()
          cell = grid.getCellFromEvent(e)
          menu
             .css("top", e.pageY - 16)
             .css("left", e.pageX)
          $("body").prepend(menu)
          $("#pu-insert").on "click", (e) =>
              @insert_row(cell.row)
          $("#pu-delete").on "click", (e) =>
              @delete_row(cell.row)

          $("body").one "click", () ->
            menu.remove()

    insert_row: (row) ->
        new_row =
            t: "op"
            d: 0
            val: ""
        @stream.splice(row, 0, new_row);
        @grid.setData(@stream);
        @grid.render();
        @grid.scrollRowIntoView(row, false);

    delete_row: (row) ->
        @stream.splice(row, 1);
        @grid.setData(@stream);
        @grid.render();
        @grid.scrollRowIntoView(row, false);

class RowTypeEditor

    constructor: (args) ->
        console.log args
        menu = Editor.type_select_menu
        @loadValue(args.item.t)
        menu.appendTo(args.container)
        menu.focus()

    destroy: () ->
        Editor.type_select_menu.remove()

    focus: () ->
        Editor.type_select_menu.focus()

    loadValue: (value) ->
        @default_value = value
        Editor.type_select_menu.val(value)

    applyValue: (row_data, value) ->
         row_data.t = value
    
    serializeValue: () ->
        Editor.type_select_menu.val()

    isValueChanged: () ->
        Editor.type_select_menu.val() != @default_value

    validate: () ->
        valid: true
        msg:   null

#         $(document).on(Player.EV_STEP, (event, n) =>
#             @handson.selectCell n, 0
#         )
        

