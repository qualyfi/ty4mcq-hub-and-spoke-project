param parSrcVnetName string
param parTargetVnetName string
param parTargetVnetId string

//Peering connection to/from Core and Hub
resource resPeerCoreToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  name: '${parSrcVnetName}/peer-${parTargetVnetName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: parTargetVnetId
    }
  }
}
