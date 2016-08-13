param
    (
        [parameter(Mandatory=$true)] 
        [string] $SourceSqlServerName,

        [parameter(Mandatory=$true)] 
        [string] $SoruceDatabaseName,

        [parameter(Mandatory=$true)] 
        [string] $SourceRGName,

        [parameter(Mandatory=$true)] 
        [string] $TargetSqlServerName,

        [parameter(Mandatory=$true)] 
        [string] $TargetDatabaseName,
		
        [parameter(Mandatory=$true)] 
        [string] $TargetRGName
    )
$credential = Get-AutomationPSCredential –Name 'subscriptionaccess'
Add-AzureRmAccount -Credential $credential

Set-AzureRmContext -SubscriptionId (Get-AutomationVariable –Name 'subid')

$resourceExists = Find-AzureRmResource -ResourceNameContains $TargetDatabaseName
if ($resourceExists -eq $null)
{
	New-AzureRmSqlDatabaseCopy -DatabaseName $SoruceDatabaseName -ServerName $SourceSqlServerName -ResourceGroupName $SourceRGName -CopyServerName $TargetSqlServerName -CopyResourceGroupName $TargetRGName -CopyDatabaseName $TargetDatabaseName	
}
else
{
	Remove-AzureRmSqlDatabase -DatabaseName $TargetDatabaseName -ServerName $TargetSqlServerName -ResourceGroupName $TargetRGName -Force -Verbose
	New-AzureRmSqlDatabaseCopy -DatabaseName $SoruceDatabaseName -ServerName $SourceSqlServerName -ResourceGroupName $SourceRGName -CopyServerName $TargetSqlServerName -CopyResourceGroupName $TargetRGName -CopyDatabaseName $TargetDatabaseName
}
