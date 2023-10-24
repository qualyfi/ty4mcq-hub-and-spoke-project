param privateDnsZoneName string

resource resPDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}
output outPDnsZoneName string = resPDnsZone.name
output outPDnsZoneId string = resPDnsZone.id
