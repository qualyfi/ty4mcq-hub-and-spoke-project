param parVnetName string
param parLocation string
param parVnetPrefix string

param parSubnet1Name string
param parSubnet1Prefix string

param parSubnet2Name string
param parSubnet2Prefix string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
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
    ]
  }
}
