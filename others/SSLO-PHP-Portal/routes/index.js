var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
require('../models/Urlcategory');
require('../models/User');
require('../models/Groups');
require('../models/Apm');
require('../models/Acls');
require('../models/networklocation');
var Urlcategory = mongoose.model('Urlcategory');
var User = mongoose.model('User');
var Group = mongoose.model('Group');
var APM = mongoose.model('APM');
var ACL = mongoose.model('ACL');
var NetworkLocation = mongoose.model('NetworkLocation');

var passport = require('passport');
var jwt = require('express-jwt');
var auth = jwt({secret: 'MYDIRTYSECRETSTATICINMYCODE', userProperty: 'payload'});
var request = require('request');
var async = require('async');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'APM Portal' });
});
router.get('/index.html', function(req, res, next) {
  res.render('index', { title: 'APM Portal' });
});
// routing for angular templates
router.get('/acls.html', function(req, res, next) {
  res.render('acls', { title: 'APM Portal' });
});

router.get('/editacl.html', function(req, res, next) {
  res.render('editacl', { title: 'APM Portal' });
});

router.get('/categories.html', function(req, res, next) {
  res.render('categories', { title: 'APM Portal' });
});

router.get('/urlcategories.html', function(req, res, next) {
  res.render('urlcategories', { title: 'APM Portal' });
});

router.get('/login.html', function(req, res, next) {
  res.render('login', { title: 'APM Portal' });
});
router.get('/register.html', function(req, res, next) {
  res.render('register', { title: 'APM Portal' });
});
router.get('/editgroups.html', function(req, res, next) {
  res.render('editgroups', { title: 'APM Portal' });
});
router.get('/groupcategory.html', function(req, res, next) {
  res.render('groupcategory', { title: 'APM Portal' });
});
router.get('/apmmgt.html', function(req, res, next) {
  res.render('apmmgt', { title: 'APM Portal' });
});
router.get('/networklocation.html', function(req, res, next) {
  res.render('networklocation', { title: 'APM Portal' });
});
router.get("/ping", function(req, res, next){
  APM.findOne({'name':"myapm"},  function (err, apm) {
    if (err) { return (JSON.stringify(err)) }
    var options = {
      url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/apm",
      method: 'GET',
      strictSSL : false, //no certificate validation
      rejectUnauthorized : false //no certificate validation
    };
    request(options, function (error, response, body) {
      if (!error  && response.statusCode == 200) {
        return res.json("{OK}");
      } else { return res.json("{KO}");
      }
    });
  })//apm findone
});
router.get("/networklocations", function(req, res, next){
  //looking for network locations, name coded in the call ...
  NetworkLocation.findOne({ 'name':"networklocation" }, function(err, networklocation) {
        if(err){ return next(err); }
          res.json(networklocation);
      }
  );
});
router.get("/apmnetworklocations", function(req, res, next){
  //looking for network locations, name coded in the call ...
    APM.findOne({'name':"myapm"},  function (err, apm) {
      if (err) { return (JSON.stringify(err)) }
      var options = {
        url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/ltm/data-group/internal/DG_FQDN",
        method: 'GET',
        strictSSL : false, //no certificate validation
        rejectUnauthorized : false //no certificate validation
      };
      console.log("sending GET request to APM for network location");
      request(options, function (error, response, body) {
        if (!error  && response.statusCode == 200) {
          console.log("apm GET all nework location done");
          NetworkLocation.findOneAndUpdate({ 'name': "networklocation"},
            { $set: {"records": JSON.parse(body).records }},       //update to be done
            {  safe: true, upsert: true, new: true }, //options new : true returns modified doc
               function(err, networklocation) {
                console.log("inserting new networklocation records");
                res.json(networklocation);
               });
        } else {
          console.log("error found while retrieving category from APM ...");
          res.json("{KO}");
        } //end if error
      }); //end request

    });//end APM findone
});//end router get

//adding a network location to db
router.post("/apmnetworklocations", function(req, res, next){
  NetworkLocation.findOneAndUpdate({ 'name':"networklocation" },
            { $push: {"records": req.body }},
            {  safe: true, upsert: true, new: true },function(err, networklocation) {
        if(err){ return next(err); }
        res.json(networklocation);
      }
  );

});//end post network location

