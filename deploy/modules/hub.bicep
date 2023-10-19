param parLocation string

resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-hub-${parLocation}-001'
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
      {
        name: 'AppgwSubnet'
        properties: {
          addressPrefix: '10.10.2.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.10.3.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.10.4.0/24'
        }
      }
    ]
  }
}
output outVnetName string = resVnet.name

resource resBasPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-hub-${parLocation}-bas-001'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource resBas 'Microsoft.Network/bastionHosts@2023-05-01' = {
  name: 'bas-hub-${parLocation}-001'
  location: parLocation
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          privateIPAllocationMethod:'Dynamic'
          publicIPAddress: {
            id: resBasPublicIP.id
          }
          subnet: {
            id: resVnet.properties.subnets[3].id
          }
        }
      }
    ]
  }
}

resource resAfwPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-hub-${parLocation}-afw-001'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
resource resAfwPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' = {
  name: 'AfwPolicy'
  location: parLocation
  properties: {
    sku: {
      tier: 'Standard'
    }
    dnsSettings: {
      enableProxy: true
    }
    threatIntelMode: 'Alert'
  }
}

resource resAfw 'Microsoft.Network/azureFirewalls@2023-05-01' = {
  name: 'afw-hub-${parLocation}-001'
  location: parLocation
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }    
    firewallPolicy: {
      id: resAfwPolicy.id
    }
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: resVnet.properties.subnets[2].id
          }
          publicIPAddress: {
            id: resAfwPublicIP.id
          }
        }
      }
    ]
  }
}

