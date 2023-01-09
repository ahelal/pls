@description('The name of the Managed Cluster resource.')
param clusterName string

@description('Location for all resources.')
param location string = 'westeurope'

@description('ssh user name.')
param sshUser string = 'linuxuser'

@description('ssh publicKey.')
param sshKey string ='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCuctee5QdJQ4YsmLx8rRBNdkmdClE/iPctiKUaL9SroySjiyHy/T9pQYtRKeQigtjmG17EfR6cNkx7jMMZDZ+A40i0se2LFpSyNMEaLpLZgKATHZroRemIMYFcWccjqZyClCGhVs9OYbvuDw6t2uBfg6hKdDpyZbCPQNvLqJwKs5+4JVLstyJefc8tG+K70G38QmDeRpAqv4MsgEr7g6WpLaD2Q+tCvlW9Pw/o3lClfuCeqUaRxSejHIYouBzx9yrAet7iJcEOXcIl9PWVCVRtstK1vgAXAVGy/+t6VI+v3k/7I2IevaS3ZGGxN4551zqpo7o2vxkBjua+vc9m4/RXxOQdSbZPLLRQiBE5H/unxC+l4zOyA/Dd0wgYf5IhnbyW5XqaImw/ZCGpjRAnStItvrX3lG8/Bes2VI2i5prvqoIf24k9yWkXUliHchL8C8l/JBt3bbodi6xETBSjKk0u2Q2a62IkApLWNWXNjVHapiLEjAUa0yF8Q8pchl7uJhFsi8HfL8D1cjBQYUbHx+H0Ju/HKHfqDCH2F29yWfqQ1dus2Ng01hu6yiyU8Eyt70pNisf8pcsAQuEmtIh7Ufdnn/+hi2Pi25hhWk5YA/GgEwf4ddLZvlZus6wdMyCanX8eN6T/tNUSEaL6FhS05b8MetCZ1xuylaIB2Kv7FbvRQ=='

@description('Address prefix')
param vnetAddressPrefix string

@description('Subnet 1 Prefix')
param subnet1Prefix string 

@description('Subnet 2 Prefix')
param subnet2Prefix string 

module networkModule './network/main.bicep' = {
  name: 'network'
  params: {
    location: location
    vnetAddressPrefix: vnetAddressPrefix
    subnet1Prefix: subnet1Prefix
    subnet2Prefix: subnet2Prefix
  }
}

module aks './aks/main.bicep' = {
  name: 'aks'
  params: {
    clusterName: clusterName
    location: location
    subnetId: networkModule.outputs.subnetId[1].id
    linuxAdminUsername: sshUser
    sshRSAPublicKey:sshKey
    dnsPrefix: 'A'
    agentCount: 1
  }
}

module role './role/main.bicep' = {
  name: 'role'
  params: {
    principalId: aks.outputs.principalId
    name: 'customer'
  }
}


output subnetId array = networkModule.outputs.subnetId
