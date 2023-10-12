param location string
param tags object
param deployFirewallBasic bool
param fwBname string
param fwBvnetName string
param fwpolicyid string
param azureFirewallSubnetName string = 'AzureFirewallSubnet'
param AzureFirewallManagementSubnet string = 'AzureFirewallManagementSubnet'
param publicIPNamePrefix string = 'fwBip'
@description('Availability zone numbers e.g. 1,2,3.')
param availabilityZones array = [
  '1'
  '2'
  '3'
]
param logAnalyticsWorkspaceId string
param numberOfFirewallPublicIPAddresses int

var azureFirewallSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', fwBvnetName, azureFirewallSubnetName)
var azureFirewallSubnetJSON = json('{"id": "${azureFirewallSubnetId}"}')

var azureFirewallIpConfigurations = [for i in range(0, numberOfFirewallPublicIPAddresses): {
  name: 'IpBConf${i}'
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

resource managementIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'fwBManagementIp'
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
}

resource AzFirewallB 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: fwBname
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: deployFirewallBasic ? 'Basic' : 'Standard'
    }
    ipConfigurations: azureFirewallIpConfigurations
    managementIpConfiguration: {
      name: 'fwManagementIpConfig'
      properties: {
        subnet: {
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', fwBvnetName, AzureFirewallManagementSubnet)
        }
        publicIPAddress: {
          id: managementIp.id
        }
      }
    }
    firewallPolicy: {
      id: fwpolicyid
    }
  }
}

resource firewallLogs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'fwlogs'
  scope: AzFirewallB
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

