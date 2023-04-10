param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ReportName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $WorkspaceName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PbixFilePath
)

$ErrorActionPreference = 'Stop'

# install PowerShell modules for Power BI
Install-Module -Name "MicrosoftPowerBIMgmt.Workspaces" -AllowClobber -Force -Scope CurrentUser
Install-Module -Name "MicrosoftPowerBIMgmt.Reports" -AllowClobber -Force -Scope CurrentUser

# log into Power BI
$secureClientSecret = ConvertTo-SecureString $Env:AZURE_CLIENT_SECRET -AsPlainText -Force
$credentials = New-Object PSCredential($Env:AZURE_CLIENT_ID, $secureClientSecret)
Connect-PowerBIServiceAccount -Tenant $Env:AZURE_TENANT_ID -ServicePrincipal -Credential $credentials | Out-Null

# publish the report
New-PowerBIReport `
  -Path $PbixFilePath `
  -Name $ReportName `
  -Workspace (Get-PowerBIWorkspace -Name $WorkspaceName) `
  -ConflictAction CreateOrOverwrite
