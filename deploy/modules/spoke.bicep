param parLocation string
param parVnetName string
param parVnetAddressPrefix string

param parAppSubnetAddressPrefix string
param parSqlSubnetAddressPrefix string
param parStSubnetAddressPrefix string

param parDefaultNsgName string
param parRtName string

param parAspName string
param parAspSkuName string

param parAsName string
param parLinuxFxVersion string

param parRepoUrl string
param parBranch string

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

resource resAsp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: parAspName
  location: parLocation
  properties: {
    reserved: true
  }
  sku: {
    name: parAspSkuName
  }
  kind: 'linux'
}

resource resAs 'Microsoft.Web/sites@2022-09-01' = {
  name: parAsName
  location: parLocation
  properties: {
    serverFarmId: resAsp.id
    publicNetworkAccess: 'Disabled'
    siteConfig: {
      linuxFxVersion: parLinuxFxVersion
    }
  }
}

resource resSrcControls 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = {
  name: 'web'
  parent: resAs
  properties: {
    repoUrl: parRepoUrl
    branch: parBranch
    isManualIntegration: true
  }
}
