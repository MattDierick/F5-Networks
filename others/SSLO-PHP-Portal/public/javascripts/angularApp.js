var app = angular.module('ApmPortal', ['ui.router','ngMaterial','md.data.table','ngMessages']);

app.config([
'$stateProvider',
'$urlRouterProvider',
function($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('logout', {
    url: '/logout',
    templateUrl: '',
    controller: 'AuthCtrl',
    resolve: {
      logoutpromise: [ 'auth', function(auth){
        return auth.logOut();
      }]
    },
    onEnter: ['$state', function($state){
      $state.go('index');
    }]
  })
  .state('index', {
    url: '/index',
    templateUrl: 'index.html',
    controller: 'MainCtrl',
    onEnter: ['$state', 'auth', function($state, auth){
      if(auth.isLoggedIn()){
        $state.go('networklocation');
      } else {
        $state.go('login');
      }
    }]
  })
  .state('networklocation', {
    url: '/networklocation',
    templateUrl: 'networklocation.html',
    controller: 'networklocationCtrl',
    resolve: {
      categoriesPromise: ['networklocations', function(networklocations){
        return networklocations.getAll();
      }]
    },
    onEnter: ['$state', 'auth', function($state, auth){
      if(!auth.isLoggedIn()){
        $state.go('login');
      }
    }]

  })
  .state('acls', {
    url: '/acls',
    templateUrl: 'acls.html',
    controller: 'MainCtrl',
    resolve: {
      categoriesPromise: ['acls', function(acls){
        return acls.getAll();
      }]
    },
    onEnter: ['$state', 'auth', function($state, auth){
      if(!auth.isLoggedIn()){
        $state.go('login');
      }
    }]

  })
  .state('acls.editacl', {
    url: '/editacl/{id}',
    templateUrl: '/editacl.html',
    controller: 'ACLCtrl',
    onEnter: ['$state', 'auth', function($state, auth){
      if(!auth.isLoggedIn()){
        $state.go('login');
      }
    }]
  })
    .state('category', {
      url: '/category',
      templateUrl: 'categories.html',
      controller: 'MainCtrl',
      resolve: {
        categoriesPromise: ['urlcategories', function(urlcategories){
          return urlcategories.getAll();
        }]
      },
      onEnter: ['$state', 'auth', function($state, auth){
        if(!auth.isLoggedIn()){
          $state.go('login');
        }
      }]

    })
    .state('category.urlcategories', {
      url: '/urlcategories/{id}',
      templateUrl: '/urlcategories.html',
      controller: 'UrlcategoriesCtrl',
      onEnter: ['$state', 'auth', function($state, auth){
        if(!auth.isLoggedIn()){
          $state.go('login');
        }
      }]
    })
    .state('editgroups', {
      url: '/editgroups',
      templateUrl: '/editgroups.html',
      controller: 'GroupsCtrl',
      resolve: {
        groupsPromise: ['groups', function(groups){
          return groups.getAll();
        }]
      },
      onEnter: ['$state','auth','groups', function($state, auth,groups){
        if(!auth.isLoggedIn()){
          $state.go('login');
        }
      }]
    })
    .state('editgroups.groupcategories', {
      url: '/groupcategories/{id}',
      templateUrl: '/groupcategory.html',
      controller: 'editGroupsCtrl',
      resolve: {
        categoriesPromise: ['urlcategories', function(urlcategories){
          return urlcategories.getAll();
        }],
        aclsPromise: ['acls', function(acls){
          return acls.getAll();
        }],
      },
      onEnter: ['$state', 'auth', 'groups', function($state, auth,groups){
        if(!auth.isLoggedIn()){
          $state.go('login');
        }
      }]
    })
    .state('login', {
      url: '/login',
      templateUrl: '/login.html',
      controller: 'AuthCtrl',
      onEnter: ['$state', 'auth', function($state, auth){
        if(auth.isLoggedIn()){
          $state.go('category');
        }
      }]
    })
    .state('register', {
      url: '/register',
      templateUrl: '/register.html',
      controller: 'AuthCtrl',
      resolve: {
        groupsPromise: ['groups', function(groups){
          return groups.getAll();
        }]
      }
    })
    .state('apmmgt', {
      url: '/apmmgt',
      templateUrl: '/apmmgt.html',
      controller: 'APMmgtCtrl',
      resolve: {
        groupsPromise: ['groups', function(groups){
          return groups.getAll();
        }]
      }
    });

    $urlRouterProvider.otherwise('index');
  }]);

  //managing user authentication
