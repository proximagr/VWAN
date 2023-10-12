param location string
param tags object
param vwanName string
param vhubName string
param vwanhubaddressspace string

resource vwan 'Microsoft.Network/virtualWans@2021-02-01' = {
  name: vwanName
  tags: tags
  location: location
  properties: {
    type: 'Standard'
  }
}

resource vhub 'Microsoft.Network/virtualHubs@2021-02-01' = {
  name: vhubName
  tags: tags
  location: location
  properties: {
    virtualWan: {
      id: vwan.id
    }
    addressPrefix: vwanhubaddressspace
  }
}

output vhubId string = vhub.id
