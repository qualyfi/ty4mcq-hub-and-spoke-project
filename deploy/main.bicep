param parLocation string = resourceGroup().location
param parUtc string = utcNow()
param parSecKeyVaultName string
param parUserObjectId string

resource resSecKv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: parSecKeyVaultName
}

module modHub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    parLocation: parLocation
    parSpokeName: 'hub'
    parVnetAddressPrefix: '10.10.0.0/16'
    
    parGatewaySubnetAddressPrefix: '10.10.1.0/24'
    parAppgwSubnetAddressPrefix: '10.10.2.0/24'
    parAzureFirewallSubnetAddressPrefix: '10.10.3.0/24'
    parAzureBastionSubnetAddressPrefix: '10.10.4.0/24'

    parWaPDnsZoneName: modWaPDnsZone.outputs.outPDnsZoneName
    parSqlPDnsZoneName: modSqlPDnsZone.outputs.outPDnsZoneName
    parKvPDnsZoneName: modKvPDnsZone.outputs.outPDnsZoneName
  }
}

module modCore 'modules/core.bicep' = {
  name: 'core'
  params: {
    parLocation: parLocation
    parSpokeName: 'core'
    parVnetAddressPrefix: '10.20.0.0/16'
    
    parVMSubnetAddressPrefix: '10.20.1.0/24'
    parKVSubnetAddressPrefix: '10.20.2.0/24'
    parWaPDnsZoneName: modWaPDnsZone.outputs.outPDnsZoneName
    parSqlPDnsZoneName: modSqlPDnsZone.outputs.outPDnsZoneName
    parKvPDnsZoneName: modKvPDnsZone.outputs.outPDnsZoneName

    parDefaultNsgId: modDefaultNsg.outputs.outDefaultNsgId
    parRtId: modRt.outputs.outRtId

    parVmSize: 'Standard_D2S_v3'
    
    parComputerName: 'vm1core001'
    parVmAdminUsername: resSecKv.getSecret('vmAdminUsername')
    parVmAdminPassword: resSecKv.getSecret('vmAdminPassword')
    
    parPublisher: 'MicrosoftWindowsServer'
    parOffer: 'WindowsServer'
    parSku: '2022-datacenter-azure-edition'
    parVersion: 'latest'

    parUtc: parUtc
    parTenantId: subscription().tenantId
    parUserObjectId: parUserObjectId

    parKvPDnsZoneId: modKvPDnsZone.outputs.outPDnsZoneId
  }
}

module modSpokeDev 'modules/spoke.bicep' = {
  name: 'spokeDev'
  params: {
    parLocation: parLocation
    parSpokeName: 'dev'
    parVnetAddressPrefix: '10.30.0.0/16'
    
    parAppSubnetAddressPrefix: '10.30.1.0/24'
    parSqlSubnetAddressPrefix: '10.30.2.0/24'
    parStSubnetAddressPrefix: '10.30.3.0/24'

    parDefaultNsgId: modDefaultNsg.outputs.outDefaultNsgId
    parRtId: modRt.outputs.outRtId

    parUtc: parUtc
    parAspSkuName: 'B1'

    parLinuxFxVersion: 'DOTNETCORE|7.0'

    parRepoUrl: 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
    parBranch: 'master'

    parSqlAdminUsername: resSecKv.getSecret('sqlAdminUsername')
    parSqlAdminPassword: resSecKv.getSecret('sqlAdminPassword')

    parWaPDnsZoneName: modWaPDnsZone.outputs.outPDnsZoneName
    parWaPDnsZoneId: modWaPDnsZone.outputs.outPDnsZoneId
    parSqlPDnsZoneName: modSqlPDnsZone.outputs.outPDnsZoneName
    parSqlPDnsZoneId: modSqlPDnsZone.outputs.outPDnsZoneId
    parKvPDnsZoneName: modKvPDnsZone.outputs.outPDnsZoneName
  }
}

