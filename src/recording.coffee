(exports ? window).Recording =
class Recording

    @load: (recording_name, callback) ->
        console.log("loading #{recording_name}")
        jQuery.ajax
            url: recording_name
            dataType: "jsonp"
            jsonpCallback: "the_recording_data"
        .done((data, textStatus) ->
             callback(Recording.add_elapsed(data)))
        .fail((jqxhr, settings, exception) -> console.log(exception))

    @save: (data, callback) ->
        console.log("saving #{data.recording_name}")
        jQuery.ajax
            url: "/sessions/" + data.recording_name
            type: "POST"
            data: data
            dataType: "json"
        .done((data, textStatus) ->
             callback("OK"))
        .fail((jqxhr, settings, exception) ->
            console.log(exception)
            callback(exception))

    @add_elapsed: (data) ->
        elapsed = 0
        for row in data.stream
            row.elapsed = elapsed
            elapsed += row.d
        data

    # update the elapsed time, and return the maximum value
    @calculate_times: (data) ->
        @add_elapsed(data)
        last = data.stream[data.stream.length-1]
        last.elapsed + last.d
        
