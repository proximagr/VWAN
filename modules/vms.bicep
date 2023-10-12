param adminUserName string
param location string
param location2 string
param tags object

@secure()
param adminPassword string
param vmSize string
param subnetRef array

resource nInter 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0, length(subnetRef)): {
  name: 'nicvm${i}'
  location: i < length(subnetRef)/2 ? location : location2
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef[i]
          }
        }
      }
    ]
  }
}
]

resource VMs 'Microsoft.Compute/virtualMachines@2023-07-01' = [for i in range(0, length(subnetRef)): {
  name: 'vm${i}'
  dependsOn: [
    nInter[i]
  ]
  location: i < length(subnetRef)/2 ? location : location2
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'vm${i}'
      adminUsername: adminUserName
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nInter[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
]
