$scriptFolder = $MyInvocation.MyCommand.Path | Split-Path
Set-Location $scriptFolder
Import-Module $scriptFolder\HookFunctions\HookFunctions.psm1 -Force
 
$f = Resolve-Path -Path "..\SsasProjects\MyTabularModel\Model.bim"
ConvertTo-OrderedModel -ModelFile $f
Invoke-Utility git add $f  # re-stage file after reordering