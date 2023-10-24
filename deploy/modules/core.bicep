param parLocation string
param parSpokeName string
param parVnetAddressPrefix string

param parVMSubnetAddressPrefix string
param parKVSubnetAddressPrefix string

param parDefaultNsgId string
param parRtId string

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

//Core VNet
resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-${parSpokeName}-${parLocation}-001'
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
            id: parDefaultNsgId
          }
          routeTable: {
            id: parRtId
          }
        }
      }
      {
        name: 'KVSubnet'
        properties: {
          addressPrefix: parKVSubnetAddressPrefix
          networkSecurityGroup: {
            id: parDefaultNsgId
          }
          routeTable: {
            id: parRtId
          }
        }
      }
    ]
  }
}
output outVnetName string = resVnet.name
output outVnetId string = resVnet.id

//VM + VM NIC + VM Extension
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
resource resVmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'IaaSAntimalware'
  location: parLocation
  parent: resVm
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      AntimalwareEnabled: 'true'
    }
  }
}
