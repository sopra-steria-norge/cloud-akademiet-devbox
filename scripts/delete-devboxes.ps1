[CmdletBinding(SupportsShouldProcess)]
param (
  [Parameter()]
  [string]
  $ResourceGroupName = "cloudakademiet24-rg"
)

$ErrorActionPreference = "Stop"

# Find project
$project = Get-AzDevCenterAdminProject -ResourceGroupName $ResourceGroupName
Write-Host "> Working in DevCenter Project: $($project.Name)"

# Find all devboxes
$devboxes = Get-AzDevCenterUserDevBox -Endpoint $project.DevCenterUri
Write-Host "- Found $($devboxes.Count) devboxes in total"

if (!$devboxes) {
  Write-Host "- No devboxes found. Exiting..."
  exit 0
}

Write-Host "- Deleting all devboxes ($($devboxes.Count)):"
$devboxes | ForEach-Object -Parallel {
  $WhatIfPreference = $using:WhatIfPreference
  Write-Host "  - Deleting [$($_.Name)]..."
  $null = Remove-AzDevCenterUserDevBox -Endpoint $using:project.DevCenterUri -ProjectName $using:project.Name -UserId $_.User -Name $_.Name -WhatIf:$WhatIfPreference
}