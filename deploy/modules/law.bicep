param parLocation string
param parGuidSuffix string

//Log Analytics Workspace
resource resLaw 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'law-core-${parLocation}-001-${parGuidSuffix}'
  location: parLocation
  tags: {
    Dept: 'coreServices'
    Owner: 'coreServicesOwner'
  }
}

output outLawId string = resLaw.id
