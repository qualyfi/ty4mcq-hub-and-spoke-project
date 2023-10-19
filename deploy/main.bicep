param parLocation string = resourceGroup().location

module modHub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    parLocation: parLocation
  }
}

module modCore 'modules/core.bicep' = {
  name: 'core'
  params: {
    parLocation: parLocation

    parDefaultNsgName: modDefaultNsg.outputs.outDefaultNsgName

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
    parVnetName: 'vnet-dev-${parLocation}-001'
    parLocation: parLocation
    parVnetPrefix: '10.30.0.0/16'

    parSubnet1Name: 'AppSubnet'
    parSubnet1Prefix: '10.30.1.0/24'

    parSubnet2Name: 'SqlSubnet'
    parSubnet2Prefix: '10.30.2.0/24'

    parSubnet3Name: 'StSubnet'
    parSubnet3Prefix: '10.30.3.0/24'

    parDefaultNsgName: modDefaultNsg.outputs.outDefaultNsgName
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

    parDefaultNsgName: modDefaultNsg.outputs.outDefaultNsgName
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

module modDefaultNsg 'modules/nsg.bicep' = {
  name: 'defaultNsg'
  params: {
    parLocation: parLocation
  }
}
