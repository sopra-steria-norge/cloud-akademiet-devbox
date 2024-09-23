#requires -Modules Az.ManagedServiceIdentity, Az.Resources

# This script is meant to run locally to create a user assigned managed identity and 
# a role assignment and federated credential to be used with GitHub Actions to manage devboxes.
# See more information at https://github.com/Azure/login#login-with-user-assigned-managed-identity

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $ResourceGroupName = 'cloudakademiet24-rg',

    [Parameter()]
    [string]
    $Location = 'westueurope',

    [Parameter()]
    [string]
    $IdentityName = 'github-repo-id',

    [Parameter()]
    [string]
    $GhUserName = 'sopra-steria-norge',

    [Parameter()]
    [string]
    $GhRepoName = 'cloud-akademiet-devbox',

    [Parameter()]
    [string]
    $GhEnvName = 'Azure'
)

$ErrorActionPreference = "Stop"

#* Create resource group
Write-Host "Checking resource group..."
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (!$rg) {
    $rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

#* Create user assigned managed identity
Write-Host "Creating user-assigned managed identity..."
$identity = New-AzUserAssignedIdentity -ResourceGroupName $rg.ResourceGroupName -Name $IdentityName -Location $rg.Location

#* Create role assignment for the managed identity
Write-Host "Creating role assignment..."
$null = New-AzRoleAssignment -PrincipalId $identity.PrincipalId -RoleDefinitionName "DevCenter Project Admin" -Scope $rg.ResourceId -ObjectType "ServicePrincipal"

#* Create credentials for user assigned managed identity
Write-Host "Creating federated credential for managed identity..."
$null = New-AzFederatedIdentityCredentials -ResourceGroupName $rg.ResourceGroupName -IdentityName $identity.Name `
    -Name $GhRepoName  -Issuer "https://token.actions.githubusercontent.com" -Subject "repo:${GhUserName}/${GhRepoName}:environment:${GhEnvName}"

#* Output subscription id, client id and tenant id
$out = [ordered]@{
    SUBSCRIPTION_ID = $(Get-AzContext).Subscription.Id
    CLIENT_ID       = $identity.ClientId
    TENANT_ID       = $identity.TenantId
}
Write-Host ($out | ConvertTo-Json | Out-String)

# If you have GitHub CLI installed, you can run the following commands:
# gh secret set SUBSCRIPTION_ID --body "<sub id>" --env Azure
# gh secret set CLIENT_ID --body "<client id>" --env Azure
# gh secret set TENANT_ID --body "<tenant id>" --env Azure