app.factory('auth', ['$http', '$window', function($http, $window){
    var auth = {};
    auth.saveToken = function (token){
     $window.localStorage['apm-demoportal-token'] = token;
    };

    auth.getToken = function (){
      return $window.localStorage['apm-demoportal-token'];
    };
    auth.isAdmin = function(){
      var token = auth.getToken();

      if(token){
        var payload = JSON.parse($window.atob(token.split('.')[1]));
          return payload.isadmin;
      }
      else {
        return false;
      }
    };
    auth.isLoggedIn = function(){
      var token = auth.getToken();

      if(token){
        var payload = JSON.parse($window.atob(token.split('.')[1]));
          return payload.exp > Date.now() / 1000;

      } else {
        return false;
      }
    };

    auth.currentUser = function(){
      if(auth.isLoggedIn()){
        var token = auth.getToken();
        var payload = JSON.parse($window.atob(token.split('.')[1]));

        return payload.username;
      }
    };

    auth.register = function(user){

      return $http.post('/register', user).then(function(data){
        //dont log on register, admin do register other users
       //  auth.saveToken(data.token);
      });
    };

    auth.logIn = function(user){
      return $http.post('/login', user).then(function(data){
        auth.saveToken(data.data.token);
      });
    };

    auth.logOut = function(){
      $window.localStorage.removeItem('apm-demoportal-token');
      return;
    };

    return auth;
  }])

app.controller('AuthCtrl', ['$scope','$state','auth', 'groups','$mdToast', function($scope, $state, auth, groups,$mdToast  ){
      $scope.user = {};
      $scope.user.isadmin =false;
      //we instentiate the groups table for select
      $scope.groups = groups.groups;
      $scope.showhint=false;
    //md-toast function
    showSimpleToast = function(position,message) {
      $mdToast.show(
        $mdToast.simple()
          .textContent(message)
          .position(position )
          .hideDelay(3000)
      );
    };

    $scope.register = function(form){
      auth.register($scope.user).then(function(){

        $scope.user.username="";
        $scope.user.password="";
        $scope.user.group="";
        $scope.user.isadmin=false;

        showSimpleToast("top right","New User added to Portal DB")
        $state.go('register');
      } , function(error){
        showSimpleToast("top right",error.data.message)
      });

    };

    $scope.logIn = function(){
      auth.logIn($scope.user).then(function(data){
        $state.go('index');

      } , function(error){
        $scope.error = error;
      });
    };

  }]);

app.controller('NavCtrl', ['$scope','auth','$http','$interval', function($scope, auth, $http,$interval){
    $scope.isLoggedIn = auth.isLoggedIn;
    $scope.currentUser = auth.currentUser;
    $scope.isapmavailable = true;

    $scope.apmavailable =  function(){
      $http.get('/ping').then(function(data){
        if (data.data == "{OK}") {
          console.log("apm available");
          $scope.isapmavailable = true;
        } else {
          console.log("apm not available");
          $scope.isapmavailable = false;
        }
      });
    }//apm available
    $scope.apmavailable();
    $scope.mycall = $interval($scope.apmavailable,30000);
    //$scope.logOut = auth.logOut;
}]);

