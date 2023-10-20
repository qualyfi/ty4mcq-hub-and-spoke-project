param parLocation string
param parVnetName string
param parVnetAddressPrefix string

param parGatewaySubnetAddressPrefix string
param parAppgwSubnetAddressPrefix string
param parAzureFirewallSubnetAddressPrefix string
param parAzureBastionSubnetAddressPrefix string

//Hub VNet
resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: parVnetName
  location: parLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        parVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: parGatewaySubnetAddressPrefix
        }
      }
      {
        name: 'AppgwSubnet'
        properties: {
          addressPrefix: parAppgwSubnetAddressPrefix
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: parAzureFirewallSubnetAddressPrefix
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: parAzureBastionSubnetAddressPrefix
        }
      }
    ]
  }
}
output outVnetName string = resVnet.name

//Bastion + Bastion Public IP
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

//Firewall + Firewall Policy + any/any Rule, + Firewall Public IP
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
resource resAfwPolicyRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' = {
  parent: resAfwPolicy
  name: 'DefaultNetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'NetworkRuleCollection'
        priority: 1000
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'any/any'
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: [
              '*'
            ]
            destinationPorts: [
              '*'
            ]
          }
        ]
      }
    ]
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
output outAfwName string = resAfw.name
