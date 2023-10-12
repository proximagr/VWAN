param logAnalyticsWorkspaceName string
param logAnalyticsSku string
param location string
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    sku: {
      name: logAnalyticsSku
    }
  }
}
//output the workspace id
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
