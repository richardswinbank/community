$scriptFolder = $MyInvocation.MyCommand.Path | Split-Path
Set-Location $scriptFolder
Import-Module $scriptFolder\HookFunctions\HookFunctions.psm1 -Force
 
$f = Resolve-Path -Path "..\DataProjects\MyDbProject\MyDbProject.sqlproj"
ConvertTo-OrderedSqlProject -ProjectFile $f
Invoke-Utility git add $f  # re-stage file after reordering