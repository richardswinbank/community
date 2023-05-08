function Use-Pbi([string[]]$WithModules = @('Profile')) {
    $ErrorActionPreference = 'Stop'
    
    # install PowerShell modules for Power BI
    foreach($module in $WithModules) {
        Install-Module -Name "MicrosoftPowerBIMgmt.$module" -AllowClobber -Force -Scope CurrentUser
    }

    # log into Power BI
    $secureClientSecret = ConvertTo-SecureString $Env:AZURE_CLIENT_SECRET -AsPlainText -Force
    $credentials = New-Object PSCredential($Env:AZURE_CLIENT_ID, $secureClientSecret)
    Connect-PowerBIServiceAccount -Tenant $Env:AZURE_TENANT_ID -ServicePrincipal -Credential $credentials | Out-Null
    Write-Host "Connected to Power BI"

    $credentials
}

function Get-PbiWorkspaceId([string]$Name) {
    $ErrorActionPreference = 'Stop'

    $workspaces = Get-PowerBIWorkspace -Name $Name
    if($workspaces.Count -eq 0) {
        $workspace = New-PbiWorkspace -Name $Name
    } elseif ($workspaces.Count -eq 1) {
        $workspace = $workspaces[0]
    } else {
        throw "Found $($workspaces.Count) workspaces named $Name!"
    }
    Write-Host "Workspace ID = $($workspace.Id)"
    $workspace.Id
}

function New-PbiWorkspace([string]$Name) {
    $ErrorActionPreference = 'Stop'

    Write-Host "Creating workspace $Name"
    $workspace = New-PowerBIWorkspace -Name $Name

    Add-PowerBIWorkspaceUser `
        -Workspace $workspace `
        -AccessRight "Admin" `
        -Identifier  "$Env:PBI_WORKSPACE_ADMINS" `
        -PrincipalType "Group"
   
    $workspace
}
