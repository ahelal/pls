@description('subnet id.')
param subnetId string 

@description('Location privateLinkServiceId.')
param privateEndpointName string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Private link service resource')
param privateLinkResource string

@description('Private link service resource')
param ipAddress string

@description('Private link service resource')
param targetSubResource array = []


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    ipConfigurations: [
      {
          name: 'proxyendpoint'
          properties: {
              privateIPAddress: ipAddress
          }
      }
    ]
    customNetworkInterfaceName: 'myip-nic'
    manualPrivateLinkServiceConnections: [
      {
          name: privateEndpointName
          properties: {
              privateLinkServiceId: privateLinkResource
              groupIds: targetSubResource
              requestMessage: 'Hey I am Bicep script please connect me'
          }
      }
  ]
  }
}
