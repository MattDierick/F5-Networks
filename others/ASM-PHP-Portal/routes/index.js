var express = require('express');
var router = express.Router();
var request = require('request');
var async = require('async');

var asm = {};
asm.ip="192.168.142.14";
asm.username="admin";
asm.password="admin";

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'ASM Portal' });
});
router.get('/index.html', function(req, res, next) {
  res.render('index', { title: 'ASM Portal' });
});
// routing for angular templates
router.get('/policies.html', function(req, res, next) {
  res.render('policies', { title: 'ASM Portal' });
});
router.get('/asmmgt.html', function(req, res, next) {
  res.render('asmmgt', { title: 'ASM Portal' });
});
router.get('/editpolicy.html', function(req, res, next) {
  res.render('editpolicy', { title: 'ASM Portal' });
});

//routing for api requests
router.get('/getasmconfig', function(req, res, next) {

  res.json({"asmip": asm.ip,"asmusername":asm.username,"asmpassword":asm.password});
});

router.put('/changeasmconfig', function(req, res, next) {
  asm.ip=req.body.newip;
  asm.username=req.body.newusername;
  asm.password=req.body.newpassword;
  console.log("asm new config:"+asm.ip,asm.username,asm.password);
  res.json("{OK}");
});
//getting all system signatures to build the signature table list
router.get('/allsignatures/', function(req, res, next) {
  console.log("retrieving all ASM  Signatures sets ");
  var options = {
        url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/signature-systems/?$select=name,id",
        method: 'GET',
        strictSSL : false, //no certificate validation
        rejectUnauthorized : false //no certificate validation
  };
  request(options, function (error, response, body) {
    if (!error  && response.statusCode == 200) {
      console.log("ASM GET all signature-sets done");
      //console.log(JSON.parse(body).items);
      res.json(JSON.parse(body).items);
      //console.log(JSON.parse(body).items);
    } else {
      console.log("error found while retrieving all signature-sets from ASM ...");
      res.json("{KO}");
    } //end if error
  }); //end request
}); //end router get allsignatures

//gettting system signatures used by current policy
router.get('/getsignatures/:policyid', function(req, res, next) {
  console.log("retrieving ASM policy Signatures for "+req.params.policyid);
  var options = {
        url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/policies/"+req.params.policyid+"/signature-sets",
        method: 'GET',
        strictSSL : false, //no certificate validation
        rejectUnauthorized : false //no certificate validation
  };
  request(options, function (error, response, body) {
    if (!error  && response.statusCode == 200) {
      console.log("ASM GET policy signature-sets done");
      //console.log(JSON.parse(body));

      var policysigsystemsets = [];
      //here we parse policy sigs set associated to the policy
      async.each (JSON.parse(body).items, function(item, next){
        //console.log("policy sigset: "+item.id);
        //don't care about this one

        //console.log("policy sigset reference:");
        //console.log(item.signatureSetReference);
        //we extract signature-set reference id
        var signaturesetreferenceid = item.signatureSetReference.link.substring(45,67);
        //console.log(signaturesetreferenceid);
        //now we query each sigset to have corresponding systems signature sets

        var options = {
              url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/signature-sets/"+signaturesetreferenceid+"?$select=systems",
              method: 'GET',
              strictSSL : false, //no certificate validation
              rejectUnauthorized : false //no certificate validation
        };
        request(options, function (error, response, body) {
          if (!error  && response.statusCode == 200) {
            console.log("signature-sets reference for "+signaturesetreferenceid);
            //console.log(JSON.parse(body).systems);
            //console.log("split");
            for (var system in JSON.parse(body).systems) {
              //console.log("systemReference "+system);
              //console.log("systemReference "+JSON.parse(body).systems[system].systemReference.link);
              policysigsystemsets.push(JSON.parse(body).systems[system].systemReference.link.substring(48,70));
            }

          } else {
            console.log("error found while retrieving policy signature-sets from ASM ...");
            return error;
          }; //end if error
          next();
        });//end request
      }, function(){
        //callback async
        //policysigsystemsets now contains a table of sytem signature sets sid

        //console.log(policysigsystemsets);
        res.json(JSON.stringify(policysigsystemsets));
      });//async


      //res.json(JSON.parse(body));
      //console.log(JSON.parse(body).items);
    } else {
      console.log("error found while retrieving policy signature-sets from ASM ...");
      res.json("{KO}");
    } //end if error
  }); //end request
}); //end router get policy

//here we get policies name, signature set reference, urlreference and policy id
router.get('/getpolicies', function(req, res, next) {
  console.log("retrieving ASM policies");
  var options = {
        url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/policies?$select=name,signatureSetReference,urlReference,id",
        method: 'GET',
        strictSSL : false, //no certificate validation
        rejectUnauthorized : false //no certificate validation
  };
  request(options, function (error, response, body) {
    if (!error  && response.statusCode == 200) {
      console.log("ASM GET policies done");
      res.json(JSON.parse(body).items);
      //console.log(JSON.parse(body).items);
    } else {
      console.log("error found while retrieving policies from ASM ...");
      res.json("{KO}");
    } //end if error
  }); //end request
}); //end router get policies

