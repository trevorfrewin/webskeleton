param (
    [Parameter(Mandatory = $true)]
    [string]$instanceNamePrefix,  # Required parameter for instance name prefix
    
    [Parameter(Mandatory = $true)]
    [string]$subscriptionId, # Required parameter for subscription ID

    [Parameter(Mandatory = $true)]
    [string]$userPrincipalName # Required parameter for subscription ID
)

. ./Generate-Password.ps1
. ./Inject-DatabaseStructure.ps1

# Variables
$timestamp = (Get-Date).ToString("yyyyMMddHHmmss")
$resourceGroupName = "$instanceNamePrefix$timestamp"
$keyVaultName = "$instanceNamePrefix$timestamp-kv"
$keyVaultName = $keyVaultName.Substring($keyVaultName.Length - 24)
$location = "UK South" # Change this to your preferred UK location (e.g., "UK South" or "UK West")
$webAppName = "$instanceNamePrefix-webapp-$timestamp" # Web App name includes prefix and timestamp
$sqlServerName = "dbms-$instanceNamePrefixsqlsrv$timestamp" # Lowercase and hyphen-free SQL Server name
$sqlDatabaseName = "db-$instanceNamePrefix$timestamp" # Change this to your database name
$sqlAdminUser = "dbadmin-$instanceNamePrefix$timestamp"
$sqlAdminPassword = Generate-Password -length 16

# Tags
$tags = @{ Timestamp = $timestamp }

# Function to run Az commands and handle errors
function Run-Command {
    param (
        [ScriptBlock]$command,
        [string]$description
    )

    Write-Host "START '$description': $(Get-Date -format 'u')"

    $global:ErrorActionPreference = 'Stop'  # Ensure that errors are thrown
    $errorVariable = $null  # Initialize error variable

    # Run the command
    Try {
        $result = &$command -ErrorAction Stop
        Write-Host "$description succeeded."
        if ($result) {
            Write-Host "Result: $($result | Out-String)"
        }
        return $result  # Return the result of the command
    } Catch {
        Write-Host "$description failed."
        Write-Host "Error: $($_.Exception.Message)"
        exit
    }
}

# Login to Azure account and set subscription
$defaultProfile = Connect-AzAccount -SubscriptionId $subscriptionId

# Get public IP address from ipinfo.io for this machine right now
$publicIP = Invoke-RestMethod -Uri "https://ipinfo.io/ip"

$resourceGroup = Run-Command -command {
    $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tags
} -description "Creating resource group: $resourceGroupName"

$keyVault = Run-Command -command {
   New-AzKeyVault -ResourceGroupName $resourceGroupName -VaultName $keyVaultName -Location $location -Sku Standard -EnabledForDeployment -Tag $tags

   #PrincipalId cannot be null
   New-AzRoleAssignment -ResourceGroupName $resourceGroupName -SignInName $userPrincipalName -RoleDefinitionName "Key Vault Secrets Officer" -AllowDelegation

   #Await propogation time
   Write-Host "Sleeping for 5 minutes for propogation of RBAC on KV"
   Start-Sleep -Seconds 300
} -description "Creating Key Vault named: $keyVaultName"

$keyVaultEntry = Run-Command -command {
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "sqlAdminUser" -SecretValue (ConvertTo-SecureString $sqlAdminUser -AsPlainText -Force) -DefaultProfile $defaultProfile
} -description "Writing DB Admin Username to KeyVault named: $keyVaultName"

$keyVaultEntry = Run-Command -command {
    Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "sqlAdminPassword" -SecretValue (ConvertTo-SecureString $sqlAdminPassword -AsPlainText -Force) -DefaultProfile $defaultProfile
} -description "Writing DB Password to KeyVault named: $keyVaultName"

Run-Command -command {
    New-AzAppServicePlan -Name "$webAppName-Plan" -Location $location -ResourceGroupName $resourceGroupName -Tier Free -Tag $tags
} -description "Creating Service plan for Web App: $webAppName"

Run-Command -command {
    New-AzWebApp -Name $webAppName -ResourceGroupName $resourceGroupName -Location $location -AppServicePlan "$webAppName-Plan" -Tag $tags
} -description "Creating Web App: $webAppName"

Run-Command -command {
    New-AzSqlServer -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -Location $location -SqlAdministratorCredentials (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sqlAdminUser, (ConvertTo-SecureString $sqlAdminPassword -AsPlainText -Force)) -Tag $tags
} -description "Creating SQL Server: $sqlServerName"

Run-Command -command {
    New-AzSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -DatabaseName $sqlDatabaseName -RequestedServiceObjectiveName "Basic" -Tag $tags
} -description "Creating SQL Database: $sqlDatabaseName"

Run-Command -command {
    New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $sqlServerName -FirewallRuleName DeploymentServerDatabaseAccess -StartIpAddress $publicIP -EndIpAddress $publicIP
} -description "Creating Firewall rule for SQL Database access: $sqlDatabaseName"

Run-Command -command {
    $dataDefinitionResults = Inject-DataDefinitions -ServerName $sqlServerName -DatabaseName $sqlDatabaseName -AdminUser $sqlAdminUser -AdminPassword $sqlAdminPassword

    Write-Host $dataDefinitionResults
} -description "Inject SQL DDL"

Write-Host "Resource provisioning complete."

# Return the created resource group
$resourceGroup