module modSpokeProd 'modules/spoke.bicep' = {
  name: 'spokeProd'
  params: {
    parLocation: parLocation
    parSpokeName: 'prod'

    parVnetAddressPrefix: '10.31.0.0/16'
    
    parAppSubnetAddressPrefix: '10.31.1.0/24'
    parSqlSubnetAddressPrefix: '10.31.2.0/24'
    parStSubnetAddressPrefix: '10.31.3.0/24'

    parDefaultNsgId: modDefaultNsg.outputs.outDefaultNsgId
    parRtId: modRt.outputs.outRtId

    parUtc: parUtc
    parAspSkuName: 'B1'

    parLinuxFxVersion: 'DOTNETCORE|7.0'

    parRepoUrl: 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
    parBranch: 'master'

    parSqlAdminUsername: resSecKv.getSecret('sqlAdminUsername')
    parSqlAdminPassword: resSecKv.getSecret('sqlAdminPassword')

    parWaPDnsZoneName: modWaPDnsZone.outputs.outPDnsZoneName
    parWaPDnsZoneId: modWaPDnsZone.outputs.outPDnsZoneId
    parSqlPDnsZoneName: modSqlPDnsZone.outputs.outPDnsZoneName
    parSqlPDnsZoneId: modSqlPDnsZone.outputs.outPDnsZoneId
    parKvPDnsZoneName: modKvPDnsZone.outputs.outPDnsZoneName
  }
}

module modPeerHubToCore 'modules/peer.bicep' = {
  name: 'peerHubToCore'
  params: {
    parSrcVnetName: modHub.outputs.outVnetName
    parTargetVnetName: modCore.outputs.outVnetName
    parTargetVnetId: modCore.outputs.outVnetId
  }
}
module modPeerCoreToHub 'modules/peer.bicep' = {
  name: 'peerCoreToHub'
  params: {
    parSrcVnetName: modCore.outputs.outVnetName
    parTargetVnetName: modHub.outputs.outVnetName
    parTargetVnetId: modHub.outputs.outVnetId
  }
}
module modPeerHubToSpokeDev 'modules/peer.bicep' = {
  name: 'peerHubToSpokeDev'
  params: {
    parSrcVnetName: modHub.outputs.outVnetName
    parTargetVnetName: modSpokeDev.outputs.outVnetName
    parTargetVnetId: modSpokeDev.outputs.outVnetId
  }
}
module modPeerSpokeDevToHub 'modules/peer.bicep' = {
  name: 'peerSpokeDevToHub'
  params: {
    parSrcVnetName: modSpokeDev.outputs.outVnetName
    parTargetVnetName: modHub.outputs.outVnetName
    parTargetVnetId: modHub.outputs.outVnetId
  }
}
module modPeerHubToSpokeProd 'modules/peer.bicep' = {
  name: 'peerHubToSpokeProd'
  params: {
    parSrcVnetName: modHub.outputs.outVnetName
    parTargetVnetName: modSpokeProd.outputs.outVnetName
    parTargetVnetId: modSpokeProd.outputs.outVnetId
  }
}
module modPeerSpokeProdToHub 'modules/peer.bicep' = {
  name: 'peerSpokeProdToHub'
  params: {
    parSrcVnetName: modSpokeProd.outputs.outVnetName
    parTargetVnetName: modHub.outputs.outVnetName
    parTargetVnetId: modHub.outputs.outVnetId
  }
}

module modDefaultNsg 'modules/nsg.bicep' = {
  name: 'defaultNsg'
  params: {
    parLocation: parLocation
  }
}

module modRt 'modules/rt.bicep' = {
  name: 'rt'
  params: {
    parLocation: parLocation
    parAfwIpAddress: '10.30.3.4'
    // parAfwIpAddress: modHub.outputs.outAfwIpAddress
  }
}

module modWaPDnsZone 'modules/privatednszone.bicep' = {
  name: 'waPDnsZone'
  params: {
    privateDnsZoneName: 'privatelink.azurewebsites.net'
  }
}
module modSqlPDnsZone 'modules/privatednszone.bicep' = {
  name: 'sqlPDnsZone'
  params: {
    privateDnsZoneName: 'privatelink${environment().suffixes.sqlServerHostname}'
  }
}
module modKvPDnsZone 'modules/privatednszone.bicep' = {
  name: 'kvPDnsZone'
  params: {
    privateDnsZoneName: 'privatelink${environment().suffixes.keyvaultDns}'
  }
}
// module modAppGw 'modules/appgw.bicep' = {
//   name: 'appGw'
//   params: {
//     parLocation: parLocation
//     parSpokeName: 'hub'
//     parAgwName: 'agw-hub-${parLocation}-001'
//     parAgwSubnetId: modHub.outputs.outAppGwSubnetId
//     parProdWaFqdn: modSpokeProd.outputs.outWaFqdn
//   }
// }
