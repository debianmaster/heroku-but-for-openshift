const OpenShiftClient = require('openshift-client');

// Get Deployments from a specific namespace
const oapi = new OpenShiftClient.OApi({
    url: "https://127.0.0.1:8443",
    insecureSkipTlsVerify: true,
    auth: {
      bearer: 'fKL0LNHu-ISAtnzqzXql2kDmIOowBPdRuqL9MPz8dg8'
    }
});
oapi.ns('myproject').deploymentconfigs('gogs').get((err, result) => {
  if (err) throw err;
  console.log(JSON.stringify(result, null, 2));
});
