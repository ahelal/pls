# AKS PLS 

## Requirements  

* You should run this scripts in Linux, MacOs or WSL
* Python3, PIP3, python-venv
* Kubectl
* az cli

## Setup

* git clone the repo
* Run `./setup.sh` 
* copy `config_template.yml` to `config.yml` `cp config_template.yml config.yml`
* Change the *tenant* and  *subscription* in both the *customer* and *provider*
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

## Test customer

From the customer view you should be able to reach the Application Service (nginx), to simulate this we will run a container and hit the Private Endpoint NIC address

Get customer context `az aks get-credentials --resource-group  customer --name customerAKS --overwrite-existing`

Run a curl image `kubectl run curl --image=curlimages/curl -i --tty  --restart=Never --rm -- /bin/sh` 

Test curl from customer context `curl 10.1.128.100`


## Test Provider

From the provider view any pod that has a label of `network filter` it's egress will be restricted with security group

Get provider context `az aks get-credentials --resource-group  provider --name providerAKS --overwrite-existing`

Run a curl image with network filter `kubectl run curl --image=curlimages/curl -i --tty  -l network=filter --restart=Never --rm -- /bin/sh`

Test curl from product context with proxy `http_proxy=10.2.128.100:3128 curl --silent ifconfig.me` you should get the Public IP of LB in the customer AKS subscription

Test curl from product context without the proxy setting `curl --silent ifconfig.me` it should time out since we have network policy that blocks that.


## Debugging errors

* If error occurs it could be an intermittent error just run the script again 
* If you have a bicep error you can check the azure portal and then head to the desired resource group `customer` or `provider` and check the deployment section in the blade and you should see the errors
* Other types of error are probably template error and naming.

