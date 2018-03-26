var mongoose = require('mongoose');
var Schema   = mongoose.Schema;

var UrlcategorySchema   = new Schema({
  name            : { type: String, unique: true },
  catNumber       : Number,
  defaultAction   : String,
  displayName     : String,
  isCustom        : Boolean,
  isRecategory    : Boolean,
  parentCatNumber : Number,
  severityLevel   : Number,
  urls            : [{name: 'string' , type : { type : String }}]  //type requiered as mongoose doesnt like type param
}, { collection: 'url-category' });

//schema to keep a counter of category number if we need to create new ones
var catNumberSchema = Schema({
    _id         : { type: String, required: true},
    seq         : { type: Number, default: 1901 }   //should be 1900
}, { collection: 'counters' });

mongoose.model('Urlcategory', UrlcategorySchema);
mongoose.model('catNumber', catNumberSchema);

/*
//mutating save to support increment on catNumber and do nothing if category already exist
UrlcategorySchema.pre('save', function(next) {
  var doc = this;

  Urlcategory.find({name : doc.name}, function (err, docs) {
    if (!docs.length) {
      //urlcategory does not exist
      //so we update catNumber
      catNumber.findByIdAndUpdate({_id: 'catNumber'}, {$inc: { seq: 1} }, function(error, catNumber)   {
        if(error)
          return next(error);
          doc.catNumber = catNumber.seq;
          next();
      });
    } else {
      // urlcategory already exists
      console.log('urlcategory already exists: ',doc.name);
      return next(new Error("Error: urlcategory already exists!"));
    }
  });
});
*/
