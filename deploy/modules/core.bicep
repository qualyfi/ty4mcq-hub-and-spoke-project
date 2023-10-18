param parVnetName string
param parLocation string
param parVnetPrefix string

param parSubnet1Name string
param parSubnet1Prefix string
var varSubnet1Ref = resourceId('Microsoft.Network/virtualNetworks/subnets', parVnetName, parSubnet1Name)

param parSubnet2Name string
param parSubnet2Prefix string

param parPrivateIPAllocationMethod string
param parPrivateIPAddress string

param parDefaultNsgName string

param parVmName string
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

param parOsDiskCreateOption string

resource resDefaultNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = {
  name: parDefaultNsgName
}


resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: parVnetName
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        parVnetPrefix
      ]
    }
    subnets: [
      {
        name: parSubnet1Name
        properties: {
          addressPrefix: parSubnet1Prefix
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
        }
      }
      {
        name: parSubnet2Name
        properties: {
          addressPrefix: parSubnet2Prefix
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
        }
      }
    ]
  }
}
output outVnetName string = resVnet.name

resource ResVm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: parVmName
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
        createOption: parOsDiskCreateOption
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resNic.id
        }
      ]
    }
  }
}
resource resNic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-${parVmName}'
  location: parLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: parPrivateIPAllocationMethod
          privateIPAddress: parPrivateIPAddress
          
          subnet: {
            id: varSubnet1Ref
          }
        }
      }
    ]
  }
}
