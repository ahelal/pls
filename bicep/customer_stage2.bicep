@description('Location for all resources.')
param location string = 'westeurope'

@description('Private link resource alias')
param privateLinkResource string

@description('endpoint ip')
param endpointIP string 

@description('subnet ID')
param subnetId string 

module ep './endpoint/main.bicep' = {
  name: 'ep'
  params: {
    location: location
    subnetId: subnetId
    privateEndpointName: 'nginxEndpoint'
    privateLinkResource: privateLinkResource
    ipAddress: endpointIP
  }
}

