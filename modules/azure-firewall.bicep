param location string
param tags object
param fwname string
param fwpolicyname string
param vnetName string
param azureFirewallSubnetName string = 'AzureFirewallSubnet'
param publicIPNamePrefix string = 'fwip'
@description('Availability zone numbers e.g. 1,2,3.')
param availabilityZones array = [
  '1'
  '2'
  '3'
]
param logAnalyticsWorkspaceId string
param numberOfFirewallPublicIPAddresses int

var azureFirewallSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, azureFirewallSubnetName)
var azureFirewallSubnetJSON = json('{"id": "${azureFirewallSubnetId}"}')

var azureFirewallIpConfigurations = [for i in range(0, numberOfFirewallPublicIPAddresses): {
  name: 'IpConf${i}'
  properties: {
    subnet: ((i == 0) ? azureFirewallSubnetJSON : null)
    publicIPAddress: {
      id: fwPublicIP[i].id
    }
  }
}]

resource fwPublicIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = [for i in range(0, numberOfFirewallPublicIPAddresses): {
  name: '${publicIPNamePrefix}${i+1}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
  zones: availabilityZones
}]

resource AzFirewallPolicy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: fwpolicyname
  location: location
  tags: tags
}

resource AzFirewall 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: fwname
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: azureFirewallIpConfigurations
    firewallPolicy: {
      id: AzFirewallPolicy.id
    }
  }
}

resource AzFirewallNetworkRuleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' = {
  name: 'NetworkAllowCollection'
  parent: AzFirewallPolicy
  properties: {
    priority: 200 
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowLanToLan'
        priority: 200
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllowLanToLan'
            sourceAddresses: [
              '10.0.0.0/8'
            ]
            destinationAddresses: [
              '10.0.0.0/8'
            ]
            destinationPorts: [
              '*'
            ]
            ipProtocols: [
              'TCP'
              'UDP'
              'ICMP'
            ]
            description: 'Allow Lan to Lan'
          }
        ]
      }
    ]
  }
}

resource firewallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'fwlogs'
  scope: AzFirewall
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'alllogs'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

