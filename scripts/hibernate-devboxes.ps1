[CmdletBinding(SupportsShouldProcess)]
param (
  [Parameter()]
  [string]
  $ResourceGroupName = "cloudakademiet-rg"
)

$ErrorActionPreference = "Stop"

# Find project
$project = Get-AzDevCenterAdminProject -ResourceGroupName $ResourceGroupName
Write-Host "> Working in DevCenter Project: $($project.Name)"

# Find all devboxes
$devboxes = Get-AzDevCenterUserDevBox -Endpoint $project.DevCenterUri
Write-Host "- Found $($devboxes.Count) devboxes in total"

# Hibernate all running devboxes
$runningDevboxes = $devboxes | Where-Object { $_.PowerState -eq "Running" -and $_.ProvisioningState -eq "Succeeded" }
if(!$runningDevboxes){
  Write-Host "- No running devboxes found. Exiting..."
  exit 0
}

Write-Host "- Hibernating all running devboxes ($($runningDevboxes.Count)):"
$runningDevboxes | ForEach-Object -Parallel {
  $WhatIfPreference = $using:WhatIfPreference
  Write-Host "  - Hibernating [$($_.Name)]..."
  $null = Stop-AzDevCenterUserDevBox -Endpoint $using:project.DevCenterUri -ProjectName $using:project.Name -UserId $_.User -Name $_.Name -Hibernate -WhatIf:$WhatIfPreference
}
