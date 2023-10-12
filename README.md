# VWAN Lab
Bicep scripts to create Azure VWAN & Azure Firewall

The script deploys:
  * One Log Analytics workspace
  * Two VETS, each on a different Azure Region.
  * one VWAN with two VWAN HUBs,  each on a different Azure Region.
  * Two Azure Firewalls, each on a different Azure Region. The Azure Firewalls have diagnostic settings sending all logs to a log analytics workspace.

You can choose to:
  * deploy VWAN or not
  * deploy Azure Firewall or not
  * how many Public IPs will be created and attached to the Azure Firewalls
  * The Azure Firewall SKU between Basic and Standard
