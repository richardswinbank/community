param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $AzureDevOpsOrganization,

  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $AzureDevOpsProject,

  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $RepositoryLocalPath,

  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $BranchName
)

# Test if a specified Azure DevOps pipeline exists.
function Test-DevOpsPipeline([string]$Folder, [string]$Name, [object[]]$Existing) {
  $exists = $false
  foreach($p in $Existing) {
    if($p.path -eq $Folder -and $p.name -eq $Name) {
      $exists = $true
    }
  }
  $exists
}

$ErrorActionPreference = 'Stop'

$toolsFolder = $MyInvocation.MyCommand.Path | Split-Path
$reportsFolder = "$toolsFolder/../reports"

# get existing Azure DevOps pipelines in target folder
$pipelines = az pipelines list `
  --organization "$AzureDevOpsOrganization" `
  --project "$AzureDevOpsProject" | ConvertFrom-Json

# check YAML pipeline definitions for corresponding Azure DevOps pipelines
foreach($folderPath in Get-ChildItem -Path $reportsFolder) {
  if(Test-Path -Path "$folderPath/pipeline.yaml") {
    $pipelineFolder = "\06-ReportCreation\Reports"
    $pipelineName = "Deploy $(Split-Path -Leaf $folderPath) report"

    if(Test-DevOpsPipeline -Folder $pipelineFolder -Name $pipelineName -Existing $pipelines) {
      Write-Host "FOUND $pipelineFolder\$pipelineName (already exists)"
      continue
    }
    
    $yamlPath = "$folderPath/pipeline.yaml" -Replace $RepositoryLocalPath,''
        
    az pipelines create `
      --organization "$AzureDevOpsOrganization" --project "$AzureDevOpsProject" `
      --name "$pipelineName" --folder-path "$pipelineFolder" `
      --yaml-path "$yamlPath" --skip-first-run `
      --service-connection "$Env:GITHUB_SERVICE_CONNECTION_ID" --branch "$BranchName" `
      2> stderr.txt | Out-Null

    # check stderr for real errors
    $failed = $false
    foreach($line in Get-Content stderr.txt) {
      if($line.StartsWith("WARNING")) {  # non-error warnings seem to be emitted on stderr
        Write-Host $line
      } else {
        Write-Error $line
        $failed = $true
      }
    }
    if($failed) { throw "FAILED TO CREATE $pipelineFolder\$pipelineName" }

    Write-Host "CREATED $pipelineFolder\$pipelineName"
  }
}
