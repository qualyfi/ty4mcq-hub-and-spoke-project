$resourceGroup = Get-AzResourceGroup
$resourceGroupName = $resourceGroup.ResourceGroupName
$resourceGroupLocation = $resourceGroup.Location

$keyVaultName = -join('kv-secret-core-',(Get-Random -Maximum 999999999))
$vmAdminUsername = ConvertTo-SecureString 'ty4mcq' -AsPlainText -Force
$vmAdminPassword = ConvertTo-SecureString 'QualyfiProject123!' -AsPlainText -Force

New-AzKeyVault -Name $keyVaultName -ResourceGroupName $resourceGroupName -Location $resourceGroupLocation -EnabledForTemplateDeployment
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'vmAdminUsername' -SecretValue $vmAdminUsername
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'vmAdminPassword' -SecretValue $vmAdminPassword

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile '.\deploy\main.bicep' -parKeyVaultName $keyVaultName

