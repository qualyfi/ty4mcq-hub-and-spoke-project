param parLocation string
param parSpokeName string
param parVnetAddressPrefix string

param parGatewaySubnetAddressPrefix string
param parAppgwSubnetAddressPrefix string
param parAzureFirewallSubnetAddressPrefix string
param parAzureBastionSubnetAddressPrefix string

param parWaPDnsZoneName string

param parAgwName string
param parProdWaFqdn string

//Hub VNet
resource resVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-${parSpokeName}-${parLocation}-001'
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
resource resWaPDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${parWaPDnsZoneName}/${parWaPDnsZoneName}-${parSpokeName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resVnet.id
    }
  }
}

//Bastion + Bastion Public IP
resource resBasPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-${parSpokeName}-${parLocation}-bas-001'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
// resource resBas 'Microsoft.Network/bastionHosts@2023-05-01' = {
//   name: 'bas-${parSpokeName}-${parLocation}-001'
//   location: parLocation
//   sku: {
//     name: 'Basic'
//   }
//   properties: {
//     ipConfigurations: [
//       {
//         name: 'ipConfig'
//         properties: {
//           privateIPAllocationMethod:'Dynamic'
//           publicIPAddress: {
//             id: resBasPublicIP.id
//           }
//           subnet: {
//             id: resVnet.properties.subnets[3].id
//           }
//         }
//       }
//     ]
//   }
// }

//Firewall + Firewall Policy + any/any Rule, + Firewall Public IP
resource resAfwPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-${parSpokeName}-${parLocation}-afw-001'
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
// resource resAfw 'Microsoft.Network/azureFirewalls@2023-05-01' = {
//   name: 'afw-${parSpokeName}-${parLocation}-001'
//   location: parLocation
//   properties: {
//     sku: {
//       name: 'AZFW_VNet'
//       tier: 'Standard'
//     }    
//     firewallPolicy: {
//       id: resAfwPolicy.id
//     }
//     ipConfigurations: [
//       {
//         name: 'ipConfig'
//         properties: {
//           subnet: {
//             id: resVnet.properties.subnets[2].id
//           }
//           publicIPAddress: {
//             id: resAfwPublicIP.id
//           }
//         }
//       }
//     ]
//   }
// }

resource resAgwPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-${parSpokeName}-${parLocation}-agw-001'
  location: parLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource resAgw 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: parAgwName
  location: parLocation
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: resVnet.properties.subnets[1].id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendPIP'
        properties: {
          publicIPAddress: {
            id: resAgwPublicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bepool-webapp'
        properties: {
          backendAddresses: [
            {
              fqdn: parProdWaFqdn
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'bepool-settings'
        properties: {
          port: 80
          protocol: 'Http'
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    httpListeners: [
      {
        name: 'http-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', parAgwName, 'frontendPIP')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', parAgwName, 'port_80')
          }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'http-only'
        properties: {
          ruleType: 'Basic'
          priority: 1000
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', parAgwName, 'http-listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parAgwName, 'bepool-webapp')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parAgwName, 'bepool-settings')
          }
        }
      }
    ]
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
  }
}


output outVnetName string = resVnet.name
output outVnetId string = resVnet.id
// output outAfwIpAddress string = resAfw.properties.ipConfigurations[0].properties.privateIPAddress
