# AKS PLS 

## Requirements  

* You should run this scripts in Linux, MacOs or WSL
* Python3, PIP3
* Kubectl

## Setup

* git clone the repo
* Run `:/setup.sh` 
* Check the `config.yml` You would need to change the *tenant* and  *subscription* in both the *customer* and *provider*
* Run `./run.sh all` during the deployment an Azure login pop up will appear twice. first is for the *customer* workload and second is for provider *provider*.

## Overview

### Provider

Hosts a Nginx Application and exposes the application as a Service (PLS).
Provider consumes the customer PLS (Proxy) as an endpoint `10.2.128.100`

* Vnet address range: '10.2.0.0/16'
* subnet1Prefix: '10.2.128.0/24'
* subnet2Prefix: '10.2.129.0/24'
* myNic: '10.2.128.100'

### Customer

Hosts a webproxy and exposes it as Service (PLS).

* vnetAddressPrefix: '10.1.0.0/16'
* subnet1Prefix: '10.1.128.0/24'
* subnet2Prefix: '10.1.129.0/24'
* myNic: '10.1.128.100'

## Test commands

Get customer context
`az aks get-credentials --resource-group  customer --name customerAKS --overwrite-existing`

Get provider context
`az aks get-credentials --resource-group  provider --name providerAKS --overwrite-existing`

Run a curl image `kubectl run curl --image=curlimages/curl -i --tty  --restart=Never --rm -- /bin/sh` 
Run a curl image with network filter `kubectl run curl --image=curlimages/curl -i --tty  -l network=filter --restart=Never --rm -- /bin/sh`

Test curl from product context
`http_proxy=10.2.128.100:3128 curl --silent ifconfig.me`
 
Test curl from customer context
`curl 10.1.128.100`
