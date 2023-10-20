param parLocation string = resourceGroup().location
param parKeyVaultName string

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

    parDefaultNsgName: modDefaultNsg.outputs.outDefaultNsgName
    parRtName: modRt.outputs.outRtName

    parVmSize: 'Standard_D2S_v3'
    
    parComputerName: 'vm1core001'
    parAdminUsername: 'ty4mcq'
    parAdminPassword: 'QualyfiProject123!'
    
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
    parVnetName: 'vnet-dev-${parLocation}-001'
    parVnetAddressPrefix: '10.30.0.0/16'
    
    parAppSubnetAddressPrefix: '10.30.1.0/24'
    parSqlSubnetAddressPrefix: '10.30.2.0/24'
    parStSubnetAddressPrefix: '10.30.3.0/24'

    parDefaultNsgName: modDefaultNsg.outputs.outDefaultNsgName
    parRtName: modRt.outputs.outRtName
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

    parDefaultNsgName: modDefaultNsg.outputs.outDefaultNsgName
    parRtName: modRt.outputs.outRtName

  }
}

module modPeer 'modules/peer.bicep' = {
  name: 'peer'
  params: {
    parHubVnetName: modHub.outputs.outVnetName
    parCoreVnetName: modCore.outputs.outVnetName
    parSpokeDevVnetName: modSpokeDev.outputs.outVnetName
    parSpokeProdVnetName: modSpokeProd.outputs.outVnetName  }
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
    parAfwName: modHub.outputs.outAfwName
  }
}
