param parLocation string
param parVnetName string
param parVnetAddressPrefix string

param parVMSubnetAddressPrefix string
param parKVSubnetAddressPrefix string

param parDefaultNsgName string
param parRtName string

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

//Declaring Default NSG as resource to reference in Core VNet
resource resDefaultNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = {
  name: parDefaultNsgName
}
//Declaring Route Table as resource to reference in Core VNet
resource resRt 'Microsoft.Network/routeTables@2023-05-01' existing = {
name: parRtName
}

//Core VNet
resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: parVnetName
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        parVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'VMSubnet'
        properties: {
          addressPrefix: parVMSubnetAddressPrefix
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
          routeTable: {
            id: resRt.id
          }
        }
      }
      {
        name: 'KVSubnet'
        properties: {
          addressPrefix: parKVSubnetAddressPrefix
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
          routeTable: {
            id: resRt.id
          }
        }
      }
    ]
  }
}
output outVnetName string = resVnet.name

//VM + VM NIC
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
