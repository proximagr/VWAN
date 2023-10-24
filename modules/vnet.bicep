param location string
param location2 string
param tags object
param fwAvnetName string
param fwBvnetName string
param fwAaddressPrefix string
param fwBaddressPrefix string
param fwsubnetAName string
param fwAsubnetAPrefix string
param fwBsubnetAPrefix string
param fwsubnetBName string
param fwAsubnetBPrefix string
param fwBsubnetBPrefix string
param fwsubnetCName string
param fwAsubnetCPrefix string
param fwBsubnetCPrefix string
param location1VnetAddress string
param location1SubnetAddress string
param location2VnetAddress string
param location2SubnetAddress string

resource fwAvnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: fwAvnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        fwAaddressPrefix
      ]
    }
    subnets: [
      {
        name: fwsubnetAName
        properties: {
          addressPrefix: fwAsubnetAPrefix
        }
      }
      {
        name: fwsubnetBName
        properties: {
          addressPrefix: fwAsubnetBPrefix
        }
      }
      {
        name: fwsubnetCName
        properties: {
          addressPrefix: fwAsubnetCPrefix
        }
      }
    ]
  }
}

resource fwBvnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: fwBvnetName
  location: location2
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        fwBaddressPrefix
      ]
    }
    subnets: [
      {
        name: fwsubnetAName
        properties: {
          addressPrefix: fwBsubnetAPrefix
        }
      }
      {
        name: fwsubnetBName
        properties: {
          addressPrefix: fwBsubnetBPrefix
        }
      }
      {
        name: fwsubnetCName
        properties: {
          addressPrefix: fwBsubnetCPrefix
        }
      }
    ]
  }
}

resource location1vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${location}spoke'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        location1VnetAddress
      ]
    }
    subnets: [
      {
        name: 'vmsubnet'
        properties: {
          addressPrefix: location1SubnetAddress
        }
      }
    ]
  }
}

resource location2vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${location2}spoke'
  location: location2
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        location2VnetAddress
      ]
    }
    subnets: [
      {
        name: 'vmsubnet'
        properties: {
          addressPrefix: location2SubnetAddress
        }
      }
    ]
  }
}

resource fwAvnetpeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: '${fwAvnet.name}-${location1vnet.name}'
  parent: fwAvnet
  properties: {
    remoteVirtualNetwork: {
      id: location1vnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource spokeAvnetpeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: '${location1vnet.name}-${fwAvnet.name}'
  parent: location1vnet
  properties: {
    remoteVirtualNetwork: {
      id: fwAvnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource fwBvnetpeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: '${fwBvnet.name}-${location2vnet.name}'
  parent: fwBvnet
  properties: {
    remoteVirtualNetwork: {
      id: location2vnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

resource spokeBvnetpeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: '${location2vnet.name}-${fwBvnet.name}'
  parent: location2vnet
  properties: {
    remoteVirtualNetwork: {
      id: fwBvnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

output fwAvnetId string = fwAvnet.properties.subnets[2].id
output location1vnetId string = location1vnet.properties.subnets[0].id
output fwBvnetId string = fwBvnet.properties.subnets[2].id
output location2vnetId string = location2vnet.properties.subnets[0].id
