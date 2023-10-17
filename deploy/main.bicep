param parLocation string = 'southuk'

module core 'modules/core.bicep' = {
  name: 'core'
  params: {
    parVnetName: 'vnet-core-location-001'
    parLocation: parLocation
    parVnetPrefix: '10.20.0.0/16'

    parSubnet1Name: 'VMSubnet'
    parSubnet1Prefix: '10.20.1.0/24'

    parSubnet2Name: 'KVSubnet'
    parSubnet2Prefix: '10.20.2.0/24'
  }

}
