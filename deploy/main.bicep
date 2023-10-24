param parLocation string = resourceGroup().location
param utc string = utcNow()
param parKeyVaultName string

resource resKv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: parKeyVaultName
}

module modHub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    parLocation: parLocation
    parVnetName: 'vnet-hub-${parLocation}-001'
    parVnetAddressPrefix: '10.10.0.0/16'
    
    parGatewaySubnetAddressPrefix: '10.10.1.0/24'
    parAppgwSubnetAddressPrefix: '10.10.2.0/24'
    parAzureFirewallSubnetAddressPrefix: '10.10.3.0/24'
    parAzureBastionSubnetAddressPrefix: '10.10.4.0/24'

  }
}

module modCore 'modules/core.bicep' = {
  name: 'core'
  params: {
    parLocation: parLocation
    parVnetName: 'vnet-core-${parLocation}-001'
    parVnetAddressPrefix: '10.20.0.0/16'
    
    parVMSubnetAddressPrefix: '10.20.1.0/24'
    parKVSubnetAddressPrefix: '10.20.2.0/24'

    parDefaultNsgId: modDefaultNsg.outputs.outDefaultNsgId
    parRtId: modRt.outputs.outRtId

    parVmSize: 'Standard_D2S_v3'
    
    parComputerName: 'vm1core001'
    parAdminUsername: resKv.getSecret('vmAdminUsername')
    parAdminPassword: resKv.getSecret('vmAdminPassword')
    
    parPublisher: 'MicrosoftWindowsServer'
    parOffer: 'WindowsServer'
    parSku: '2022-datacenter-azure-edition'
    parVersion: 'latest'
  }
}

module modSpokeDev 'modules/spoke.bicep' = {
  name: 'spokeDev'
  params: {
    parLocation: parLocation
    // parSpokeName: 'dev'
    parVnetName: 'vnet-dev-${parLocation}-001'
    parVnetAddressPrefix: '10.30.0.0/16'
    
    parAppSubnetAddressPrefix: '10.30.1.0/24'
    parSqlSubnetAddressPrefix: '10.30.2.0/24'
    parStSubnetAddressPrefix: '10.30.3.0/24'

    parSpokeName: 'dev'

    parDefaultNsgId: modDefaultNsg.outputs.outDefaultNsgId
    parRtId: modRt.outputs.outRtId

    parAspName: 'asp-dev-${parLocation}-001-${uniqueString(utc)}'
    parAspSkuName: 'B1'

    parWaName: 'as-dev-${parLocation}-001-${uniqueString(utc)}'
    parLinuxFxVersion: 'DOTNETCORE|7.0'

    parRepoUrl: 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
    parBranch: 'master'

    parWaPeName: 'pe-dev-${parLocation}-wa-001'
    // parWaPeNicName: 'nic-dev-${parLocation}-wa-001'
    parWaPDnsZoneName: modWaPDnsZone.outputs.outPDnsZoneName
    parWaPDnsZoneId: modWaPDnsZone.outputs.outPDnsZoneId
  }
}

module modSpokeProd 'modules/spoke.bicep' = {
  name: 'spokeProd'
  params: {
    parLocation: parLocation
    parVnetName: 'vnet-prod-${parLocation}-001'
    parVnetAddressPrefix: '10.31.0.0/16'
    
    parAppSubnetAddressPrefix: '10.31.1.0/24'
    parSqlSubnetAddressPrefix: '10.31.2.0/24'
    parStSubnetAddressPrefix: '10.31.3.0/24'

    parSpokeName: 'prod'

    parDefaultNsgId: modDefaultNsg.outputs.outDefaultNsgId
    parRtId: modRt.outputs.outRtId

    parAspName: 'asp-prod-${parLocation}-001-${uniqueString(utc)}'
    parAspSkuName: 'B1'

    parWaName: 'as-prod-${parLocation}-001-${uniqueString(utc)}'
    parLinuxFxVersion: 'DOTNETCORE|7.0'

    parRepoUrl: 'https://github.com/Azure-Samples/dotnetcore-docs-hello-world'
    parBranch: 'master'

    parWaPeName: 'pe-prod-${parLocation}-wa-001'
    // parWaPeNicName: 'nic-prod-${parLocation}-wa-001'
    parWaPDnsZoneName: modWaPDnsZone.outputs.outPDnsZoneName
    parWaPDnsZoneId: modWaPDnsZone.outputs.outPDnsZoneId
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
    // parAfwIpAddress: modHub.outputs.outAfwName

  }
}

module modWaPDnsZone 'modules/privatednszone.bicep' = {
  name: 'waPDnsZone'
  params: {
    privateDnsZoneName: 'privatelink.azurewebsites.net'
  }
}
