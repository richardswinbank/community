$folder = "powerbi-pro-devex-series\02-Datasets"
Import-Module ".\$folder\GitHookFunctions\GitHookFunctions.psm1" -Force
Write-Host "This is $($MyInvocation.MyCommand.Path)"

$f = Resolve-Path -Path ".\$folder\Model.bim"
ConvertTo-OrderedModel -ModelFile $f
Invoke-Utility git add $f  # re-stage file after reordering
