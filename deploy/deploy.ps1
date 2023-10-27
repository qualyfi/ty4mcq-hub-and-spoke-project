Connect-AzAccount

$resourceGroup = Get-AzResourceGroup
$resourceGroupName = $resourceGroup.ResourceGroupName
$resourceGroupLocation = $resourceGroup.Location

$randUser = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_})
$randPass = -join ("?!.&@#".tochararray() + (48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

$keyVaultName = -join('kv-secret-core-',(Get-Random -Maximum 999999999))
$vmAdminUsername = ConvertTo-SecureString -String $randUser -AsPlainText -Force
$vmAdminPassword = ConvertTo-SecureString -String $randPass -AsPlainText -Force

$sqlAdminUsername = ConvertTo-SecureString -String $randUser -AsPlainText -Force
$sqlAdminPassword = ConvertTo-SecureString -String $randPass -AsPlainText -Force

$kvTags = @{"Dept"="coreServices"; "Owner"="coreServicesOwner"}

New-AzKeyVault -Name $keyVaultName -ResourceGroupName $resourceGroupName -Location $resourceGroupLocation -EnabledForTemplateDeployment -Tag $kvTags
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'vmAdminUsername' -SecretValue $vmAdminUsername
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'vmAdminPassword' -SecretValue $vmAdminPassword
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlAdminUsername' -SecretValue $sqlAdminUsername
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'sqlAdminPassword' -SecretValue $sqlAdminPassword

Write-Output 'VM Admin Username'
Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "vmAdminUsername" -AsPlainText
Write-Output 'VM Admin Password'
Get-AzKeyVaultSecret -VaultName $keyVaultName -Name "vmAdminPassword" -AsPlainText

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile '.\deploy\main.bicep' -parSecKeyVaultName $keyVaultName -parUserObjectId (Get-AzADUser -UserPrincipalName (Get-AzContext).Account).Id
