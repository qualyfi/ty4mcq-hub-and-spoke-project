$resourceGroup = Get-AzResourceGroup
$resourceGroupName = $resourceGroup.ResourceGroupName

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile '.\deploy\main.bicep'