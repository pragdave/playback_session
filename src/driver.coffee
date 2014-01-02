(exports ? window).Driver =
class Driver

    for_recording: (recording_name, dom_terminal) ->
        @load_recording(recording_name, (recording_data) =>
                 @handle_recording_data(recording_data, dom_terminal))

    handle_recording_data: (recording_data, dom_terminal) ->
        data = recording_data.data
        source = Rx.Observable.generateWithRelativeTime(
                     0,                        # initial state
                     (n) -> n < data.length,   # termination condition
                     (n) -> n + 1,             # step function
                     (n) -> data[n][1],        # value returned by iteration
                     (n) -> data[n][0])        # and the time

        sb   = new ScreenBuffer(recording_data.size)
        html = new HtmlViewer(dom_terminal, sb)
        fsm  = new AnsiFSM(new Emulator(dom_terminal, sb, html))

        subscription = source.subscribe(
            (x)   -> fsm.accept_string(x),
            (err) -> console.log('Error: ' + err),
            ()    -> console.log('Completed'))

    load_recording: (recording_name, callback) ->
        console.log("loading #{recording_name}")
        jQuery.ajax
            url: recording_name
            dataType: "jsonp"
            jsonpCallback: "the_recording_data"
        .done((recording_data, textStatus) -> callback(recording_data))
        .fail((jqxhr, settings, exception) -> console.log(exception))


