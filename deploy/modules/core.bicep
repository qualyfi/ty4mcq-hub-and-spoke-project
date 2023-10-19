param parLocation string

param parDefaultNsgName string

param parVmSize string
param parComputerName string
@secure()
param parAdminUsername string
@secure()
param parAdminPassword string
param parPublisher string
param parOffer string
param parSku string
param parVersion string

resource resDefaultNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = {
  name: parDefaultNsgName
}


resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-core-${parLocation}-001'
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'VMSubnet'
        properties: {
          addressPrefix: '10.20.1.0/24'
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
        }
      }
      {
        name: 'KVSubnet'
        properties: {
          addressPrefix: '10.20.2.0/24'
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
        }
      }
    ]
  }
}
output outVnetName string = resVnet.name

resource resVm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: 'vm-core-${parLocation}-001'
  location: parLocation
  properties: {
    hardwareProfile: {
      vmSize: parVmSize
    }
    osProfile: {
      computerName: parComputerName
      adminUsername: parAdminUsername
      adminPassword: parAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: parPublisher
        offer: parOffer
        sku: parSku
        version: parVersion
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resVmNic.id
        }
      ]
    }
  }
}
resource resVmNic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-core-${parLocation}-vm-001'
  location: parLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.20.1.20'
          
          subnet: {
            id: resVnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

