var mongoose = require('mongoose');
var Schema   = mongoose.Schema;

var NetworkLocation   = new Schema({
  "name": String,
  "type": { type : String},
  "records": [
    {
      "name": String,
	"data": String
    }]
}, { collection: 'networklocation' });

mongoose.model('NetworkLocation', NetworkLocation);
