param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ReportName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $WorkspaceName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PbixFilePath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [bool] $IsDeleted
)

$ErrorActionPreference = 'Stop'

$scriptFolder = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $scriptFolder\PbiDeployment\PbiDeployment.psm1 -Force

# Connect to Power BI
Use-Pbi -WithModules @('Workspaces', 'Reports') | Out-Null

# publish the report
Write-Host "Deploying '$ReportName' to workspace '$WorkspaceName'"
Write-Host $PbixFilePath
Write-Host "IsDeleted = $IsDeleted"

if($IsDeleted) {
  Unpublish-PbiReport `
    -Name $ReportName `
    -WorkspaceName $WorkspaceName
} else {
  Publish-PbiReport `
    -Path $PbixFilePath `
    -Name $ReportName `
    -WorkspaceName $WorkspaceName
}
