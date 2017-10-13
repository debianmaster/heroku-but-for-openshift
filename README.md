# heroku-for-openshift

```sh
jjonagam-osx:rhc cjonagam$ git remote -v
origin2	http://gogs.127.0.0.1.nip.io/admin5/test.git (fetch)
```

```
oc new-app -f http://bit.ly/openshift-nodb-template --param=HOSTNAME=gogs.127.0.0.1.nip.io
```

```sh
jjonagam-osx:rhc cjonagam$ cat ~/.netrc
machine gogs.127.0.0.1.nip.io
  password c0mputer
  login admin5
```
<<<<<<< HEAD

=======
>>>>>>> 03623e8d01226b607b888995181ae9f140a1d4b6
