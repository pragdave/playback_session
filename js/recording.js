var Recording;

(typeof exports !== "undefined" && exports !== null ? exports : window).Recording = Recording = (function() {
  function Recording() {}

  Recording.load = function(recording_name, callback) {
    console.log("loading " + recording_name);
    return jQuery.ajax({
      url: recording_name,
      dataType: "jsonp",
      jsonpCallback: "the_recording_data"
    }).done(function(data, textStatus) {
      return callback(Recording.add_elapsed(data));
    }).fail(function(jqxhr, settings, exception) {
      return console.log(exception);
    });
  };

  Recording.inline = function(element, callback) {
    return callback(Recording.add_elapsed(JSON.parse(element.find("script").html())));
  };

  Recording.save = function(data, callback) {
    console.log("saving " + data.recording_name);
    return jQuery.ajax({
      url: "/sessions/" + data.recording_name,
      type: "POST",
      data: data,
      dataType: "json"
    }).done(function(data, textStatus) {
      return callback("OK");
    }).fail(function(jqxhr, settings, exception) {
      console.log(exception);
      return callback(exception);
    });
  };

  Recording.add_elapsed = function(data) {
    var elapsed, row, _i, _len, _ref;
    elapsed = 0;
    _ref = data.stream;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      row.elapsed = elapsed;
      elapsed += row.d;
    }
    return data;
  };

  Recording.calculate_times = function(data) {
    var last;
    this.add_elapsed(data);
    last = data.stream[data.stream.length - 1];
    return last.elapsed + last.d;
  };

  return Recording;

})();