app.factory('urlcategories', ['$http', 'auth', function($http, auth){
  var o = {
    urlcategories: ["{dummy empty}"]
  };
  //create a category ------ to be tested, no functionnal , dont use ...
  o.create = function(urlcategory) {
    return $http.post('/urlcategories', urlcategory, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      o.urlcategories.push(data);
    });
  };
  //get all categories
  o.getAll = function() {
      $http.get('/urlcategories', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
        angular.copy(data.data, o.urlcategories);
    });

  };
  //adding url to a category
  o.addurl = function(urlcategory,arrayid,url) {
    return $http.put('/urlcategories/'+urlcategory._id,{url: url.name}, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.urls,o.urlcategories[arrayid].urls);
    });
  }
  o.removeurl = function(urlcategory,arrayid,urlid) {
    return $http.delete('/urlcategories/'+urlcategory._id+"/"+urlid, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.urls,o.urlcategories[arrayid].urls);
    });
  }
  o.pushcategorytoapm = function(category) {

    return $http.get('/updateapmcategory/'+category, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      if (data.data != "{OK}") {
        showSimpleToast('top right',"Error, cannot update category on APM");
      } else {
        showSimpleToast('top right',"Category updated successfully on APM");
      }
    }, function(data){
        showSimpleToast('top right',"Error, Error, cannot update category on APM");
    })
  };
    o.pullcategoryfromapm = function(category,arrayid) {
      return $http.get('/getapmcategory/'+category, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
        if (data.data != "{KO}") {
          angular.copy(data.data,o.urlcategories[arrayid].urls)
          //data is the category.urls part
            showSimpleToast('top right',"Retrieval successfull from APM");
        } else {
          //something bad happened
          //get working but error code back KO
            showSimpleToast('top right',"Cannot retrieve configuration from APM");
        }
      }, function(data){
          // get no working ?
          showSimpleToast('top right',"Cannot retrieve configuration from APM");
      });
    };

  return o;
}]);

app.factory('acls', ['$http', 'auth', function($http, auth){
  var o = {
    acls: ["{dummy empty}"]
  };

  //get all acls
  //ok
  o.getAll = function() {
      $http.get('/acls', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
        angular.copy(data.data, o.acls);
    });

  };
  //adding acl to an acl
  //ok
  o.addacl = function(acl,arrayid,newaclparamsjson) {
    //{"dstSubnet" : $scope.newacl.dstSubnet, "dstStartPort" : $scope.newacl.dstStartPort, "dstEndPort": $scope.newacl.dstEndPort }
    return $http.put('/acls/'+acl._id,newaclparamsjson, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){

      angular.copy(data.data,o.acls[arrayid]);
    });
  }
  //remove an acl entry
  //ok
  o.removeaclentry = function(acl,arrayid,entryid) {
    return $http.delete('/acls/'+acl._id+"/"+entryid, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.entries,o.acls[arrayid].entries);
    });
  }
  //ok
  o.pushacltoapm = function(acl) {
    return $http.get('/updateapmacl/'+acl, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      if (data.data != "{OK}") {
        showSimpleToast('top right',"Error, cannot update ACL on APM");
      } else {
        showSimpleToast('top right',"ACL updated successfully on APM");
      }
    }, function(data){
        showSimpleToast('top right',"Error, Error, cannot update ACL on APM");
    })
  };
    o.pullaclfromapm = function(acl,arrayid) {
      return $http.get('/getapmacl/'+acl, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
        if (data.data != "{KO}") {
          angular.copy(data.data,o.acls[arrayid].entries)
          //data is the category.urls part
            showSimpleToast('top right',"Retrieval successfull from APM");
        } else {
          //something bad happened
          //get working but error code back KO
            showSimpleToast('top right',"Cannot retrieve configuration from APM");
        }
      }, function(data){
          // get no working ?
          showSimpleToast('top right',"Cannot retrieve configuration from APM");
      });
    };

  return o;
}]);

