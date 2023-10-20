param parLocation string
param parVnetName string
param parVnetAddressPrefix string

param parAppSubnetAddressPrefix string
param parSqlSubnetAddressPrefix string
param parStSubnetAddressPrefix string

param parDefaultNsgName string
param parRtName string

//Declaring Default NSG as resource to reference in Spoke VNet
resource resDefaultNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' existing = {
  name: parDefaultNsgName
}
//Declaring Route Table as resource to reference in Spoke VNet
resource resRt 'Microsoft.Network/routeTables@2023-05-01' existing = {
  name: parRtName
}

//Spoke VNet
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
        name: 'AppSubnet'
        properties: {
          addressPrefix: parAppSubnetAddressPrefix
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
          routeTable: {
            id: resRt.id
          }
        }
      }
      {
        name: 'SqlSubnet'
        properties: {
          addressPrefix: parSqlSubnetAddressPrefix
          networkSecurityGroup: {
            id: resDefaultNsg.id
          }
          routeTable: {
            id: resRt.id
          }
        }
      }
      {
        name: 'StSubnet'
        properties: {
          addressPrefix: parStSubnetAddressPrefix
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
