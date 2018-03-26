var mongoose = require('mongoose');
var Schema   = mongoose.Schema;

var APMSchema   = new Schema({
  name          : String,
  ip            : String,
  username      : String,
  password      : String
}, { collection: 'apmconfig' });

mongoose.model('APM', APMSchema);