app.controller('ACLCtrl', [
  '$scope',  '$stateParams',  'acls',  '$animate',  'auth', '$mdDialog','$mdToast',
  function($scope, $stateParams, acls, $animate,auth,$mdDialog,$mdToast){
    $scope.acl = acls.acls[$stateParams.id];
    $scope.newacl={};
    $scope.newacl.dstSubnet="";
    $scope.newacl.dstEndPort="";
    $scope.newacl.dstStartPort="";
    $scope.aclalert="";
    $scope.showhint=false;
    $scope.progressbar=true;
    //md-toast function
    showSimpleToast = function(position,message) {
      $mdToast.show(
        $mdToast.simple()
          .textContent(message)
          .position(position )
          .hideDelay(3000)
      );
    };
    //md-dialog to push to apm
    $scope.showConfirmpush = function(ev) {
      var confirm = $mdDialog.confirm()
            .title('Update '+ $scope.acl.name+' to APM')
            .textContent('This will overwrite this APM ACL configuration')
            .ariaLabel('Push to APM')
            .targetEvent(ev)
            .ok("Let's do it!")
            .cancel('Cancel');
        $mdDialog.show(confirm).then(function() {
            //if confirm
          $scope.progressbar=false;
          acls.pushacltoapm($scope.acl._id).then(function(){
            $scope.progressbar=true;
          }) ;
        }, function() {
            //do nothing on cancel
            //$scope.status = 'You decided to keep your debt.';
          });
    };
    //end md-dialog
    //md-dialog to pull from apm
    $scope.showConfirmpull = function(ev) {

      var confirm = $mdDialog.confirm()
            .title('Update '+ $scope.acl.name+' from APM')
            .textContent('This will overwrite this acl configuration')
            .ariaLabel('Pull from APM')
            .targetEvent(ev)
            .ok("Let's do it!")
            .cancel('Cancel');
        $mdDialog.show(confirm).then(function() {
            //if confirm
            $scope.progressbar=false;
            acls.pullaclfromapm($scope.acl._id,$stateParams.id).then(function(){
              $scope.progressbar=true;
            }) ;
        }, function() {
          //do nothing on cancel
          //$scope.status = 'You decided to keep your debt.';
        });
    };
    //end md-dialog


    $scope.addAcl = function(form){

      //validation for destport
      if($scope.newacl.dstEndPort=="") {
        $scope.newacl.dstEndPort=$scope.newacl.dstStartPort;
      }


      //we call the function with acl , acl entry array number in acls, form parm containing new acl entry definition
      acls.addacl($scope.acl,$stateParams.id,{"dstSubnet" : $scope.newacl.dstSubnet, "dstStartPort" : $scope.newacl.dstStartPort, "dstEndPort": $scope.newacl.dstEndPort });
      $scope.newacl.dstSubnet="";
      $scope.newacl.dstStartPort="";
      $scope.newacl.dstEndPort="";

    };
    $scope.removeAclentry = function(aclid){
      acls.removeaclentry($scope.acl,$stateParams.id,aclid);
    };
}]);

