param location string
param tags object
param deployFirewallBasic bool
param fwpolicyname string = deployFirewallBasic ? 'BasicFWPolicy' : 'STDFWPolicy'

resource AzFirewallPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' = {
  name: fwpolicyname
  location: location
  tags: tags
  properties: {
    sku: {
      tier: deployFirewallBasic ? 'Basic' : 'Standard'
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

output fwpolicyid string = AzFirewallPolicy.id
