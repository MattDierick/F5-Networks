var app = angular.module('AsmPortal', ['ui.router','ngMaterial','md.data.table','ngMessages']);

app.config(['$stateProvider','$urlRouterProvider',
function($stateProvider, $urlRouterProvider) {
  $stateProvider
  .state('index', {
    url: '/index',
    templateUrl: 'index.html',
    controller: 'MainCtrl',
    onEnter: ['$state', function($state){
      $state.go('policies');
    }]
  })
  .state('policies', {
      url: '/policies',
      templateUrl: 'policies.html',
      controller: 'PoliciesCtrl',
      resolve: {
        policiesPromise: ['policies', function(policies){
          return policies.getAll();
        }],
        signaturesPromise : ['policies', function(policies){
          return policies.allSignatureSet();
        }]
      }
    })
    .state('policies.editpolicy', {
      url: '/{id}',
      templateUrl: '/editpolicy.html',
      controller: 'PolicyCtrl',
      //params : { policyid : "default" },
      resolve: { policiesPromise: ['policies','$stateParams', function(policies,$stateParams){
          return policies.getSignatureSets($stateParams.id);
        }]
      }//resolve
    })
    .state('asmmgt', {
      url: '/asmmgt',
      templateUrl: '/asmmgt.html',
      controller: 'MainCtrl',
    });

    $urlRouterProvider.otherwise('index');
  }]);

app.controller('PolicyCtrl', [ '$scope','$mdToast','$mdDialog','policies' ,'$stateParams', function($scope,$mdToast,$mdDialog,policies,$stateParams){
  //setting current policy for edit policy page
  $scope.currentpolicy= {};
  $scope.signaturesets= {};
  //policies.getSignatureSet($stateParams.id);
  $scope.currentpolicy=policies.policies[$stateParams.id];
  //console.log(policies.signatureSets);
  $scope.signaturesets=policies.signatureSets;
  //console.log(policies.policies);
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

  //console.log($scope.currentpolicy);

  //md-dialog to push signatures sets to asm
  $scope.showConfirmasmpush = function(ev) {

    var confirm = $mdDialog.confirm()
          .title('Push signatures to ASM')
          .textContent('This will overwrite this policy signatures sets configuration')
          .ariaLabel('Push configuration to ASM')
          .targetEvent(ev)
          .ok("Let's do it!")
          .cancel('Cancel');
      $mdDialog.show(confirm).then(function() {
          //if confirm
          $scope.progressbar=false;
          policies.pushsignaturestopolicy($scope.currentpolicy.id,$scope.currentpolicy.signatureSets,$scope.currentpolicy.name).then(function(){
            $scope.progressbar=true;
          }) ;
      }, function() {
          //do nothing on cancel
          //$scope.status = 'You decided to keep your debt.';
        });
  };
  //end md-dialog

  //md-dialog to pull signatures sets from asm
  $scope.showConfirmasmpull = function(ev) {

    var confirm = $mdDialog.confirm()
          .title('Pull signatures from ASM')
          .textContent('This will retrieve signatures sets configuration from ASM')
          .ariaLabel('Pull configuration from ASM')
          .targetEvent(ev)
          .ok("Let's do it!")
          .cancel('Cancel');
      $mdDialog.show(confirm).then(function() {
          //if confirm
          $scope.progressbar=false;
          policies.updateSignatureSets($stateParams.id).then(function() {
            $scope.progressbar=true;
          });
      }, function() {
          //do nothing on cancel
          //$scope.status = 'You decided to keep your debt.';
        });
  };
  //end md-dialog

  $scope.sigactive = function(item) {
    //console.log("sigactive ? "+item);
    if ($scope.currentpolicy.signatureSets != undefined && $scope.currentpolicy.signatureSets.length != 0)  {
      return $scope.currentpolicy.signatureSets.indexOf(item) > -1;
    } else return 0;
  };//end sigactive

  $scope.togglesig = function (item) {
    var idx = $scope.currentpolicy.signatureSets.indexOf(item);
    if (idx > -1) {
      $scope.currentpolicy.signatureSets.splice(idx, 1);
    }
    else {
      $scope.currentpolicy.signatureSets.push(item);
    }
  };//end togglesig
}]); //end controller PolicyCtrl

