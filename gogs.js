var GogsClient = require('gogs-client');
var api = new GogsClient('http://gogs.127.0.0.1.nip.io/api/v1');
var netrc = require('netrc');
var myNetrc = netrc();
console.log(myNetrc);
myNetrc['gogs.127.0.0.1.nip.io']={login:'chakri',password:'asdfsaf'};
netrc.save(myNetrc);



api.createUser({
    "username": "admin5",
    "password": "c0mputer",
    "full_name": "Demo User",
    "email": "admin5@gmail.com"
  },null,false).then(function(user) {
   console.log(user);
}).catch(function(err){
   console.log(err);
});

//const kApi = require('kubernetes-client');
/*
const OpenShiftClient = require('openshift-client');
const oapi = new OpenShiftClient.OApi({
  url: 'https://127.0.0.1:8443',
  insecureSkipTlsVerify: true,
  auth: {
    bearer: 'pdoiU7snbeIC4BpWzvbagWKqyjVcSp2a5ik1J8EALLw'
  }
});

var simpleGit = require('simple-git')("./");
simpleGit.init(null,function(){
    simpleGit.addRemote("openshift","http://gogs.127.0.0.1.nip.io/admin5/test.git", function(err,res){
        console.log(err,res);
    });
});
*/

//oapi.ns('myproject').deploymentconfigs.post({ body: manifest0 },function(err){ console.log(err) });

/*
api.createRepo({name: 'admin5',description:'desc',private:true},{
    "username": "admin5",
    "password": "c0mputer"
  }).then(function(res){
   console.log(res);
}).catch(function(err){
   console.log(err);
});

api.listRepos('admin2').then(function(res){
   console.log(res);
});
*/
