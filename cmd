#!/usr/bin/env node
const prog = require('commander-plus');
var GogsClient = require('gogs-client');
var netrc = require('netrc');
var myNetrc = netrc();
var simpleGit = require('simple-git')("./");
const OpenShiftClient = require('openshift-client');
const jq = require('node-jq');
const randomstring = require("randomstring");
var gogsAPI = new GogsClient('http://'+myNetrc['openshift.local'].gitserver+'/api/v1');
var oapi = new OpenShiftClient.OApi({
    url: myNetrc['openshift.local'].url,
    insecureSkipTlsVerify: true,
    auth: {
      bearer: (undefined!=myNetrc['openshift.local'].token?myNetrc['openshift.local'].token:'')
    }
});

var coapi = new OpenShiftClient.Core({
    url: myNetrc['openshift.local'].url,
    insecureSkipTlsVerify: true,
    auth: {
      bearer: (undefined!=myNetrc['openshift.local'].token?myNetrc['openshift.local'].token:'')
    }
});

prog
  .command('login','[url]')
  .action(function(url, options, logger) {
      var inObj={};
      prog.prompt('username: ', function(username){
        inObj['username']=username;
        prog.password('password: ',function(pwd){
          inObj['password']=pwd;
          prog.prompt('authtoken: ', function(authtoken){
            inObj['authtoken']=authtoken;
            prog.prompt('namespace: ', function(namespace){
              inObj['namespace']=namespace;
              var gitserver=url.replace('https:\/\/','');
              gitserver=gitserver.replace(':8443','');
              myNetrc['openshift.local']={
                  login : inObj.username,
                  password: inObj.password,
                  url: url,
                  gitserver: 'gogs.'+gitserver,
                  ns: inObj.namespace,
                  token: inObj.authtoken
              }
              myNetrc[gitserver]={
                  login : inObj.username,
                  password: inObj.password
              }
              netrc.save(myNetrc);
              console.log("Config Saved");
            });
          });
        })
      });
      //prompt.get(['username', 'password','authtoken','namespace'], function (err, result) {
    	  
      //}); 
  });

prog
  .command('apps','List apps')
  .action(function(args, options, logger) {
      if(undefined==myNetrc['openshift.local'])
        console.log('Please login')
      else{ 
        oapi.ns(myNetrc['openshift.local'].ns).deploymentconfigs.get((err, result) => {
            if (err) throw err;
            jq.run('.items[].metadata.name',result,{ input: 'json' }).then(console.log);
        });
      }
  });
prog
  .command('apps:create','[app]') 
  .action(function(app, options, logger) {
    var buildPacks = ['nodejs:latest','python:latest','ruby:latest','php:latest','wildfly:latest'];
    console.log('Build Pack');
    prog.choose(buildPacks,function(bp){
      bp=buildPacks[bp];
      gogsAPI.createRepo({name: app,description:'desc',private:true},{
          "username": myNetrc['openshift.local'].login,
          "password": myNetrc['openshift.local'].password
        }).then(function(res){
        
        //create openshift application  
        var webhook= randomstring.generate();  
        var oc_app={
          name: app,
          webhook: webhook,
          username:  myNetrc['openshift.local'].login,
          password: myNetrc['openshift.local'].password,
          base_image: bp,
          git_url: 'http://gogs:3000/'+myNetrc['openshift.local'].login+'/'+app+'.git'
        }
        var tmpl=require('blueimp-tmpl');
        var oc_app_json = require('./objects/all'); 

        var bc=tmpl(JSON.stringify(oc_app_json.items[1]),oc_app);
        oapi.ns(myNetrc['openshift.local'].ns).buildconfigs.post({ body: JSON.parse(bc) },function(err,result){
          console.log('Creating Build Config....');  
        });
        
        var is=tmpl(JSON.stringify(oc_app_json.items[0]),oc_app);
        oapi.ns(myNetrc['openshift.local'].ns).imagestreams.post({ body: JSON.parse(is) },function(err,result){
          console.log('Creating Image stream....');
        });
        
        var dc=tmpl(JSON.stringify(oc_app_json.items[2]),oc_app);
        oapi.ns(myNetrc['openshift.local'].ns).deploymentconfigs.post({ body: JSON.parse(dc) },function(err,result){
          console.log('Creating Deployment Config....');
        });
        
        var svc=tmpl(JSON.stringify(oc_app_json.items[3]),oc_app);
        coapi.ns(myNetrc['openshift.local'].ns).services.post({ body: JSON.parse(svc) },function(err,result){
          console.log('Creating Service....');
        });
        
        var route=tmpl(JSON.stringify(oc_app_json.items[4]),oc_app);
        oapi.ns(myNetrc['openshift.local'].ns).routes.post({ body: JSON.parse(route) },function(err,result){
          console.log('Creating  Route.... http://'+result.spec.host);
        });
        oc_app.username_hash= new Buffer(oc_app.username).toString('base64');
        oc_app.password_hash= new Buffer(oc_app.password).toString('base64');
        var secret=tmpl(JSON.stringify(oc_app_json.items[5]),oc_app);
        coapi.ns(myNetrc['openshift.local'].ns).secret.post({ body: JSON.parse(secret) },function(err,result){
          console.log('Creating Secret....');
        });
        
        //create webhook on gogs
        gogsAPI.createGogsWebhook(app,{
          "username": myNetrc['openshift.local'].login,
          "password": myNetrc['openshift.local'].password
        },"https://kubernetes.default/oapi/v1/namespaces/myproject/buildconfigs/"+app+"/webhooks/"+webhook+"/generic").then(function(){
            simpleGit.init(null,function(){
              simpleGit.addRemote("openshift",'http://'+myNetrc['openshift.local'].gitserver+'/'+myNetrc['openshift.local'].login+'/'+app, function(err,res){
                  console.log("Adding remote git repo");
              });
            });
        }).catch(function(err){
          console.log(err);
        });  
        //end webhook

      }).catch(function(err){
        console.log(err);
      });
       process.stdin.destroy();
    });  //close choose build pack
  });

prog.parse(process.argv);