//put all network locations to APM
router.put("/apmnetworklocations", function(req, res, next){
  //looking for network locations, name coded in the call ...
    APM.findOne({'name':"myapm"},  function (err, apm) {
      if (err) { return (JSON.stringify(err)) }
      var options = {
        url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/ltm/data-group/internal/DG_FQDN",
        method: 'PUT',
        json : {"records": ""},
        strictSSL : false, //no certificate validation
        rejectUnauthorized : false //no certificate validation
      };
      console.log("sending put request to APM  network location");
      NetworkLocation.findOne({ 'name':"networklocation" } ,function(err, networklocation) {
            if(err){ return next(err); }

            options.json = {"records" : networklocation.records}; //setting request payload
            request(options, function (error, response, body) {
              if (!error  && response.statusCode == 200) {
                console.log("apm put Nework locations done");
                res.json(response.body);

              } else {
                console.log("error found while  pushing Network Locations to APM ...");
                res.json("{KO}");
              } //end if error
            }); //end request
          }
      );// end findone
    });//end APM findone
});//end router put

router.delete('/networklocations/:id1', auth, function(req, res, next) {
  NetworkLocation.findOneAndUpdate({ 'name':"networklocation" },
            { $pull: {"records": {"_id": req.params.id1} }},
            {  safe: true, upsert: true, new: true },function(err, networklocation) {
        if(err){ return next(err); }
        res.json(networklocation);
      }
  );
});

router.get("/apmconfig", function(req, res, next){
  //looking for entry for APM config, name coded in the call ...
  APM.findOne({ 'name':"myapm" }, function(err, apmconfig) {
        if(err){ return next(err); }
          res.json(apmconfig);
      }
  );
});

router.post('/apmconfig', function(req, res, next){
  APM.findOneAndUpdate({ 'name':req.body.name },
    { $set : {"ip"       : req.body.ip ,
              "password" : req.body.password ,
              "username" : req.body.username }
    },  {new: true }, function(err, apmconfig) {
        if(err){ return next(err); }
          res.json(apmconfig);
      }
  );

});



//routing for passport authentication
router.post('/login', function(req, res, next){
  if(!req.body.username || !req.body.password){
    return res.status(400).json({message: 'Please fill out all fields'});
  }

  passport.authenticate('local', function(err, user, info){
    if(err){ return next(err); }

    if(user){
      return res.json({token: user.generateJWT()});
    } else {
      return res.status(401).json(info);
    }
  })(req, res, next);
});

router.post('/register', function(req, res, next){
  if(!req.body.username || !req.body.password || !req.body.group){
    return res.status(400).json({message: 'Please fill out all fields'});
  }

  var user = new User();
  user.username = req.body.username;
  user.group = req.body.group;
  user.isadmin = req.body.isadmin;
  user.setPassword(req.body.password);
  user.save(function (err){
    if(err){
      console.log("Error Registering new user in DB");
      if (err.code == 11000) {return res.status(400).json({message: 'User already exists in DB'})}
      else {return next(err)};
    }
    return res.json({token: user.generateJWT()})
  });
} );

router.param('group', function(req, res, next, id) {
  var query = Group.findById(id);

  query.exec(function (err, group){
    if (err) { return next(err); }
    if (!group) { return next(new Error('can\'t find group')); }

    req.group = group;

    return next();
  });
});

// routing for apm deleg portal

router.get('/acls', auth, function(req, res, next) {
  //we ask to retrieve user's group
  User.findOne({ username: req.payload.username },'username group', function (err, user) {
   if (err) { return next(err) }
    console.log("Logged user "+user.username + " group is " + user.group);
    //then we find group definition containing allowed categories for group user
    Group.findOne({name: user.group}, function (err, group) {
     if (err) { return (err) }
      //find acl in db belonging to that group
      ACL.find({'name': { $in : group.acl }}, function(err, acls){
        if(err){   return next(err); }
        //by filtering urlcategories
        res.json(acls);
      });
    });
  });


});


