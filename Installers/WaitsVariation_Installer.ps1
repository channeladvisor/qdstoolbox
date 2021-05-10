Param(
    [Parameter(mandatory=$true)][string]$TargetInstance,
    [Parameter(mandatory=$true)][string]$TargetDatabase,
    [string]$TargetSchema = "dbo",
    [string]$Login,
    [string]$Password
)
Import-Module SqlServer

# Verify SQL version
if($Login){
    $SQLVersion = Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Username $Login -Password $Password -Query "SELECT CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT) AS [VersionNumber]"
}
else {
    $SQLVersion = Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Query "SELECT CAST(SUBSTRING(CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0,CHARINDEX('.',CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),0)) AS INT) AS [VersionNumber]"
}
if($SQLVersion.VersionNumber -lt 14){
    Write-Output "The component [WaitsVariation] cannot be deployed on a SQL version prior to 2017"
    return
}

# Deploy all SQL script found in \WaitsVariation
$SQLScripts = (Get-ChildItem -Path '..\WaitsVariation' -Filter "*.sql") | Sort
foreach($Script in $SQLScripts){
    # Replace default schema name [dbo] with [$TargetSchema]
    $ScriptContents = Get-Content -Path $Script.FullName -Raw
    $ScriptContents = ($ScriptContents.Replace("[dbo]","[$($TargetSchema)]"))

    # Deploy updated script
    if($Login){
        # Login / Password authentication
        Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Username $Login -Password $Password -Query $ScriptContents
    }
    else {
        # Active Directory authentication
        Invoke-SqlCmd -ServerInstance $TargetInstance -Database $TargetDatabase -Query $ScriptContents
        }  
}