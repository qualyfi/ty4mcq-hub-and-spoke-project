param parVnetName string
param parLocation string
param parVnetPrefix string

param parSubnet1Name string
param parSubnet1Prefix string

param parSubnet2Name string
param parSubnet2Prefix string

param parSubnet3Name string
param parSubnet3Prefix string

param parDefaultNsgName string

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
      {
        name: parSubnet3Name
        properties: {
          addressPrefix: parSubnet3Prefix
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
        }
      }
    ]
  }
}

output outVnetName string = resVnet.name