app.controller('UrlcategoriesCtrl', [
  '$scope',  '$stateParams',  'urlcategories',  '$animate',  'auth', '$mdDialog','$mdToast',
  function($scope, $stateParams, urlcategories, $animate,auth,$mdDialog,$mdToast){
    $scope.urlcategory = urlcategories.urlcategories[$stateParams.id];
    $scope.newurl={};
    $scope.newurl.urlname="";
    $scope.urlalert="";
    $scope.showhint=false;
    $scope.progressbar=true//hide progressbar

    //md-toast function
    showSimpleToast = function(position,message) {
      $mdToast.show(
        $mdToast.simple()
          .textContent(message)
          .position(position )
          .hideDelay(3000)
      );
    };
    //md-dialog to push to apm
    $scope.showConfirmpush = function(ev) {
      var confirm = $mdDialog.confirm()
            .title('Update '+ $scope.urlcategory.name+' to APM')
            .textContent('This will overwrite this APM category configuration')
            .ariaLabel('Push to APM')
            .targetEvent(ev)
            .ok("Let's do it!")
            .cancel('Cancel');
        $mdDialog.show(confirm).then(function() {
            //if confirm
            $scope.progressbar=false;
              urlcategories.pushcategorytoapm($scope.urlcategory._id).then(function(){
              $scope.progressbar=true;
            }) ;

        }, function() {
            //do nothing on cancel
            //$scope.status = 'You decided to keep your debt.';
          });
    };
    //end md-dialog
    //md-dialog to pull from apm
    $scope.showConfirmpull = function(ev) {

      var confirm = $mdDialog.confirm()
            .title('Update '+ $scope.urlcategory.name+' from APM')
            .textContent('This will overwrite this category configuration')
            .ariaLabel('Pull from APM')
            .targetEvent(ev)
            .ok("Let's do it!")
            .cancel('Cancel');
        $mdDialog.show(confirm).then(function() {
            //if confirm
          $scope.progressbar=false;
          urlcategories.pullcategoryfromapm($scope.urlcategory._id,$stateParams.id).then(function(){
            $scope.progressbar=true;
          }) ;

        }, function() {
          //do nothing on cancel
          //$scope.status = 'You decided to keep your debt.';
        });
    };
    //end md-dialog


    $scope.addUrl = function(form){
      //checing if requested url already exists
      //blocking to be modified
      function isurlpresent(arrayofjsonurl,lookedurl) {
        for(var k in arrayofjsonurl) {
          if(arrayofjsonurl[k].name == lookedurl) {
            $scope.urlalert="The requested url is already present in this category";
            return 1;
          }
        }

        return 0;
      };// function isurlpresent

      //validation
      if( isurlpresent($scope.urlcategory.urls,$scope.newurl.urlname)) {
        showSimpleToast("top right","Url already present")
        return;
      }

      //we call the function with urlcategory , urlcategory array number in urlcaterories, form parm containing url
      urlcategories.addurl($scope.urlcategory,$stateParams.id,{name:$scope.newurl.urlname });
      $scope.newurl.urlname="";
    //  $scope.newUrlform.$error=null;


    };
    $scope.removeUrl = function(urlid){

      urlcategories.removeurl($scope.urlcategory,$stateParams.id,urlid);
      $scope.newurl.name="";
    };
}]);

app.factory('groups', ['$http', 'auth', function($http, auth){
  var o = {
    groups :[]
  };
  //get all groups
  o.getAll = function() {
    return $http.get('/groups', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data, o.groups);
    });
  };
  o.addGroup = function(groupname) {
    return $http.post('/groups',{newgroup: groupname}, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      o.groups.push(data.data);
    });
  }
  o.categoryinGroup = function(groupname) {

  };

  return o;
}]);

app.controller('editGroupsCtrl', [
  '$scope','auth','groups','urlcategories','acls','$state','$http','$mdToast',
  function($scope,auth,groups,urlcategories,acls,$state,$http,$mdToast){
    $scope.group = {"name":"error no group found",
                    "category":[],
                    "acl":[]};

    for(var mygroup in groups.groups) {
      if (groups.groups[mygroup].name == $state.params.id ) {
        $scope.group=groups.groups[mygroup];
      break;
        }
    };

  //md-toast function
  showSimpleToast = function(position,message) {
    $mdToast.show(
      $mdToast.simple()
        .textContent(message)
        .position(position )
        .hideDelay(3000)
    );
  };
 //category management
  $scope.togglecat = function (item, list) {
    var idx = list.indexOf(item);
    if (idx > -1) {
      list.splice(idx, 1);
    }
    else {
      list.push(item);
    }

    return $http.put('/groups/'+groups.groups[mygroup]._id,{category: list}, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.category,groups.groups[mygroup].category);
    }, function(response){
        showSimpleToast('top right',"Cannot update group in Portal DB");
    });
  };
  $scope.existscat = function (item, list) {
    return list.indexOf(item) > -1;
  };
  //acl management
  $scope.toggleacl = function (item, list) {
    var idx = list.indexOf(item);
    if (idx > -1) {
      list.splice(idx, 1);
    }
    else {
      list.push(item);
    }
    return $http.put('/groups/'+groups.groups[mygroup]._id,{acl: list}, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.acl,groups.groups[mygroup].acl);
    }, function(response){
        showSimpleToast('top right',"Cannot update acl in Portal DB");
    });
  };
  $scope.existsacl = function (item, list) {

    return list.indexOf(item) > -1;
  };
}]);

