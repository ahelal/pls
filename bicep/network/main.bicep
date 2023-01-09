@description('VNet name')
param vnetName string = 'VNet1'

@description('Address prefix')
param vnetAddressPrefix string = '10.1.0.0/16'

@description('Subnet 1 Prefix')
param subnet1Prefix string = '10.1.128.0/24'

@description('Subnet 1 Name')
param subnet1Name string = 'Subnet1'

@description('Subnet 2 Prefix')
param subnet2Prefix string = '10.1.129.0/24'

@description('Subnet 2 Name')
param subnet2Name string = 'Subnet2'

@description('Location for all resources.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2Prefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subnetId array = vnet.properties.subnets