router.put('/pushsignaturestopolicy/:policyid', function(req, res, next) {
  //console.log("push sig :"+req.params.policyid);
  //console.log("received sig to push "+req.body.newsigset);

  applypolicy = function (error, response, body) {
    if (!error  && response.statusCode == 201) {
      console.log("ASM attaching sigset to policy done");
      //applypolicy
      //$url_apply = "https://" . $selected_device . "/mgmt/tm/asm/tasks/apply-policy";
      var jsonpayload = {};
      jsonpayload.policyReference = {"link":"https://localhost/mgmt/tm/asm/policies/"+req.params.policyid};
      var options = {
            url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/tasks/apply-policy",
            method: 'POST',
            json: jsonpayload,
            strictSSL : false, //no certificate validation
            rejectUnauthorized : false //no certificate validation
      };
      request(options, function (error, response, body) {
        if (!error  && response.statusCode == 201) {
          console.log("applying policy done");
          res.json("{OK}");
        } else {
          console.log("error applying policy ..."+response.statusCode);
          res.json("{KO}" );
        }
      });//end request
    }  else {
        console.log("error attaching sigset to policy ...");
        res.json("{KO}");
    } //end if error
  };//end applypolicy

  addsigset  = function (error, response, body) {
    if (!error  && response.statusCode == 201) {
      console.log("ASM creating sigset done");
      //console.log("newsigset id "+response.body.id);

      jsonpayload = {};
      jsonpayload.alarm = "true";
      jsonpayload.block = "true";
      jsonpayload.learn = "true";
      jsonpayload.signatureSetReference = {"link"  : "https://localhost/mgmt/tm/asm/signature-sets/"+response.body.id};
      var options = {
            url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/policies/" + req.params.policyid + "/signature-sets",
            method: 'POST',
            json: jsonpayload,
            strictSSL : false, //no certificate validation
            rejectUnauthorized : false //no certificate validation
      };
      request(options, applypolicy);//adding the sig set to policy then apply
    }  else {
        console.log("error creating sigset  ...");
        res.json("{KO}");
    } //end if error
  };//end addsigset

  createsigset = function (error, response, body) {
    if (!error  && response.statusCode == 201) {
      console.log("ASM DELETE sigset from policy  done");
      // the demo portal is exclusively using a sig set with the same name as the policy, replacing any existing one
      var jsonpayload={};
      jsonpayload.systems=[];
      for (var sig in req.body.newsigset) {
        jsonpayload.systems.push({'systemReference' :{"link" : "https://localhost/mgmt/tm/asm/signature-systems/"+req.body.newsigset[sig] +"?ver=12.0.0"}})
      }
      jsonpayload.name="customset_"+req.body.policyname;
      //console.log(JSON.stringify(jsonpayload));
      var options = {
            url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/signature-sets/",
            method: 'POST',
            json: jsonpayload,
            strictSSL : false, //no certificate validation
            rejectUnauthorized : false //no certificate validation
      };
      request(options, addsigset);//creating the sig set then adding it to policy
    } else {
      console.log("error DELETING sigset from policy ...");
      res.json("{KO}");
    } //end if error
  }//end createsigset

  deletesigsetfrompolicy = function (error, response, body) {
    if (!error  && response.statusCode == 201) {
      console.log("ASM DELETE sigset  done");

      //DELETING SIG SET attached to  policy
      //$url_delete_sigset_policy = "https://" . $selected_device . "/mgmt/tm/asm/policies/" . $selected_policy . "/signature-sets";
			var options = {
            url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/policies/"+req.params.policyid+"/signature-sets/",
            method: 'DELETE',
            strictSSL : false, //no certificate validation
            rejectUnauthorized : false //no certificate validation
      };
      request(options, createsigset);//delete sig set from policy then create new
    } else {
      console.log("error DELETING sigset ...");
      res.json("{KO}");
    } //end if error
  };//deletesigsetfrompolicy
  // ---->> need to delete existin sigset with same name ... we only have a name for filter and get id
	// !!! can use filter with delete : DELETE https://192.168.142.13/mgmt/tm/asm/signature-sets/?$filter=name eq test_no-template
  var options = {
        url: "https://"+asm.username+":"+asm.password+"@"+asm.ip+"/mgmt/tm/asm/signature-sets/?$filter=name eq "+"customset_"+req.body.policyname,
        method: 'DELETE',
        strictSSL : false, //no certificate validation
        rejectUnauthorized : false //no certificate validation
  };
  //deleting the existing sigset then deleting the sigset attached to policy
  request(options, deletesigsetfrompolicy); //deleting sigset then delete it from policy


});

module.exports = router;
