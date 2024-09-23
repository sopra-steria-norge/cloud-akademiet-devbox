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

# Hibernate all running devboxes
$runningDevboxes = $devboxes | Where-Object PowerState -ne "Hibernated"
Write-Host "- Hibernating all running devboxes ($($runningDevboxes.Count)):"
$devboxes | Where-Object PowerState -ne "Hibernated" | ForEach-Object -Parallel {
  Write-Host "  - Hibernating [$($_.Name)]... with whatifpreference $using:WhatIfPreference"
  #$null = Stop-AzDevCenterUserDevBox -Endpoint $using:project.DevCenterUri -ProjectName $using:project.Name -Name $_.Name -Hibernate
}