app.factory('policies', ['$http', function($http){
  var p = {
    signatureSets : [],
    policies : []
  };
  //get all policy names
  p.getAll = function() {
    $http.get('/getpolicies').then(function(data){
      if (data.data == "{KO}") {
        showSimpleToast('top right',"Error, cannot get policies from ASM");
      } else {
        angular.copy(data.data, p.policies);
      }
    });
  };
  //list all systema available sets
  p.allSignatureSet = function () {
    $http.get('/allsignatures/').then(function(data){
      angular.copy(data.data, p.signatureSets);
    });
  }
  //get system-signature assigned to a policy signature-sets
  p.getSignatureSets = function (policyarrayid) {
    if (p.policies[policyarrayid].signatureSets == undefined) {
      console.log("Policy signatureSets is undefined, retrieving from ASM ...")
      $http.get('/getsignatures/'+p.policies[policyarrayid].id).then(function(data){
        if (data.data == "{OK}") {
          showSimpleToast('top right',"Error, cannot get policy signatures from ASM");
        } else {
          p.policies[policyarrayid].signatureSets=[];
          showSimpleToast('top right',"Policy Signatures retrieved successfully from ASM");
          angular.copy(JSON.parse(data.data), p.policies[policyarrayid].signatureSets);
        }
      }, function(data) {
        showSimpleToast('top right',"Error, cannot retrieve policy signatures on ASM");
      })
    }
  };
  p.updateSignatureSets = function (policyarrayid) {
    return $http.get('/getsignatures/'+p.policies[policyarrayid].id).then(function(data){
        p.policies[policyarrayid].signatureSets=[];
        showSimpleToast('top right',"Policy Signatures retrieved successfully from ASM");
        angular.copy(JSON.parse(data.data), p.policies[policyarrayid].signatureSets);
      }, function(data) {
        showSimpleToast('top right',"Error, cannot retrieve policy signatures on ASM");
      })
  };
  //update a policy signature sets
  p.pushsignaturestopolicy = function (currentpolicyid,signaturesets,policyname) {
    return $http.put('/pushsignaturestopolicy/'+currentpolicyid,{'newsigset': signaturesets,'policyname' :policyname}).then(function(data){
      if (data.data != "{OK}") {
        showSimpleToast('top right',"Error, cannot update policy signatures on ASM");
      } else {
        showSimpleToast('top right',"Policy Signatures updated successfully on ASM");
      }
    } , function(data) {
      showSimpleToast('top right',"Error, cannot update policy signatures on ASM");
    })
  };

  return p;
}]); //end factory Policies

app.controller('PoliciesCtrl', [ '$scope','$mdToast','policies' , function($scope,$mdToast,policies){
$scope.policies = policies.policies;



}]); //end controller PoliciesCtrl

app.controller('MainCtrl', ['$scope', '$mdToast','$http', function($scope,$mdToast,$http){
  $scope.menufabisOpen = true;
  $scope.asm={};


  $http.get('/getasmconfig').then(function(data){
    if (data.data == "{KO}") {
      showSimpleToast('top right',"Error, cannot retrieve ASM config");
     } else {
       $scope.asm.ip=data.data.asmip;
       $scope.asm.username=data.data.asmusername;
       $scope.asm.password=data.data.asmpassword;
     }
  });//end get

  $scope.changeasmconfig = function() {
    return $http.put('/changeasmconfig/',{'newip': $scope.asm.ip,'newusername':$scope.asm.username,'newpassword':$scope.asm.password}).then(function(data){
      if (data.data != "{OK}") {
        showSimpleToast('top right',"Error, cannot update ASM config");
      } else {
        showSimpleToast('top right',"ASM config updated");
      }
    } , function(data) {
      showSimpleToast('top right',"Error, cannot update ASM config");
    }) //end put
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
}]); //end controller MainCtrl
