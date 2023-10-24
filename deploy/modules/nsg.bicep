param parLocation string

//Default NSG
resource resDefaultNsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-default'
  location: parLocation
}
output outDefaultNsgId string = resDefaultNsg.id
