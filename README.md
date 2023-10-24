# VWAN Lab
Bicep scripts to create Azure VWAN & Azure Firewall

**The script deploys**:
  * One Log Analytics workspace
  * Four VETS, two on each Azure Region.
  * one VWAN with two VWAN HUBs,  each on a different Azure Region.
  * Two Azure Firewalls inside the VWAN Hubs, each on a different Azure Region. The Azure Firewalls have diagnostic settings sending all logs to a log analytics workspace.
  * Two Azure Firewalls outside the VWAN Hubs, each on a different Azure Region. The Azure Firewalls have diagnostic settings sending all logs to a log analytics workspace.
  * Four VMs, Ubuntu, one in each VNET

**You can choose to**:
  * deploy VWAN or not
  * deploy Azure Firewall inside the VWAN Hubs
  * deploy VMs or not
  * deploy Azure Firewall outside the VWAN Hubs or not
  * how many Public IPs will be created and attached to the Azure Firewalls
  * The Azure Firewall SKU between Basic and Standard

**The script does NOT deploy the connections** between the VWAN Hubs & the VNETS. Once the VWAN Hubs are ready, with Hub Status "Succeeded" **and** Router Status "Provisioned", create the connections manually. This is because to create a connection the VWAN Hub Router Status must be "Provisioned" and currently, the is no way of getting this Status. 

The VMs are for testing & troubleshooting. Ubuntu Linux, without Public IP. I usually use the Serial console. 

## Deployment Commands for Azure Cli:

**create the Resource Group**
az group create --name ResourceGroupName --location PreferedLocation

**deploy the bicep script and answer the questions interactively**
az deployment group create --resource-group ResourceGroupName --template-file main.bicep

**deploy the bicep script with the required parameters and choose true false**
az deployment group create --resource-group ResourceGroupName --template-file main.bicep --parameters numberOfFirewallPublicIPAddresses=1 adminPassword='#########' adminUserName='######' deployVWAN=true addFirewallToVWAN=true deployFirewall=true deployFirewallBasic=true deployVMs=true

# Deployment Diagram
![vwan](https://github.com/proximagr/VWAN/assets/4180413/6c029ff9-1024-4618-82ed-d9aca040d6d1)