router.param('urlcategory', function(req, res, next, id) {
  var query = Urlcategory.findById(id);

  query.exec(function (err, urlcategory){
    if (err) { return next(err); }
    if (!urlcategory) { return next(new Error('can\'t find urlcategory')); }

    req.urlcategory = urlcategory;

    return next();
  });
});

router.get('/urlcategories', auth, function(req, res, next) {
  //we ask to retrieve user's group
  User.findOne({ username: req.payload.username },'username group', function (err, user) {
   if (err) { return next(err) }
    console.log("Logged user "+user.username + " group is " + user.group);
    //then we find group definition containing allowed categories for group user
    Group.findOne({name: user.group}, function (err, group) {
     if (err) { return (err) }
      //find category in db belonging to that group
      Urlcategory.find({'name': { $in : group.category }}, function(err, urlcategories){
        if(err){   return next(err); }
        //by filtering urlcategories

        res.json(urlcategories);
      });
    });
  });


});

//adding url to a category
router.put('/urlcategories/:urlcategory', auth, function(req, res, next) {
  var modification = {"name": req.body.url, "type": "glob-match"};

  req.urlcategory.urls.push(modification);
  req.urlcategory.save(function(err) {
    if(err){ return next(err); }
    return res.json(req.urlcategory);
  });

});

//update to apm one category
router.get('/updateapmcategory/:urlcategory', auth, function(req, res, next) {
  //removing mango _id property
  for (var i = 0; i < req.urlcategory.urls.length; i++) {
    delete req.urlcategory.urls[i]._id
  }
  APM.findOne({'name':"myapm"},  function (err, apm) {
    if (err) { return (JSON.stringify(err)) }

    var options = {
      url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/sys/url-db/url-category/~Common~"+req.urlcategory.name,
      method: 'PATCH',
      json : {"urls": req.urlcategory.urls}, //post the urls array in json
      strictSSL : false, //no certificate validation
      rejectUnauthorized : false //no certificate validation
    };
    console.log("sending patch request to APM");
    request(options, function (error, response, body) {
        if (!error  && response.statusCode == 200) {
          console.log("apm change done");
          res.json("{OK}");
        } else {
          console.log("error found sending category to APM ...");
          res.json(error || response.body );
        }
    })
  });
});
//retrieve a category configuration from apm
router.get('/getapmcategory/:urlcategory', auth, function(req, res, next) {
  APM.findOne({'name':"myapm"},  function (err, apm) {
    if (err) { return (JSON.stringify(err)) }

    var options = {
      url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/sys/url-db/url-category/~Common~"+req.urlcategory.name,
      method: 'GET',
      strictSSL : false, //no certificate validation
      rejectUnauthorized : false //no certificate validation
    };
    console.log("sending GET request to APM");
    request(options, function (error, response, body) {
        if (!error  && response.statusCode == 200) {
          console.log("apm GET done");
          //updating mangodb
          req.urlcategory.urls=JSON.parse(body).urls;
          req.urlcategory.save();
          //sending response
          res.json(req.urlcategory.urls);
        } else {
          console.log("error found while retrieving category from APM ...");
          res.json("{KO}");
        }
    })
  });
});

