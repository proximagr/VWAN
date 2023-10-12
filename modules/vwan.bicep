param location string
param location2 string
param tags object
param vwanName string
param vhubAName string
param vhubBName string
param vwanhubAaddressspace string
param vwanhubBaddressspace string

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

output vhubAId string = vhubA.id
output vhubBId string = vhubB.id
