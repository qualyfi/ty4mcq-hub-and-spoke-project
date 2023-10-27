param parLocation string
param parSpokeName string
param parAgwName string
param parAgwSubnetId string
param parProdWaFqdn string

resource resAgwPublicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-${parSpokeName}-${parLocation}-agw-001'
  location: parLocation
  tags: {
    Dept: parSpokeName
    Owner: '${parSpokeName}Owner'
  }
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
  tags: {
    Dept: parSpokeName
    Owner: '${parSpokeName}Owner'
  }
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
            id: parAgwSubnetId
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