//bulk operation retrieve all APM categories, ACLS and overwrite
router.get('/getapmcategories', auth, function(req, res, next) {
  APM.findOne({'name':"myapm"},  function (err, apm) {
    if (err) { return (JSON.stringify(err)) }

    var options = {
      url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/sys/url-db/url-category/",
      method: 'GET',
      strictSSL : false, //no certificate validation
      rejectUnauthorized : false //no certificate validation
    };
    console.log("sending GET request to APM for all categories");
    request(options, function (error, response, body) {
        if (!error  && response.statusCode == 200) {
          console.log("apm GET all category done");
                    //removing default categories Uncategorized and User-Defined
          var tmp = JSON.parse(body).items.filter(function( item){
            return ((item.name !="Uncategorized") && (item.name !="User-Defined")) ;
          }
        );

        //now overwritting mongodb
        //droping the table
        //no error checking here
        var urlcategories=[];
        console.log("before :"+urlcategories);
        Urlcategory.collection.drop( function(err) {
          console.log('MongoDB collection Urlcategory dropped');
          //now inserting

          async.each (tmp, function(tmpcategory, next){
            newcategory = new Urlcategory();
            newcategory.name             = tmpcategory.name;
            newcategory.catNumber        = tmpcategory.catNumber;
            newcategory.defaultAction    = tmpcategory.defaultAction;
            newcategory.displayName      = tmpcategory.displayName;
            newcategory.isCustom         = tmpcategory.isCustom;
            newcategory.isRecategory     = tmpcategory.isRecategory;
            newcategory.parentCatNumber  = tmpcategory.parentCatNumber;
            newcategory.severityLevel    = tmpcategory.severityLevel;
            newcategory.urls             = tmpcategory.urls
            newcategory.save( function(err,newcategory){
              urlcategories.push(newcategory);
              next();
            });
          }, function(){
            //al done
            //updating allcategories group with acces to all categories
            var allcategoriesgroup =[];
            for (var i = 0; i < urlcategories.length; i++) {
              allcategoriesgroup.push(urlcategories[i].name);
            }
            Group.findOneAndUpdate({ 'name': "allcategories"},
              { $set: {"category": allcategoriesgroup }},       //update to be done
              {  safe: true, upsert: true, new: true }, //options new : true returns modified doc
                 function(err) {
                    if(err){ return next(err); }
                    Group.update({"name":{ $ne : "allcategories"}},  {"category": []}, {multi: true}, function(err) {
                      //need to modify existing other groups
                      if(err){ return next(err); }
                      //res.json("{Portal DB updated}");
                      nowupdateacls();
                    });

                 }
              );

          });


        });
        } else {
          console.log("error found while retrieving category from APM ...");
          res.json("{KO}");
        }
    });

    nowupdateacls = function () {
      //doing the same for acls
      var options2 = {
        url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/apm/acl/",
        method: 'GET',
        strictSSL : false, //no certificate validation
        rejectUnauthorized : false //no certificate validation
      };
      console.log("sending GET request to APM for all ACLs");
      request(options2, function (error, response, body) {
          if (!error  && response.statusCode == 200) {
          console.log("apm GET all acl done");


          //now overwritting mongodb
          //droping the table
          //no error checking here
          var acls=[];
          console.log("before :"+acls);
          ACL.collection.drop( function(err) {
            console.log('MongoDB collection ACL dropped');
            //now inserting
            var tmp = JSON.parse(body).items;
            async.each (tmp, function(tmpacl, next){
              newacl = new ACL();
              newacl.name             = tmpacl.name;
              newacl.aclOrder         = tmpacl.aclOrder;
              newacl.locationSpecific = tmpacl.locationSpecific;
              newacl.pathMatchCase    = tmpacl.pathMatchCase;
              newacl.type             = tmpacl.type;
              newacl.entries          = tmpacl.entries;
              newacl.save( function(err,newacl){
                acls.push(newacl);
                next();
              });
            }, function(){
              //all done
              //updating allcategories group with acces to all acls
              var allaclsgroup =[];
              for (var i = 0; i < acls.length; i++) {
                allaclsgroup.push(acls[i].name);
              }
              Group.findOneAndUpdate({ 'name': "allcategories"},
                { $set: {"acl": allaclsgroup }},       //update to be done
                {  safe: true, upsert: true, new: true }, //options new : true returns modified doc
                   function(err) {
                      if(err){ return next(err); }
                      Group.update({"name" :{ $ne : "allcategories"}}, {"acl": []}, {multi: true}, function(err) {
                        //need to modify existing other groups
                        if(err){ return next(err); }
                        res.json("{Portal DB updated}");
                      });
                   }
                );
            });
          });
          } else {
            console.log("error found while retrieving acls from APM ...");
            res.json("{KO}");
          }
      })
    } //end definition nowupdateacls


  });
});

router.get('/groups', auth, function(req, res, next) {
  //retrieve all groups
  Group.find( function (err, groups) {
    if (err) { return next(err) }
    res.json(groups);
  });
});
//create a new group
router.post('/groups', auth, function(req, res, next) {

  var group= new Group();
  group.name=req.body.newgroup;
  console.log("posted new group:"+req.body.newgroup);
  group.category=[];
  group.save(function (err){
    if(err){ return next(err); }
    return res.json(group)
  });

});
//updating a group
router.put('/groups/:group', auth, function(req, res, next) {

  if (req.body.category){req.group.category=req.body.category;}
  if (req.body.acl){req.group.acl=req.body.acl;}
  req.group.save(function(err) {
    if(err){ return next(err); }
    return res.json(req.group);
  });

});

