$resourceGroup = Get-AzResourceGroup
$resourceGroupName = $resourceGroup.ResourceGroupName

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile '.\main.bicep'