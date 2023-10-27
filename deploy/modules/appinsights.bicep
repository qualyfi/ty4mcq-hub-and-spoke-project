param parLocation string
param parLawId string

resource resProdAppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'prodAppInsights'
  location: parLocation
  tags: {
    Dept: 'coreServices'
    Owner: 'coreServicesOwner'
  }
  kind: 'web'
  properties: {
    WorkspaceResourceId: parLawId
    Application_Type: 'web'
  }
}
