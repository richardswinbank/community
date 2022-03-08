
# invokes a utility, exposing errors to PowerShell as exceptions
# From https://stackoverflow.com/questions/48864988/powershell-with-git-command-error-handling-automatically-abort-on-non-zero-exi
Function Invoke-Utility {
    $exe, $argsForExe = $Args
    $ErrorActionPreference = 'Continue' # to prevent 2> redirections from triggering a terminating error.
    try { & $exe $argsForExe } catch { Throw } # catch is triggered ONLY if $exe can't be found, never for errors reported by $exe itself
    if ($LASTEXITCODE) { Throw "$exe indicated failure (exit code $LASTEXITCODE; full command: $Args)." }
} 

# Formats JSON in a nicer format than the built-in ConvertTo-Json does. From:
#  - https://github.com/PowerShell/PowerShell/issues/2736
#  - https://stackoverflow.com/questions/56322993/proper-formating-of-json-using-powershell/56324939
Function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'
    $indent = 0;

    ($json -Split '\n' |
      % {
        if ($_ -match "[}\]]$regexUnlessQuoted") {
          # This line contains  ] or }, decrement the indentation level
          $indent = [Math]::Max($indent - 1, 0)
        }
        $line = (' ' * $indent * 2) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')
        if ($_ -match "[\{\[]$regexUnlessQuoted") {
          # This line contains [ or {, increment the indentation level
          $indent++
        }
        $line
    }) -Join "`n"
}

# Sort a specified .bim file into a consistent order
Function ConvertTo-OrderedModel($ModelFile) {
    $ErrorActionPreference = "Stop"
    Write-Host "Running ConvertTo-OrderedModel() on $ModelFile"
    $model = Get-Content $ModelFile -Encoding UTF8 | ConvertFrom-Json
    
    # order data sources, reset credential expiries
    if([bool]($model.model.PSobject.Properties.name -match "dataSources")) {
        if($model.model.dataSources.count -gt 1) {
            $model.model.dataSources = $model.model.dataSources | Sort-Object -Property "name"
        }
    
        for ($i=0; $i -lt $model.model.dataSources.length; $i++) {
            $ds = $model.model.dataSources[$i]
    
            if([bool]($ds.PSobject.Properties.name -match "credential")) {
                $cred = $ds.credential
                if([bool]($cred.PSobject.Properties.name -match "Expires")) {
                    $model.model.dataSources[$i].credential.Expires = "Fri, 10 Sep 2021 12:00:00 GMT"
                }
            }
        }
    }
    
    # order tables & their components
    if([bool]($model.model.PSobject.Properties.name -match "tables")) {
        if($model.model.tables.count -gt 1) {
            $model.model.tables = $model.model.tables | Sort-Object -Property "name"
        }
    
        for ($i=0; $i -lt $model.model.tables.length; $i++) {
            $table = $model.model.tables[$i]
    
            if([bool]($table.PSobject.Properties.name -match "columns")) {
                if($table.columns.count -gt 1) {
                    $table.columns = $table.columns | Sort-Object -Property "name"
                }
            }
            if([bool]($table.PSobject.Properties.name -match "partitions")) {
                if($table.partitions.count -gt 1) {
                    $table.partitions = $table.partitions | Sort-Object -Property "name"
                }
            }
            if([bool]($table.PSobject.Properties.name -match "measures")) {
                if($table.measures.count -gt 1) {
                    $table.measures = $table.measures | Sort-Object -Property "name"
                }
            }
            if([bool]($table.PSobject.Properties.name -match "hierarchies")) {
                if($table.hierarchies.count -gt 1) {
                    $table.hierarchies = $table.hierarchies | Sort-Object -Property "name"
                }
            }
    
            $model.model.tables[$i] = $table
        }
    }
    
    # order relationships
    if([bool]($model.model.PSobject.Properties.name -match "relationships")) {
        if($model.model.relationships.count -gt 1) {
            $model.model.relationships = $model.model.relationships | Sort-Object -Property "name"
        }
    }
    
    # order roles
    if([bool]($model.model.PSobject.Properties.name -match "roles")) {
        if($model.model.relationships.count -gt 1) {
            $model.model.relationships = $model.model.relationships | Sort-Object -Property "name"
        }
    }
    
    # order expressions
    if([bool]($model.model.PSobject.Properties.name -match "expressions")) {
        if($model.model.expressions.count -gt 1) {
            $model.model.expressions = $model.model.expressions | Sort-Object -Property "name"
        }
    }
    
    # order annotations
    if([bool]($model.model.PSobject.Properties.name -match "annotations")) {
        if($model.model.annotations.count -gt 1) {
            $model.model.annotations = $model.model.annotations | Sort-Object -Property "name"
        }
    }
    
    # write re-ordered model back out to source file
    $output = $model | ConvertTo-Json -Depth 100 | Format-Json 
    $output | Out-File -FilePath $ModelFile -Encoding UTF8
}

Function ConvertTo-OrderedSqlProject($ProjectFile) {
    $ErrorActionPreference = "Stop" 
    Write-Host "Running ConvertTo-OrderedSqlProject() on $ProjectFile"
    $doc = new-object System.Xml.XmlDocument
    $xml = Get-Content $ProjectFile -Encoding UTF8
    $doc.LoadXml($xml)

    foreach($node in $doc.DocumentElement.ChildNodes) {
      if($node.Name -eq "ItemGroup") {
        ConvertTo-OrderedElement -Element $node -AttributeName "Include"
      }
    }

    $doc.Save($ProjectFile)
}

Function ConvertTo-OrderedElement([System.Xml.XmlElement]$Element, [string]$AttributeName) {
    $ErrorActionPreference = "Stop" 
    $items = $Element.ChildNodes
    $changed = $true
    
    # bubble sort the element's children by the specified attribute
    while($changed) {
        $changed = $false
        for($i = $items.Count - 1; $i -gt 0; $i--) {
            if($items[$i].Attributes[$AttributeName].Value -lt $items[$i-1].Attributes[$AttributeName].Value) {
                $item = $Element.RemoveChild($items[$i])
                $Element.InsertBefore($item, $items[$i-1]) | Out-Null
                $changed = $true
            }
        }
    }
}
