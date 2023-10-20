param parHubVnetName string
param parCoreVnetName string
param parSpokeDevVnetName string
param parSpokeProdVnetName string

//Declaring existing VNets as resources to reference in peering resources
resource resHubVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: parHubVnetName
}
resource resCoreVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: parCoreVnetName
}
resource resSpokeDevVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: parSpokeDevVnetName
}
resource resSpokeProdVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: parSpokeProdVnetName
}

//Peering connection to/from Core and Hub
resource resPeerCoreToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: 'peer-${parCoreVnetName}-to-${parHubVnetName}'
  parent: resCoreVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resHubVnet.id
    }
  }
}
resource resPeerHubToCore 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: 'peer-${parHubVnetName}-to-${parCoreVnetName}'
  parent: resHubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resCoreVnet.id
    }
  }
}

//Peering connection to/from SpokeDev and Hub
resource resPeerSpokeDevToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: 'peer-${parSpokeDevVnetName}-to-${parHubVnetName}'
  parent: resSpokeDevVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resHubVnet.id
    }
  }
}
resource resPeerHubToSpokeDev 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: 'peer-${parHubVnetName}-to-${parSpokeDevVnetName}'
  parent: resHubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resSpokeDevVnet.id
    }
  }
}

//Peering connection to/from SpokeProd and Hub
resource resPeerSpokeProdToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: 'peer-${parSpokeProdVnetName}-to-${parHubVnetName}'
  parent: resSpokeProdVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resHubVnet.id
    }
  }
}
resource resPeerHubToSpokeProd 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: 'peer-${parHubVnetName}-to-${parSpokeProdVnetName}'
  parent: resHubVnet
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resSpokeProdVnet.id
    }
  }
}
