param parLocation string
param parSpokeName string
param parVnetAddressPrefix string

param parVMSubnetAddressPrefix string
param parKVSubnetAddressPrefix string

param parWaPDnsZoneName string
param parSqlPDnsZoneName string
param parKvPDnsZoneName string
param parKvPDnsZoneId string

param parDefaultNsgId string
param parRtId string

param parVmSize string
param parComputerName string
@secure()
param parVmAdminUsername string
@secure()
param parVmAdminPassword string
param parPublisher string
param parOffer string
param parSku string
param parVersion string

param parGuidSuffix string
param parTenantId string
param parUserObjectId string


//Core VNet + Web App/SQL Private DNS Zone Link
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

//VM + VM NIC + Antimalware/ADE Extension
resource resVm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: 'vm-${parSpokeName}-${parLocation}-001'
  location: parLocation
  properties: {
    hardwareProfile: {
      vmSize: parVmSize
    }
    osProfile: {
      computerName: parComputerName
      adminUsername: parVmAdminUsername
      adminPassword: parVmAdminPassword
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
  name: 'nic-${parSpokeName}-${parLocation}-vm-001'
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
resource resAntiMalwareVmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
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
resource resAdeVmExtension 'Microsoft.Compute/virtualMachines/extensions@2023-07-01' = {
  name: 'AzureDiskEncryption'
  location: parLocation
  parent: resVm
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'AzureDiskEncryption'
    typeHandlerVersion: '2.2'
    autoUpgradeMinorVersion: true
    settings: {
      EncryptionOperation: 'EnableEncryption'
      KeyVaultURL: resEncryptKv.properties.vaultUri
      KeyVaultResourceId: resEncryptKv.id
      KeyEncryptionAlgoritm: 'RSA-OAEP'
      VolumeType: 'All'
      ResizeOSDisk: false 
    }
  }
}

//Disk Encryption Key Vault
resource resEncryptKv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-encrypt-${parSpokeName}-${parGuidSuffix}'
  location: parLocation
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: false
    enabledForDiskEncryption: true
    publicNetworkAccess: 'Enabled'
    
    tenantId: parTenantId
    accessPolicies: [
      {
        tenantId: parTenantId
        objectId: parUserObjectId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}
resource resEncryptKvPe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pe-${parSpokeName}-${parLocation}-kv-001'
  location: parLocation
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe-${parSpokeName}-${parLocation}-kv-001'
        properties: {
          privateLinkServiceId: resEncryptKv.id
          groupIds: [
            'vault'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: resVnet.properties.subnets[1].id
    }
  }
}
resource resKvPeNic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'nic-${parSpokeName}-${parLocation}-kv-001'
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
resource resKvPeDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  name: 'kvDnsGroup'
  parent: resEncryptKvPe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'kvPeDnsZoneGroupConfig'
        properties: {
          privateDnsZoneId: parKvPDnsZoneId
        }
      }
    ]
  }
}


output outVnetName string = resVnet.name
output outVnetId string = resVnet.id
