param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $FolderName,
  
  [Parameter(Mandatory = $False)]
  [bool] $WithGitActions = $True
)

$ErrorActionPreference = 'Stop'

$toolsFolder = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $toolsFolder\PbiDeployment\PbiDeployment.psm1 -Force
Set-Location $toolsFolder

$reportFolder = "$toolsFolder\..\reports\$FolderName"
if(Test-Path -Path "$reportFolder") {
  throw "$reportFolder already exists. Delete the existing folder or create a new one."
}

# create new report folder
Copy-Item `
  -Path "$toolsFolder\ReportTemplate" `
  -Destination "$reportFolder" `
  -Recurse

Write-Host "Created report folder $reportFolder"

# configure pipeline YAML files
foreach($file in @('pipeline.yaml', 'metadata.yaml')) {
  $content = Get-Content -Path "$reportFolder\$file"
  $content = $content -Replace "_ReportTemplate_", "$FolderName"
  Set-Content -Path "$reportFolder\$file" -Value $content  
}

# create & push feature branch
if($WithGitActions -eq $true) {
  New-ReportBranch -FolderPath $reportFolder
}
