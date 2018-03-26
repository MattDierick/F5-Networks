var mongoose = require('mongoose');
var Schema   = mongoose.Schema;

var ACLSchema   = new Schema({
  "name":             String,
  "aclOrder":         Number,
  "locationSpecific": {type : Boolean, default : true},
  "pathMatchCase":    {type : Boolean, default : true},
  "type":             { type : String, default : "static" },
  "entries": [
    {
      "action":       { type : String, default : "reject" },
      "dstEndPort":   Number,
      "dstStartPort": Number,
      "dstSubnet":    String,
      "log":          { type : String, default : "none" },
      "protocol":     { type : Number, default : 0 },
      "scheme":       { type : String, default : "any" },
      "srcEndPort":   { type : Number, default : 0},
      "srcStartPort": { type : Number, default : 0},
      "srcSubnet":    { type : String, default : "0.0.0.0/0" }
    }
  ]
}, { collection: 'acls' });

mongoose.model('ACL', ACLSchema);
