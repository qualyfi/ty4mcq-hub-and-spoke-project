param parLocation string = resourceGroup().location

module modHub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    parVnetName: 'vnet-hub-${parLocation}-001'
    parLocation: parLocation
    parVnetPrefix: '10.10.0.0/16'

    parSubnet1Name: 'GatewaySubnet'
    parSubnet1Prefix: '10.10.1.0/24'

    parSubnet2Name: 'AppgwSubnet'
    parSubnet2Prefix: '10.10.2.0/24'

    parSubnet3Name: 'AzureFirewallSubnet'
    parSubnet3Prefix: '10.10.3.0/24'

    parSubnet4Name: 'AzurebBastionSubnet'
    parSubnet4Prefix: '10.10.4.0/24'
  }
}

module modCore 'modules/core.bicep' = {
  name: 'core'
  params: {
    parVnetName: 'vnet-core-${parLocation}-001'
    parLocation: parLocation
    parVnetPrefix: '10.20.0.0/16'

    parSubnet1Name: 'VMSubnet'
    parSubnet1Prefix: '10.20.1.0/24'

    parSubnet2Name: 'KVSubnet'
    parSubnet2Prefix: '10.20.2.0/24'
  }
}

module modSpokeDev 'modules/spoke.bicep' = {
  name: 'spokeDev'
  params: {
    parVnetName: 'vnet-dev-${parLocation}-001'
    parLocation: parLocation
    parVnetPrefix: '10.30.0.0/16'

    parSubnet1Name: 'AppSubnet'
    parSubnet1Prefix: '10.30.1.0/24'

    parSubnet2Name: 'SqlSubnet'
    parSubnet2Prefix: '10.30.2.0/24'

    parSubnet3Name: 'StSubnet'
    parSubnet3Prefix: '10.30.3.0/24'
  }
}

module modSpokeProd 'modules/spoke.bicep' = {
  name: 'spokeProd'
  params: {
    parVnetName: 'vnet-prod-${parLocation}-001'
    parLocation: parLocation
    parVnetPrefix: '10.31.0.0/16'

    parSubnet1Name: 'AppSubnet'
    parSubnet1Prefix: '10.31.1.0/24'

    parSubnet2Name: 'SqlSubnet'
    parSubnet2Prefix: '10.31.2.0/24'

    parSubnet3Name: 'StSubnet'
    parSubnet3Prefix: '10.31.3.0/24'
  }
}

module modPeer 'modules/peer.bicep' = {
  name: 'peer'
  params: {
    parHubVnetName: modHub.outputs.outVnetName
    parCoreVnetName: modCore.outputs.outVnetName
    parSpokeDevVnetName: modSpokeDev.outputs.outVnetName
    parSpokeProdVnetName: modSpokeProd.outputs.outVnetName
  }
}
