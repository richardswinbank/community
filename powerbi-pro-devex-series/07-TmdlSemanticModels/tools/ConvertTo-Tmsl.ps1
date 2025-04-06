param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $TmdlFolderPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $BimFilePath
)

$ErrorActionPreference = 'Stop'

$scriptFolder = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $scriptFolder\PbiDeployment\PbiDeployment.psm1 -Force

Write-Host "Converting TMDL model in $TmdlFolderPath to $BimFilePath"

$pkgName = "Microsoft.AnalysisServices"
Write-Host "Installing $pkgName"
Install-Package -Name $pkgName -ProviderName NuGet -Force | Out-Null

$pkg = Get-Package $pkgName
$nugetFile = Get-ChildItem $pkg.Source
$dllPath = Join-Path $nugetFile.DirectoryName "lib\net8.0\Microsoft.AnalysisServices.Tabular.dll"
Write-Host "Loading types from $dllPath"
try {
    Add-Type -Path $dllPath
} 
catch [System.Reflection.ReflectionTypeLoadException] {
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Green
    Write-Host "StackTrace: $($_.Exception.StackTrace)" -ForegroundColor Yellow
    Write-Host "LoaderExceptions: $($_.Exception.LoaderExceptions)" -ForegroundColor Cyan
}

Write-Host "Reading TMDL"
Get-ChildItem -Path $TmdlFolderPath
$model = [Microsoft.AnalysisServices.Tabular.TmdlSerializer]::DeserializeDatabaseFromFolder($TmdlFolderPath)

Write-Host "Writing TMSL"
$options = New-Object Microsoft.AnalysisServices.Tabular.SerializeOptions
$options.SplitMultilineStrings = $true
$tmslText = [Microsoft.AnalysisServices.Tabular.JsonSerializer]::SerializeDatabase($model,$options)
$tmslText | Out-File $BimFilePath
$tmslText
