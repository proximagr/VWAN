param location string
param tags object
param vnetName string
param addressPrefix string
param subnetAName string
param subnetAPrefix string
param subnetBName string
param subnetBPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetAName
        properties: {
          addressPrefix: subnetAPrefix
        }
      }
      {
        name: subnetBName
        properties: {
          addressPrefix: subnetBPrefix
        }
      }
    ]
  }
}
//output vnet id
output vnetId string = vnet.id
output AzureFirewallSubnetId string = vnet.properties.subnets[0].id
