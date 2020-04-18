# `kubeio`: Power tool for kubectl import resources
[![Build Status](https://travis-ci.org/FCesar/kubeio.svg?branch=master)](https://travis-ci.org/FCesar/kubeio)
```
 Help using kubeio

  -f --from         [arg] Name from context to use for get infos. Required.
  -n --namespace    [arg] Namespace to usage. Default=default
  -r --resource     [arg] Name of resource to wish obtain infos. Default=all
  -o --output       [arg] Output format. Default=json
  -h --help         Show message help
```

### Usage
Params --namesapce or -n, --resource or -r, --output or -o are default values. 
Use kubeio -h or kubeio --help to see default valus.
#### Short 
```sh
$ kubeio -f minikube          
'all.json' file saved successfully

$ kubeio -f minikube -r deployments/xpto          
'deployments_xpto.json' file saved successfully

$ kubeio -f minikube -r deployments/xpto -o wide      
'deployments_xpto.wide' file saved successfully

$ kubeio -f minikube -r deployments/xpto -o wide -n default      
'deployments_xpto.wide' file saved successfully
```

#### Full 
```sh
$ kubeio --from minikube          
'all.json' file saved successfully

$ kubeio --from minikube --resource deployments/xpto          
'deployments_xpto.json' file saved successfully

$ kubeio --from minikube --resource deployments/xpto --output wide      
'deployments_xpto.wide' file saved successfully

$ kubeio --from minikube --resource deployments/xpto --output wide --namespace default      
'deployments_xpto.wide' file saved successfully
```
