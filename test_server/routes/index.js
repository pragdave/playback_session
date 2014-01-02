var fs = require('fs');

exports.index = function(req, res) {
  var files = fs.readdirSync(session_dir);
  res.render('index', { title: 'Available Test Sessions', files: files });
};


exports.show = function(req, res){
    res.render('show', {session_name: req.params.session_name});
};

exports.session = function(req, res){
    res.set('Content-Type', 'application/json');
    res.send(fs.readFileSync(session_dir + "/" + req.params.session_name));
};
