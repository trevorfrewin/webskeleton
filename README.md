# Web Skeleton

A quick Azure web set up for ephemeral build &amp; tear down.

Deploys a web app and databases to demonstrate the construction of a test instance.

Illustrates the use of Powershell 'Az' commands.

Illustrates the minimum set up for an end-to-end web app deployment.

Future iterations should

* strengthen the protection around the case and length of the instanceNamePrefix
* cover details like load balancing (etc)
* provide a way to inject the web site code
* provide injection of a Cosmos DB instance
* provide a function for playing the events forward into the records in the relational database

## Usage

Using the script is simple. It has 3 required parameters as described here:

```Bash
./Create-Starter.ps1 instanceNamePrefix subscriptionId userPrincipalName
```

The parameters are:

|Parameter Name|Description|Example|
|-|-|-|
|*instanceNamePrefix*|Any meaningful string for the name of this environment. **Must** be lower case.|"mynewwebsite"|
|*subscriptionId*|The Id for the Azure Subscription into which the environment must be injected. Must be the Id for a Subscription that the User Principal (as identified int he next paramter) is suitably authorised upon.|"a75d75f1-2c40-46c1-97d9-429729735baf"|
|*userPrincipalName*|The User Principal Name for the user that is selected (on the web login page) whenthe script starts. Must be appropriately authorised ont he Subscription identified by the Subscription Id (also supplied).|"tjfrewin_gmail.com#EXT#@tjfrewingmail.onmicrosoft.com"|

## Expected Results

A Web App, Key Vault, Database (RDBMS and database instance) - and more - are created within Azure. But everything created in this process is created within a Resource Group, and tagged.

To review billing for things, and/or to clean up the environment when you are done, it is suggested that you access everything through the Resource Group entry point on the Azure Portal.

### Resource Group Name

The name of the Resource group created (and the assets in that Resource Group) follows this pattern (where available):

* instanceNamePrefixYYYYMMDDHHmmSS

Review the **SampleScriptOutput.txt** file to preview the normal behaviour of the script (preview as at October 2024).

#### Key vault name specifics

The KeyVault - which *in Azure* requires a globally unique name - does NOT fit this standard (and specifix are seen in the DB Name too) but it is created in the Resource Group of this name.

### Database Access

A close inspection fo the script will identify the use of an online service to establish the IP address for the machine upon which the script is running - because this has to be set into the Firewall Rules for the database to enable database access by the script - ahead of injecting DDL (etc) into the database.

This also means that the database can only be accessed from the machine upon which the script executed (and assuming that machine has not seen a change of Public IP address).

To modify the access rules for the database - as at October 2024 - this requires other script or access via the Azure Portal.

#### Database Connection string

SQL Server Plugins in VSCode (or ther SQL Server access technology) can use a database connection string available on the database created during deployment. The easiest way to get the connection string (given that the RDBMS and DB Names are both environment instance specific) is via the Azure Portal.

Connection Strings available on the Azure Portal for the Database instance do nt include the password for the user specified.

For sqladmin access to this database, find the password on the Azure Portal in the Key Vault. The sqlAdmin username is also in the KeyVault, but is usually already present in the database connection strings available on the Database instance in the Portal.

## Azure Subscription details

An Azure Pay as You Go subscription is fine.

The first time you run this script, it is suggested you use a personal Pay as You Go subscription to review the results, and to aid in any troubleshooting.

## Azure footprint and cost management

The deployment into Azure creates resources that - in Azure terms - are billable.

**WARNING** :- please be sure to clean up any Resource groups resulting fromany executions of this script. Suggest: use the 'Delete Resource Group' on the Azure Portal User experience.

## Powershell and Azure Libraries

A machine capable of running a Powershell instance.

It is suggested you use Git to clone the repository.

Development and enhancement of this script is done in VSCode - but other editors are available.

The platform for running the script is any machine/OS that can run Powershell. Installing Powershell is operating-system specific (and not covered here).

The user will need to install the Azure Powershell libraries explicitly:

```Bash
Install-Module -Name Az -Repository PSGallery -Force 
```

Additional Azure libraries are required (as at October 2024 this is limited to the SQL Server Azure extensions) - but these are loaded on demand by the Powershell.
