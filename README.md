# Introduction 
A repo to test syncing secrets from kubernetes to AKV via kubewatch and a webhook.

part of this blog: https://freshbrewed.science/kubewatch-to-akv-for-dr/

# Getting Started
1. create a webhook
2. setup a group variable (library) with your k8s config (so AzDO can read secret)
2. install kubewatch via helm


## helm values

e.g. if my webhook name is `k8sevents`, then it would look like
```
$ helm get values kubewatch
USER-SUPPLIED VALUES:
msteams:
  enabled: true
  webhookurl: https://princessking.webhook.office.com/webhookb2/….snip….
rbac:
  create: true
resourcesToWatch:
  clusterrole: false
  configmap: false
  daemonset: false
  deployment: false
  ingress: false
  job: false
  namespace: false
  node: false
  persistentvolume: false
  pod: false
  replicaset: false
  replicationcontroller: false
  secret: true
  serviceaccount: false
  services: false
slack:
  enabled: false
webhook:
  enabled: true
  url: https://dev.azure.com/princessking/_apis/public/distributedtask/webhooks/k8sevents?api-version=6.0-preview
```

## group variable

e.g. webhooklibrary with k8sconfig set to the base64'ed kubeconfig (using, of course, external IPs that are reachable by Azure DevOps)

# Build and Test

apply a simple secret to test
```
$ cat my-secret.yaml
apiVersion: v1
data:
  key1: Y2hhbmdlZHZhbHVlCg==
  key2: Y2hhbmdlZHZhbHVlCg==
kind: Secret
metadata:
  name: my-secret6
  namespace: default
type: Opaque

$ kubectl apply -f my-secret.yaml
secret/my-secret6 configured
```

# Contribute

Fork and PR back.
