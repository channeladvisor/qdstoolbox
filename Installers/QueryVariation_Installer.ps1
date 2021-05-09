Param(
    [Parameter(mandatory=$true)][string]$TargetInstance,
    [Parameter(mandatory=$true)][string]$TargetDatabase,
    [string]$TargetSchema = "dbo",
    [string]$Login,
    [string]$Password
)
Import-Module SqlServer

# Deploy all SQL script found in \QueryVariation
$SQLScripts = (Get-ChildItem -Path '..\QueryVariation' -Filter "*.sql") | Sort
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