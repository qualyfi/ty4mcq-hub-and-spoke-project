param parLocation string
param parUtc string

param parVnetAddressPrefix string

param parAppSubnetAddressPrefix string
param parSqlSubnetAddressPrefix string
param parStSubnetAddressPrefix string

param parSpokeName string

param parDefaultNsgId string
param parRtId string

param parAspSkuName string

param parLinuxFxVersion string


param parRepoUrl string
param parBranch string

param parWaPDnsZoneName string
param parWaPDnsZoneId string

//Spoke VNet
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
        name: 'AppSubnet'
        properties: {
          addressPrefix: parAppSubnetAddressPrefix
          networkSecurityGroup: {
            id: parDefaultNsgId
          }
          routeTable: {
            id: parRtId
          }
        }
      }
      {
        name: 'SqlSubnet'
        properties: {
          addressPrefix: parSqlSubnetAddressPrefix
          networkSecurityGroup: {
            id: parDefaultNsgId
          }
          routeTable: {
            id: parRtId
          }
        }
      }
      {
        name: 'StSubnet'
        properties: {
          addressPrefix: parStSubnetAddressPrefix
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

resource resWaPDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${parWaPDnsZoneName}/${parWaPDnsZoneName}-${parSpokeName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resVnet.id
    }
  }
}

//App Service Plan + Web App + Source Controls
resource resAsp 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-${parSpokeName}-${parLocation}-001-${uniqueString(parUtc)}'
  location: parLocation
  properties: {
    reserved: true
  }
  sku: {
    name: parAspSkuName
  }
  kind: 'linux'
}
resource resWa 'Microsoft.Web/sites@2022-09-01' = {
  name: 'as-${parSpokeName}-${parLocation}-001-${uniqueString(parUtc)}'
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
  parent: resWa
  properties: {
    repoUrl: parRepoUrl
    branch: parBranch
    isManualIntegration: true
  }
}

resource resWaPe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-${parSpokeName}-${parLocation}-wa-001'
  location: parLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe-${parSpokeName}-${parLocation}-wa-001'
        properties: {
          privateLinkServiceId: resWa.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
    subnet: {
      id: resVnet.properties.subnets[0].id
    }
  }
}
resource resWaPeNic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-${parSpokeName}-${parLocation}-wa-001'
  location: parLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resVnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}
resource resWaPeDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'dnsGroupName'
  parent: resWaPe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'ipConfig'
        properties: {
          privateDnsZoneId: parWaPDnsZoneId
        }
      }
    ]
  }
}

output outVnetName string = resVnet.name
output outVnetId string = resVnet.id
output outWaName string = resWa.name
output outWaFqdn string = resWa.properties.defaultHostName
