# heroku-for-openshift

```sh
jjonagam-osx:rhc cjonagam$ git remote -v
origin2	http://gogs.127.0.0.1.nip.io/admin5/test.git (fetch)
```

```
oc new-app -f http://bit.ly/openshift-nodb-template --param=HOSTNAME=gogs.127.0.0.1.nip.io
oc policy add-role-to-user admin -z gogs
```

```sh
jjonagam-osx:rhc cjonagam$ cat ~/.netrc
machine gogs.127.0.0.1.nip.io
  password c0mputer
  login admin5
```
