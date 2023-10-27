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
param locationPrefix string
param location2Prefix string

resource locationNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${locationPrefix}nsg'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'allowLanIn'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 500
          protocol: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          sourcePortRange: '*'
          destinationAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          destinationPortRange: '*'
        }
      }
      {
        name: 'allowLanOut'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 400
          protocol: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          sourcePortRange: '*'
          destinationAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource location2Nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: '${location2Prefix}nsg'
  location: location2
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'allowLanIn'
        properties: {
          access: 'Allow'
          direction: 'Inbound'
          priority: 500
          protocol: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          sourcePortRange: '*'
          destinationAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          destinationPortRange: '*'
        }
      }
      {
        name: 'allowLanOut'
        properties: {
          access: 'Allow'
          direction: 'Outbound'
          priority: 400
          protocol: '*'
          sourceAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          sourcePortRange: '*'
          destinationAddressPrefixes: [
            '10.0.0.0/8'
            '192.168.0.0/16'
            '172.16.0.0/12'
          ]
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource locationUdr 'Microsoft.Network/routeTables@2023-05-01' = {
  name: '${locationPrefix}udr'
  location: location
  tags: tags
  properties: {
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.100.1.4'
        }
      }
      ]
      disableBgpRoutePropagation: true
  }
}

resource location2Udr 'Microsoft.Network/routeTables@2023-05-01' = {
  name: '${location2Prefix}udr'
  location: location2
  tags: tags
  properties: {
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.200.1.4'
        }
      }
      ]
      disableBgpRoutePropagation: true
  }
}

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
          networkSecurityGroup: {
            id: locationNsg.id
          }
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
          networkSecurityGroup: {
            id: location2Nsg.id
          }
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
          routeTable: {
            id: locationUdr.id
          }
          networkSecurityGroup: {
            id: locationNsg.id
          }
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
          routeTable: {
            id: location2Udr.id
          }
          networkSecurityGroup: {
            id: location2Nsg.id
          }
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
