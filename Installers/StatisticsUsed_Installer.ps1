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

# Deploy all SQL script found in \StatisticsUsed
$SQLScripts = (Get-ChildItem -Path '..\StatisticsUsed' -Filter "*.sql") | Sort
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