Param(
    [Parameter(mandatory=$true)][string]$TargetInstance,
    [Parameter(mandatory=$true)][string]$TargetDatabase,
    [string]$TargetSchema = "dbo",
    [string]$Login,
    [string]$Password
)

.\PivotedWaitStats_Installer.ps1    -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\PlanMiner_Installer.ps1           -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\QDSCacheCleanup_Installer.ps1     -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\QueryVariation_Installer.ps1      -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\QueryWaits_Installer.ps1          -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\ServerTopQueries_Installer.ps1    -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\StatisticsUsed_Installer.ps1      -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\WaitsVariation_Installer.ps1      -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password
.\QueryReport_Installer.ps1         -TargetInstance $TargetInstance -TargetDatabase $TargetDatabase -TargetSchema $TargetSchema -Login $Login -Password $Password