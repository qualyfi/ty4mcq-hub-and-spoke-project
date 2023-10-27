param parLocation string
param parAfwIpAddress string

//Route table sending all traffic to Firewall
resource resRouteTable 'Microsoft.Network/routeTables@2023-05-01' = {
  name: 'rt-${parLocation}-001'
  location: parLocation
  tags: {
    Dept: 'coreServices'
    Owner: 'coreServicesOwner'
  }
  properties: {
    routes: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: parAfwIpAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}
output outRtId string = resRouteTable.id
