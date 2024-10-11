# Create a function to generate a random password
function Inject-DataDefinitions {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        [Parameter(Mandatory = $true)]
        [string]$DatabaseName,
        [Parameter(Mandatory = $true)]
        [string]$AdminUser,
        [Parameter(Mandatory = $true)]
        [string]$AdminPassword
    )

    # Ensure the SqlServer module is installed for Invoke-Sqlcmd
    if (-not (Get-Module -ListAvailable -Name SqlServer)) {
        Install-Module -Name SqlServer -Force -AllowClobber
    }
    
    # Define the connection string for Invoke-Sqlcmd
    $connectionString = "Server=tcp:$ServerName.database.windows.net,1433;Database=$DatabaseName;User ID=$AdminUser;Password=$AdminPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

    $ddlFolderPath = ".\DataDefinitions"
    $ddlFiles = Get-ChildItem -Path $ddlFolderPath -Filter *.ddl | Sort-Object Name
    if ($ddlFiles.Count -eq 0) {
        Write-Host "No .ddl files found in the 'DataDefinitions' folder."
        exit 1
    }

    $dataDefinitionResults = @()
    foreach ($ddlFile in $ddlFiles) {
        try {
            # Read the content of the DDL file
            $ddlQuery = Get-Content -Path $ddlFile.FullName -Raw

            # Execute the DDL file using Invoke-Sqlcmd
            Write-Host "Executing DDL file: $($ddlFile.Name)"
            $dataDefinitionResult = Invoke-Sqlcmd -ConnectionString $connectionString -Query $ddlQuery

            if ($dataDefinitionResult) {
                $dataDefinitionResults += $dataDefinitionResult
            } else {
                $dataDefinitionResults += "Executed $($ddlFile.Name): No results returned."
            }

            Write-Host "Successfully executed: $($ddlFile.Name)"
        } catch {
            Write-Host "Error executing DDL file: $($ddlFile.Name)"
            Write-Host $_.Exception.Message
        }
    }
    return $dataDefinitionResults;
}










