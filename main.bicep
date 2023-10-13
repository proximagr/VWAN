param location string = 'northeurope'
param location2 string = 'westeurope'
//vwan parameters
param vwanName string = 'myVWAN'
param vhubAName string = 'NEUVHub'
param vhubBName string = 'WEUVHub'
param vwanhubAaddressspace string = '10.100.0.0/24'
param vwanhubBaddressspace string = '10.200.0.0/24'
//vwan secure parameters
param hubfwAname string = 'NEUHubFW'
param hubfwBname string = 'WEUHubFW'
//vnet parameters
param fwAvnetName string = 'WEUFWVNet'
param fwBvnetName string = 'NEUFWVNet'
param fwAaddressPrefix string = '10.100.1.0/24'
param fwBaddressPrefix string = '10.200.1.0/24'
param fwsubnetAName string = 'AzureFirewallSubnet'
param fwAsubnetAPrefix string = '10.100.1.0/26'
param fwBsubnetAPrefix string = '10.200.1.0/26'
param fwsubnetBName string = 'AzureFirewallManagementSubnet'
param fwAsubnetBPrefix string = '10.100.1.64/26'
param fwBsubnetBPrefix string = '10.200.1.64/26'
param fwsubnetCName string = 'vmsubnet'
param fwAsubnetCPrefix string = '10.100.1.128/26'
param fwBsubnetCPrefix string = '10.200.1.128/26'
param location1VnetAddress string = '10.100.2.0/24'
param location2VnetAddress string = '10.200.2.0/24'
param location1SubnetAddress string = '10.100.2.0/28'
param location2SubnetAddress string = '10.200.2.0/28'
//firewall parameters
param fwAname string = 'myFirewall'
param fwBname string = 'myFirewall2'
@description('Number of public IP addresses for the Azure Firewall')
@minValue(1)
@maxValue(100)
param numberOfFirewallPublicIPAddresses int
//log analytics parameters
param logAnalyticsWorkspaceName string = 'firewallogs'
param logAnalyticsSku string = 'PerGB2018'
//VMs parameters
@secure()
param adminPassword string
param adminUserName string
param vmSize string = 'Standard_B2s'

//create tags
var tags = {
  Deployment:deployment().name
}

//choose what to deploy
param deployVWAN bool
param addFirewallToVWAN bool
param deployFirewall bool
param deployFirewallBasic bool
param deployVMs bool

module firewallogs 'modules/loganalytics.bicep' = {
  name: 'firewallogs'
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logAnalyticsSku: logAnalyticsSku
    tags: tags
  }
}

module firewallpolicy 'modules/azure-firewall-policy.bicep' = if (deployFirewall) {
  name: 'firewallpolicy'
  params: {
    location: location
    tags: tags
    deployFirewallBasic: deployFirewallBasic
  }
}

module vwan './modules/vwan.bicep' = if (deployVWAN) {
  name: vwanName
  params: {
    location: location
    location2: location2
    tags: tags
    vwanName: vwanName
    vhubAName: vhubAName
    vhubBName: vhubBName
    vwanhubAaddressspace: vwanhubAaddressspace
    vwanhubBaddressspace: vwanhubBaddressspace
    addFirewallToVWAN: addFirewallToVWAN
    hubfwAname: addFirewallToVWAN ? hubfwAname : ''
    hubfwBname: addFirewallToVWAN ? hubfwBname : ''
    logAnalyticsWorkspaceId: firewallogs.outputs.logAnalyticsWorkspaceId
  }
}

module fwvnets './modules/vnet.bicep' = {
  name: 'fwvnets'
  params: {
    location: location
    location2: location2
    tags: tags
    fwAvnetName: fwAvnetName
    fwBvnetName: fwBvnetName
    fwAaddressPrefix: fwAaddressPrefix
    fwBaddressPrefix: fwBaddressPrefix
    fwsubnetAName: fwsubnetAName
    fwAsubnetAPrefix: fwAsubnetAPrefix
    fwBsubnetAPrefix: fwBsubnetAPrefix
    fwsubnetBName: fwsubnetBName
    fwAsubnetBPrefix: fwAsubnetBPrefix
    fwBsubnetBPrefix: fwBsubnetBPrefix
    fwsubnetCName: fwsubnetCName
    fwAsubnetCPrefix: fwAsubnetCPrefix
    fwBsubnetCPrefix: fwBsubnetCPrefix
    location1VnetAddress: location1VnetAddress
    location2VnetAddress: location2VnetAddress
    location1SubnetAddress: location1SubnetAddress
    location2SubnetAddress: location2SubnetAddress
  }
}

module AzFirewallA 'modules/azure-firewall-location1.bicep' = if (deployFirewall) {
  name: 'AzFirewallA-deployment'
  params: {
    fwAname: fwAname
    tags: tags
    location: location
    deployFirewallBasic: deployFirewallBasic
    fwAvnetName: fwAvnetName
    fwpolicyid: deployFirewall ? firewallpolicy.outputs.fwpolicyid : ''
    logAnalyticsWorkspaceId: deployFirewall ? firewallogs.outputs.logAnalyticsWorkspaceId : ''
    numberOfFirewallPublicIPAddresses: numberOfFirewallPublicIPAddresses
  }
}

module AzFirewallB 'modules/azure-firewall-location2.bicep' = if (deployFirewall) {
  name: 'AzFirewallB-deployment'
  params: {
    fwBname: fwBname
    tags: tags
    location: location2
    deployFirewallBasic: deployFirewallBasic
    fwBvnetName: fwBvnetName
    fwpolicyid: deployFirewall ? firewallpolicy.outputs.fwpolicyid : ''
    logAnalyticsWorkspaceId: deployFirewall ? firewallogs.outputs.logAnalyticsWorkspaceId : ''
    numberOfFirewallPublicIPAddresses: numberOfFirewallPublicIPAddresses
  }
}

module VirtualMachines 'modules/vms.bicep' = if (deployVMs) {
  name: 'vms'
  dependsOn: [
    fwvnets
  ]
  params: {
    location: location
    location2: location2
    tags: tags
    adminPassword: adminPassword
    adminUserName: adminUserName
    vmSize: vmSize
    subnetRef: [
      fwvnets.outputs.fwAvnetId
      fwvnets.outputs.location1vnetId
      fwvnets.outputs.fwBvnetId
      fwvnets.outputs.location2vnetId
    ]
  }
}
