# `kubeio`: Power tool for kubectl import resources
[![Build Status](https://travis-ci.org/FCesar/kubeio.svg?branch=master)](https://travis-ci.org/FCesar/kubeio)
[![codecov](https://codecov.io/gh/FCesar/kubeio/branch/master/graph/badge.svg)](https://codecov.io/gh/FCesar/kubeio)
```
 Help using kubeio

  -f --from         [arg] Name from context to use for get infos. Required.
  -n --namespace    [arg] Namespace to usage. Default=default
  -r --resource     [arg] Name of resource to wish obtain infos. Default=all
  -o --output       [arg] Output format. Default=json
  -h --help         Show message help
```

### Usage
Params --namesapce or -n, --resource or -r, --output or -o are default values
Use kubeio -h or kubeio --help to see default values.
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

== Installing Kubeio from source

Check out a copy of the **kubeio** repository. Then, either add the **kubeio**
`bin` directory to your `$PATH`, or run the provided `install.sh`
command with the location to the prefix in which you want to install
**kubeio**. For example, to install Bats into `/usr/local`,

    $ git clone [repository_url]
    $ cd kubeio
    $ ./install.sh /usr/local

Note that you may need to run `install.sh` with `sudo` if you do not
have permission to write to the installation prefi
