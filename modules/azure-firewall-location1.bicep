param location string
param locationPrefix string
param tags object
param deployFirewallBasic bool
param fwAname string
param fwAvnetName string
param fwpolicyid string
param azureFirewallSubnetName string = 'AzureFirewallSubnet'
param AzureFirewallManagementSubnet string = 'AzureFirewallManagementSubnet'
param publicIPNamePrefix string = '${locationPrefix}vnetfwip'
@description('Availability zone numbers e.g. 1,2,3.')
param availabilityZones array = [
  '1'
  '2'
  '3'
]
param logAnalyticsWorkspaceId string
param numberOfFirewallPublicIPAddresses int

var azureFirewallSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', fwAvnetName, azureFirewallSubnetName)
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
  name: '${locationPrefix}VnetFWMGIp'
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

resource AzFirewallA 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: fwAname
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
          id: resourceId('Microsoft.Network/virtualNetworks/subnets', fwAvnetName, AzureFirewallManagementSubnet)
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
  scope: AzFirewallA
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

