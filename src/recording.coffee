(exports ? window).Recording =
class Recording

    @load: (recording_name, callback) ->
        console.log("loading #{recording_name}")
        jQuery.ajax
            url: recording_name
            dataType: "jsonp"
            jsonpCallback: "the_recording_data"
        .done((data, textStatus) -> callback(data))
        .fail((jqxhr, settings, exception) -> console.log(exception))

