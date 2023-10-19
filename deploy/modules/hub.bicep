param parVnetName string
param parLocation string
param parVnetPrefix string

param parSubnet1Name string
param parSubnet1Prefix string

param parSubnet2Name string
param parSubnet2Prefix string

param parSubnet3Name string
param parSubnet3Prefix string


param parSubnet4Name string
param parSubnet4Prefix string

param parBasPublicIPName string
param parBasName string
param parBasSku string

param parAfwPublicIPName string

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
        }
      }
      {
        name: parSubnet2Name
        properties: {
          addressPrefix: parSubnet2Prefix
        }
      }
      {
        name: parSubnet3Name
        properties: {
          addressPrefix: parSubnet3Prefix
        }
      }
      {
        name: parSubnet4Name
        properties: {
          addressPrefix: parSubnet4Prefix
        }
      }
    ]
  }
}
output outVnetName string = resVnet.name

resource resBasPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: parBasPublicIPName
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource resBastionHost 'Microsoft.Network/bastionHosts@2023-05-01' = {
  name: parBasName
  location: parLocation
  sku: {
    name: parBasSku
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod:'Dynamic'
          publicIPAddress: {
            id: resBasPublicIP.id
          }
          subnet: {
            id: resVnet.properties.subnets[3].id
          }
        }
      }
    ]
  }
}

resource resAfwPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: parAfwPublicIPName
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
