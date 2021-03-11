# Installers
The installers require the SqlServer PS module to be installed
``` 
Install-Module SqlServer
Import-Module SqlServer
```
## Parameters
```
Param(
    [Parameter(mandatory=$true)][string]$TargetInstance,
    [Parameter(mandatory=$true)][string]$TargetDatabase,
    [string]$TargetSchema = "dbo",
    [string]$Login,
    [string]$Password
)
```
$TargetSchema allows the QDSToolBox object to be deployed into a different schema than [dbo] (hardcoded in the SQL scripts)
\
By default, it will use the current user's Windows Credentials to connect to the database, but this can be modified by using SQL credentials ($Login and $Password)

## Sample deployment
```
.\QDSToolbox_Installer.ps1 -TargetInstance "Machine\Instance" -TargetDatabase "AdminDB" -TargetSchema "QDS"
```

---

# Testing scripts
The accompannying _Test.sql scripts will check the correct execution of the QDSToolBox components
\
These scripts are meant to help testing new changes in the scripts