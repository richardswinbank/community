# Prepares environment to use Power BI cmdlets
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

# Gets the ID of an existing Power BI workspace. (If it doesn't exist, creates it).
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
    Write-Host "Workspace $Name has ID $($workspace.Id)"
    $workspace.Id
}

# Sets up a new Power BI workspace
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

# Publishes a Power BI report
function Publish-PbiReport([string]$Path, [string]$Name, [string]$WorkspaceName) {
    New-PowerBIReport `
        -Path $Path `
        -Name $Name `
        -WorkspaceId (Get-PbiWorkspaceId -Name $WorkspaceName) `
        -ConflictAction CreateOrOverwrite    
}

# Unpublishes a Power BI report
function Unpublish-PbiReport([string]$Name, [string]$WorkspaceName) {
    try {
        $workspaceId = Get-PbiWorkspaceId -Name $WorkspaceName -CreateIfNotExists = $false
    } catch {
        # Workspace doesn't exist? Report doesn't exist!
        return
    }

    $reports = Get-PowerBIReport -Name $Name -WorkspaceId $workspaceId
    foreach($report in $reports) {
        Remove-PowerBIReport -Id $report.Id -WorkspaceId $workspaceId 
    }
}

function Get-PbiDatasetId([string]$Name, [string]$WorkspaceId) {
    $dataset = Get-PowerBIDataset -WorkspaceId "$WorkspaceId" | Where-Object {$_.Name -eq "$DatasetName"}
    Write-Host "Dataset $Name has ID $($dataset.Id)"
    $dataset.Id
}

function Get-PbiReportId([string]$Name, [string]$WorkspaceId) {
    $report = Get-PowerBIReport -WorkspaceId "$WorkspaceId" -Name $ReportName
    Write-Host "Report $Name has ID $($report.Id)"
    $report.Id
}

# Binds a Power BI report to a dataset
function Set-PbiReportDataset([string]$ReportName, [string]$ReportWorkspaceName, [string]$DatasetName, [string]$DatasetWorkspaceName) {
    Write-Host "Binding '$ReportName' in workspace '$ReportWorkspaceName'"
    Write-Host "to dataset '$DatasetName' in workspace '$DatasetWorkspaceName'"

    $workspaceId = Get-PbiWorkspaceId -Name $DatasetWorkspaceName
    $datasetId = Get-PbiDatasetId -Name $DatasetName -WorkspaceId $workspaceId
    $workspaceId = Get-PbiWorkspaceId -Name $ReportWorkspaceName
    $reportId = Get-PbiReportId -Name $ReportName -WorkspaceId $workspaceId

    $body = @{datasetId = $datasetId} | ConvertTo-Json -Compress;
    $url = "https://api.powerbi.com/v1.0/myorg/groups/$workspaceId/reports/$reportId/Rebind"
    Invoke-PowerBIRestMethod -Url $url -Method POST -Body $body | Out-Null
}

# invokes a utility, exposing errors to PowerShell as exceptions
# From https://stackoverflow.com/questions/48864988/powershell-with-git-command-error-handling-automatically-abort-on-non-zero-exi
function Invoke-Utility {
    $exe, $argsForExe = $Args
    $ErrorActionPreference = 'Continue' # to prevent 2> redirections from triggering a terminating error.
    try { & $exe $argsForExe } catch { Throw } # catch is triggered ONLY if $exe can't be found, never for errors reported by $exe itself
    if ($LASTEXITCODE) { Throw "$exe indicated failure (exit code $LASTEXITCODE; full command: $Args)." }
} 

# Creates a new feature branch, adds a specified folder, pushes to origin.
function New-ReportBranch ([string]$FolderPath) {
    $ErrorActionPreference = 'Stop'
    $FolderName = Split-Path $FolderPath -Leaf
    $BranchName = "create-$FolderName"

    Invoke-Utility git checkout main
    Invoke-Utility git pull
    Invoke-Utility git checkout -b $BranchName
    Invoke-Utility git add "$FolderPath"
    Invoke-Utility git commit -m "Initialised report folder $FolderName"
    Invoke-Utility git push --set-upstream origin $BranchName

    Write-Host "`n------------------------------------------------`n"
    Invoke-Utility git status
    Write-Host ""
}
