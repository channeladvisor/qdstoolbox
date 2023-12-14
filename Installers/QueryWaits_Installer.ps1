Param(
    [Parameter(mandatory=$true)][string]$TargetInstance,
    [Parameter(mandatory=$true)][string]$TargetDatabase,
    [string]$TargetSchema = "dbo",
    [string]$Login,
    [string]$Password
)
Import-Module SqlServer
# For versions >= 22 of the SqlServer PS module, the default encryption changed so it must be manually set Encrypt
if( (Get-Module -Name "sqlserver").Version.Major -ge 22){
    $EncryptionParameter = @{Encrypt = "Optional"}
}

# Verify SQL version
if($Login){
    $SQLVersion = Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Username $Login -Password $Password -Query "SELECT CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT) AS [VersionNumber]"
}
else {
    $SQLVersion = Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Query "SELECT CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT) AS [VersionNumber]"
}
if($SQLVersion.VersionNumber -lt 14){
    Write-Output "The component [QueryWaits] cannot be deployed on a SQL version prior to 2017"
    return
}

# Deploy all SQL script found in \QueryWaits
$SQLScripts = (Get-ChildItem -Path '..\QueryWaits' -Filter "*.sql") | Sort
foreach($Script in $SQLScripts){
    # Replace default schema name [dbo] with [$TargetSchema]
    $ScriptContents = Get-Content -Path $Script.FullName -Raw
    $ScriptContents = ($ScriptContents.Replace("[dbo]","[$($TargetSchema)]"))

    # Deploy updated script
    if($Login){
        # Login / Password authentication
        Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Username $Login -Password $Password -Query $ScriptContents @EncryptionParameter
    }
    else {
        # Active Directory authentication
        Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Query $ScriptContents @EncryptionParameter
        }  
}