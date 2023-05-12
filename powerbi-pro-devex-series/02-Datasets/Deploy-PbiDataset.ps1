param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $DatasetName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $WorkspaceName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $BimFilePath,

    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [bool] $RefreshDataset
)

$ErrorActionPreference = 'Stop'

$scriptFolder = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $scriptFolder\PbiDeployment\PbiDeployment.psm1 -Force

# Connect to Power BI
$credential = Use-Pbi -WithModules @('Workspaces', 'Data')

# prepare model
$model = Get-Content $BimFilePath -Encoding UTF8
$cmd = '{"createOrReplace":{"object":{"database":""}, "database":' + $model + '}}' | ConvertFrom-Json
$cmd.createOrReplace.object.database = $DatasetName
$cmd.createOrReplace.database.name = $DatasetName
$query = ConvertTo-Json $cmd -Depth 100 -Compress

# deploy model
$endpoint = "powerbi://api.powerbi.com/v1.0/myorg/$WorkspaceName"
$result = Invoke-ASCmd -Server $endpoint -Query $query -Credential $credential -ServicePrincipal -TenantId $Env:AZURE_TENANT_ID
Write-Output $result
if($result -like "*error*") {
    throw "Error deploying dataset."
}

# refresh dataset
if ($RefreshDataset) {
    $workspaceId = (Get-PowerBIWorkspace -Name $WorkspaceName).Id
    $datasetId = (Get-PowerBIDataset -WorkspaceId "$workspaceId" | Where-Object {$_.Name -eq "$DatasetName"}).Id
    $url = "/groups/$workspaceId/datasets/$datasetId/refreshes"
    $body = @{notifyOption = "NoNotification"} | ConvertTo-Json -Compress
    Invoke-PowerBIRestMethod -Url $url -Method POST -Body $body | Out-Null
}