app.controller('GroupsCtrl',[
  '$scope','auth','groups','$state','urlcategories' ,
  function($scope,auth,groups,$state,urlcategories ){
    $scope.groups=groups.groups;

    $scope.addGroup = function(){
      groups.addGroup($scope.newgroup.groupname).then(function(error){
        if (error) {$scope.error = error; return}
        $scope.newgroup.groupname = "";
        $state.go('editgroups');
      });
    };
}]);
//hastily coded
app.controller('APMmgtCtrl', [
  '$scope','urlcategories','auth','$http','$mdToast','$mdDialog',
  function($scope,urlcategories,auth, $http,$mdToast,$mdDialog){
    $scope.apm={};
    $scope.progressbar=true;

    $http.get('/apmconfig', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      $scope.apm.name =data.data.name;
      $scope.apm.ip=data.data.ip;
      $scope.apm.username=data.data.username;
      $scope.apm.password=data.data.password;

    }, function(response) {
      showSimpleToast("top right","Error Connecting to Portal DB setting APM default config")
      $scope.apm.name ="myapm";
      $scope.apm.ip="192.168.142.15";
      $scope.apm.username="admin";
      $scope.apm.password="admin";
    })  ;

    $scope.showhint=false;

    //md-toast function
    showSimpleToast = function(position,message) {
      $mdToast.show(
        $mdToast.simple()
          .textContent(message)
          .position(position )
          .hideDelay(3000)
      );
    };

  //md-dialog to pull all category/acl from apm
  $scope.showConfirmbulkapmpull = function(ev) {

    var confirm = $mdDialog.confirm()
          .title('Bulk Update from APM')
          .textContent('This will overwrite ALL Portal DB categories and ACLs and Reset Portal DB groups assignments')
          .ariaLabel('Pull Bulk from APM')
          .targetEvent(ev)
          .ok("Let's do it!")
          .cancel('Cancel');
      $mdDialog.show(confirm).then(function() {
          //if confirm
          $scope.progressbar=false;
          $http.get('/getapmcategories', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
            if (data.data == "{KO}") {
              $scope.progressbar=true;
              showSimpleToast("top right","Error making change to Portal DB")
            }
            $scope.progressbar=true;
            showSimpleToast("top right","Change done to Portal DB")
          }, function(response) {
            $scope.progressbar=true;
            showSimpleToast("top right","Error making change to Portal DB")
          })  ;
      }, function() {
          //do nothing on cancel
          //$scope.status = 'You decided to keep your debt.';
        });
  };
  //end md-dialog
  //change apm credential in portal DB
  $scope.changeapmconfig = function () {

    var apmconfig = {};
    apmconfig.name = $scope.apm.name;
    apmconfig.ip = $scope.apm.ip;
    apmconfig.username=$scope.apm.username;
    apmconfig.password=$scope.apm.password;
    return $http.post('/apmconfig', apmconfig, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      showSimpleToast("top right","Change done to Portal DB");
    }, function(response) {
      showSimpleToast("top right","Error making change to Portal DB")
    })  ;
  }

  $scope.urlcategories = urlcategories.urlcategories;
}]);

