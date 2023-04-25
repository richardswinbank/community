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