router.delete('/urlcategories/:id1/:id2', auth, function(req, res, next) {

  Urlcategory.findOneAndUpdate({ '_id': req.params.id1},
    { $pull: {"urls": {"_id": req.params.id2} }},       //update to be done
    {  safe: true, upsert: true, new: true }, //options new : true returns modified doc
       function(err, urlcategory) {
          if(err){ return next(err); }
          return res.json(urlcategory);
       }
    );
});

//manage route for acls
router.param('acl', function(req, res, next, id) {
  var query = ACL.findById(id);

  query.exec(function (err, acl){
    if (err) { return next(err); }
    if (!acl) { return next(new Error('can\'t find acl')); }
    req.acl = acl;
    return next();
  });
});

//deleting an entry in an acl
router.delete('/acls/:id1/:id2', auth, function(req, res, next) {
//id1 is acl id , id2 is entry id
  ACL.findOneAndUpdate({ '_id': req.params.id1},
    { $pull: {"entries": {"_id": req.params.id2} }},       //update to be done
    {  safe: true, upsert: true, new: true }, //options new : true returns modified doc
       function(err, acl) {
          if(err){ return next(err); }
          return res.json(acl);
       }
    );
});

//newaclparamsjson {"dstSubnet" : $scope.newacl.dstSubnet, "dstStartPort" : $scope.newacl.dstStartPort, "dstEndPort": $scope.newacl.dstEndPort }
//adding entry to a acl
router.put('/acls/:acl', auth, function(req, res, next) {

  var modification = {"dstSubnet" : req.body.dstSubnet, "dstStartPort" : req.body.dstStartPort,"dstEndPort":   req.body.dstEndPort} ;

  req.acl.entries.push(modification);

  req.acl.save({setDefaultsOnInsert: true},function(err) {
    if(err){ return next(err); }

    return res.json(req.acl);
  });

});

//push an acl ocnfiguration to apm
router.get('/updateapmacl/:acl', auth, function(req, res, next) {
  //removing mango _id property
  for (var i = 0; i < req.acl.entries.length; i++) {
    delete req.acl.entries[i]._id
  }

  APM.findOne({'name':"myapm"},  function (err, apm) {
    if (err) { return (JSON.stringify(err)) }

    var options = {
      url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/apm/acl/~Common~"+req.acl.name,
      method: 'PATCH',
      json : {"entries": req.acl.entries}, //post the urls array in json
      strictSSL : false, //no certificate validation
      rejectUnauthorized : false //no certificate validation
    };
    console.log("sending patch request to APM for acl update");
    request(options, function (error, response, body) {
        if (!error  && response.statusCode == 200) {
          console.log("apm change done");
          res.json("{OK}");
        } else {
          console.log("error found sending acl to APM ...");
          res.json(error || response.body );
        }
    })
  });

});

//retrieve an acl configuration from apm
router.get('/getapmacl/:acl', auth, function(req, res, next) {
  APM.findOne({'name':"myapm"},  function (err, apm) {
    if (err) { return (JSON.stringify(err)) }

    var options = {
      url: "https://"+apm.username+":"+apm.password+"@"+apm.ip+"/mgmt/tm/apm/acl/~Common~"+req.acl.name,
      method: 'GET',
      strictSSL : false, //no certificate validation
      rejectUnauthorized : false //no certificate validation
    };
    console.log("sending GET request to APM");
    request(options, function (error, response, body) {
        if (!error  && response.statusCode == 200) {
          console.log("apm GET done on acl");
          //updating mangodb
          req.acl.entries=JSON.parse(body).entries;
          req.acl.save();
          //sending response
          res.json(req.acl.entries);
        } else {
          console.log("error found while retrieving acl from APM ...");
          res.json("{KO}");
        }
    })
  });
});

module.exports = router;