app.factory('networklocations', ['$http', 'auth','$mdToast', function($http, auth, $mdToast){
  var nl = {
    networklocations :[]
  };

  //md-toast function
  showSimpleToast = function(position,message) {
    $mdToast.show(
      $mdToast.simple()
        .textContent(message)
        .position(position )
        .hideDelay(3000)
    );
  };

  //remove a newtork location
  nl.removeLocation = function(locationid) {
    return $http.delete('/networklocations/'+locationid, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.records,nl.networklocations);
    });
  };
  //get all network location
  nl.getAll = function() {
    $http.get('/networklocations', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.records,nl.networklocations);
    });
  };
  nl.pullnetworkfromapm = function() {
    return $http.get('/apmnetworklocations', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      if (data.data != "{KO}") {
        angular.copy(data.data.records,nl.networklocations);
        showSimpleToast('top right',"Network locations Retrieval successfull from APM");
      } else {
        //something bad happened
        //get working but error code back KO
          showSimpleToast('top right',"Cannot retrieve Network locations from APM");
      }
    }, function(data){
        // get no working ?
        showSimpleToast('top right',"Cannot retrieve Network locations from APM");
    }
  )};//end pull

    nl.pushnetworktoapm = function() {
      return $http.put('/apmnetworklocations', {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
        if (data.data != "{KO}") {
          /*angular.copy(data.data.records,nl.networklocations);*/
          showSimpleToast('top right',"Network Locations successfull pushed to APM");
        } else {
          //something bad happened
          //get working but error code back KO
            showSimpleToast('top right',"Cannot push Network Locations to APM");
        }
      }, function(data){
          // get no working ?
          showSimpleToast('top right',"Cannot push Network Locations to APM");
      });
  };//endput


  nl.addnetworklocation = function(newnetworklocation) {
    //{name : $scope.newlocation.name, type : $scope.newlocation.data }
    return $http.post('/apmnetworklocations/',newnetworklocation, {headers: {Authorization: 'Bearer '+auth.getToken()}}).then(function(data){
      angular.copy(data.data.records,nl.networklocations);
    });
  }

  return nl;
}]);

app.controller('networklocationCtrl', [
  '$mdDialog','$scope','networklocations','auth', function($mdDialog,$scope,networklocations,auth){
    //$scope.networklocations=[];
    $scope.newlocation={};
    $scope.newlocation.name="";
    $scope.newlocation.data="";
    $scope.showhint=false;
    $scope.networklocations=networklocations.networklocations;
    $scope.progressbar=true;

    $scope.removeLocation = function(locationid){
      networklocations.removeLocation(locationid);
      $scope.newlocation.name="";
      $scope.newlocation.data="";
    };
    $scope.addNetworkLocation = function(form) {
      console.log($scope.newlocation.name);
      console.log($scope.newlocation.data);
      networklocations.addnetworklocation({name : $scope.newlocation.name, data : $scope.newlocation.data });
      $scope.newlocation.name="";
      $scope.newlocation.data="";
    };//end add NetworkLocation

    //md-dialog to push to apm
    $scope.showConfirmpush = function(ev) {

      var confirm = $mdDialog.confirm()
            .title('Update APM Network Locations')
            .textContent('This will overwrite  APM Network Locations configuration')
            .ariaLabel('Push to APM')
            .targetEvent(ev)
            .ok("Let's do it!")
            .cancel('Cancel');
        $mdDialog.show(confirm).then(function() {
            //if confirm
          $scope.progressbar=false;
          networklocations.pushnetworktoapm().then(function(){
            $scope.progressbar=true;
          }) ;
        }, function() {
            //do nothing on cancel
          });
    }; //end confirm push
    //end md-dialog

    //md-dialog to pull from apm
    $scope.showConfirmpull = function(ev) {

      var confirm = $mdDialog.confirm()
            .title('Update Network Locations from APM')
            .textContent('This will overwrite Network Location configuration')
            .ariaLabel('Pull from APM')
            .targetEvent(ev)
            .ok("Let's do it!")
            .cancel('Cancel');
        $mdDialog.show(confirm).then(function() {
            //if confirm
          $scope.progressbar=false;
          networklocations.pullnetworkfromapm().then(function(){
            $scope.progressbar=true;
          }) ;
        }, function() {
          //do nothing on cancel
        });
    };
    //end md-dialog
}]);

app.controller('MainCtrl', [
  '$scope','urlcategories','acls','auth',
  function($scope,urlcategories,acls,auth){

  $scope.urlcategories = urlcategories.urlcategories;
  $scope.menufabisOpen = true;
  $scope.isAdmin = auth.isAdmin;

  $scope.acls = acls.acls;
}]);
