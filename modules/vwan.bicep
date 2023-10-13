param location string
param location2 string
param tags object
param vwanName string
param vhubAName string
param vhubBName string
param vwanhubAaddressspace string
param vwanhubBaddressspace string
//vwan firewall parameters
param addFirewallToVWAN bool
param hubfwAname string
param hubfwBname string
param fwpolicyid string
param logAnalyticsWorkspaceId string

resource vwan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: vwanName
  tags: tags
  location: location
  properties: {
    type: 'Standard'
  }
}

resource vhubA 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: vhubAName
  tags: tags
  location: location
  properties: {
    virtualWan: {
      id: vwan.id
    }
    addressPrefix: vwanhubAaddressspace
  }
}

resource vhubB 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: vhubBName
  tags: tags
  location: location2
  properties: {
    virtualWan: {
      id: vwan.id
    }
    addressPrefix: vwanhubBaddressspace
  }
}

//add firεwall to vwans
resource AzFirewallPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' = {
  name: 'vwanFwPolicy'
  location: location
  tags: tags
  properties: {
    sku: {
      tier: 'Standard'
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


resource hubAzFirewallA 'Microsoft.Network/azureFirewalls@2023-05-01' = if (addFirewallToVWAN) {
  name: hubfwAname
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    virtualHub: {
      id: vhubA.id
    }
    firewallPolicy: {
      id: AzFirewallPolicy.id
    }
  }
}

resource hubfirewallaLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (addFirewallToVWAN) {
  name: 'hubfirewallaLogs'
  scope: hubAzFirewallA
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

resource hubAzFirewallB 'Microsoft.Network/azureFirewalls@2023-05-01' = if (addFirewallToVWAN) {
  name: hubfwBname
  location: location2
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    virtualHub: {
      id: vhubB.id
    }
    firewallPolicy: {
      id: AzFirewallPolicy.id
    }
  }
}

resource hubfirewallbLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (addFirewallToVWAN) {
  name: 'hubfirewallbLogs'
  scope: hubAzFirewallB
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

//outputs
output vhubAId string = vhubA.id
output vhubBId string = vhubB.id
