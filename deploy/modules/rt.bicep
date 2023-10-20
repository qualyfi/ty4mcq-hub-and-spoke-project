param parLocation string
param parAfwName string

//Declaring Firewall as resource to reference in route table
resource resAfw 'Microsoft.Network/azureFirewalls@2023-05-01' existing = {
  name: parAfwName
}
//Route table sending all traffic to Firewall
resource resRouteTable 'Microsoft.Network/routeTables@2023-05-01' = {
  name: 'rt-${parLocation}-001'
  location: parLocation
  properties: {
    routes: [
      {
        name: 'Default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: resAfw.properties.ipConfigurations[0].properties.privateIPAddress
          hasBgpOverride: false
        }
      }
    ]
  }
}
output outRtName string = resRouteTable.name
