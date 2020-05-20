Param(
  [Parameter(Mandatory=$true)][string] $resourceGroupName
, [Parameter(Mandatory=$true)][string] $dataFactoryName
, [string] $adfFileRoot = "."
)

$folders = "integrationRuntime","linkedService","dataset","dataflow","pipeline","trigger"

foreach ($f in $folders) {
  $folderPath = "$adfFileRoot\$f"
  if (Test-Path $folderPath -PathType Container) {
    foreach ($ls in Get-ChildItem "$folderPath\*.json" | Sort-Object) {  # KV before LS
      $cmd = "Set-AzDataFactoryV2$($f) -dataFactoryName '$dataFactoryName' -resourceGroupName '$resourceGroupName' -Name '$($ls.BaseName)' -DefinitionFile '$($ls.FullName)' -Force"  
      Invoke-Expression $cmd
    }
  }
}
