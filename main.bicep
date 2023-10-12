param location string = 'northeurope'
param vwanName string = 'myVWAN'
param vhubName string = 'NEUVHub'
param vnetName string = 'FirewallVNet'
param fwname string = 'myFirewall'
param fwpolicyname string = 'myFirewallPolicy'
param logAnalyticsWorkspaceName string = 'firewallogs'
param logAnalyticsSku string = 'PerGB2018'
@description('Number of public IP addresses for the Azure Firewall')
@minValue(1)
@maxValue(100)
param numberOfFirewallPublicIPAddresses int

//create tags
var tags = {
  Region: location
  Deployment:deployment().name
}

//choose what to deploy
param deployVWAN bool
param deployFirewall bool

module firewallogs 'modules/loganalytics.bicep' = {
  name: 'firewallogs'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsSku: logAnalyticsSku
    tags: tags
  }
}

module vwan './modules/vwan.bicep' = if (deployVWAN) {
  name: vwanName
  params: {
    location: location
    tags: tags
    vwanName: vwanName
    vhubName: vhubName
    vwanhubaddressspace: '10.1.0.0/24'
  }
}

module vnet './modules/vnet.bicep' = {
  name: vnetName
  params: {
    location: location
    tags: tags
    addressPrefix: '10.0.0.0/22'
    vnetName: vnetName
    subnetAName: 'AzureFirewallSubnet'
    subnetAPrefix: '10.0.0.0/24'
    subnetBName: 'AzureFirewallManagementSubnet'
    subnetBPrefix: '10.0.1.0/24'
  }
}

module AzFirewall 'modules/azure-firewall.bicep' = if (deployFirewall) {
  name: 'AzFirewall-deployment'
  params: {
    fwname: fwname
    tags: tags
    location: location
    vnetName: vnetName
    fwpolicyname: fwpolicyname
    logAnalyticsWorkspaceId: firewallogs.outputs.logAnalyticsWorkspaceId
    numberOfFirewallPublicIPAddresses: numberOfFirewallPublicIPAddresses
  }
}
