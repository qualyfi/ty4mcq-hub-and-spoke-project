$resourceGroup = Get-AzResourceGroup
$resourceGroupName = $resourceGroup.ResourceGroupName
$resourceGroupLocation = $resourceGroup.Location

$randUser = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$randPass = -join ("?!.&@#".tochararray() + (48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

$keyVaultName = -join('kv-secret-core-',(Get-Random -Maximum 999999999))
$vmAdminUsername = ConvertTo-SecureString -String $randUser -AsPlainText -Force
$vmAdminPassword = ConvertTo-SecureString -String $randPass -AsPlainText -Force

New-AzKeyVault -Name $keyVaultName -ResourceGroupName $resourceGroupName -Location $resourceGroupLocation -EnabledForTemplateDeployment
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'vmAdminUsername' -SecretValue $vmAdminUsername
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'vmAdminPassword' -SecretValue $vmAdminPassword

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile '.\deploy\main.bicep' -parKeyVaultName $keyVaultName
