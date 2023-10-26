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

@secure()
param parSqlAdminUsername string
@secure()
param parSqlAdminPassword string

param parWaPDnsZoneName string
param parWaPDnsZoneId string
param parSqlPDnsZoneName string
param parSqlPDnsZoneId string
param parKvPDnsZoneName string

//Spoke VNet + Private DNS Zone Link
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
resource resSqlPDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${parSqlPDnsZoneName}/${parSqlPDnsZoneName}-${parSpokeName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resVnet.id
    }
  }
}
resource resKvPDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${parKvPDnsZoneName}/${parKvPDnsZoneName}-${parSpokeName}-link'
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

//Web App Private Endpoint + Private Endpoint NIC + Private Endpoint DNS Group
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
  name: 'waPeDnsGroup'
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

//SQL Server + Database
resource resSqlServer 'Microsoft.Sql/servers@2021-11-01' ={
  name: 'sql-${parSpokeName}-${parLocation}-001-${uniqueString(parUtc)}'
  location: parLocation
  properties: {
    administratorLogin: parSqlAdminUsername
    administratorLoginPassword: parSqlAdminPassword
    publicNetworkAccess: 'Disabled'
  }
}
resource resSqlDb 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: resSqlServer
  name: 'sqldb-${parSpokeName}-${parLocation}-001'
  location: parLocation
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
}

//SQL Private Endpoint + Private Endpoint NIC + Private Endpoint DNS Group
resource resSqlPe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-${parSpokeName}-${parLocation}-sql-001'
  location: parLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe-${parSpokeName}-${parLocation}-sql-001'
        properties: {
          privateLinkServiceId: resSqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
    subnet: {
      id: resVnet.properties.subnets[1].id
    }
  }
}
resource resSqlPeNic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-${parSpokeName}-${parLocation}-sql-001'
  location: parLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resVnet.properties.subnets[1].id
          }
        }
      }
    ]
  }
}
resource resSqlPeDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'sqlPeDnsGroup'
  parent: resSqlPe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'ipConfig'
        properties: {
          privateDnsZoneId: parSqlPDnsZoneId
        }
      }
    ]
  }
}


output outVnetName string = resVnet.name
output outVnetId string = resVnet.id
output outWaName string = resWa.name
output outWaFqdn string = resWa.properties.defaultHostName
