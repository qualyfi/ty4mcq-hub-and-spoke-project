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

    parSubnet4Name: 'AzureBastionSubnet'
    parSubnet4Prefix: '10.10.4.0/24'

    parBasPublicIPName: 'pip-hub-${parLocation}-bas-001'
    parBasName: 'bas-hub-${parLocation}-001'
    parBasSku: 'Basic'
    
    parAfwPublicIPName: 'pip-hub-${parLocation}-afw-001'
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

    parPrivateIPAddress: '10.20.1.20'

    parDefaultNsgName: modDefaultNsg.outputs.outDefaultNsgName

    parVmName: 'vm-core-${parLocation}-001'
    parVmSize: 'Standard_D2S_v3'
    
    parComputerName: 'vm1core001'
    parAdminUsername: 'ty4mcq'
    parAdminPassword: 'QualyfiProject123!'
    
    parPublisher: 'MicrosoftWindowsServer'
    parOffer: 'WindowsServer'
    parSku: '2022-datacenter-azure-edition'
    parVersion: 'latest'
    
    parOsDiskCreateOption: 'FromImage'
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
