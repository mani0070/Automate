
$serverName = 'diexam'
$rgName = 'diexam'
$dbEdition = 'Basic'
$dbName = 'diexam'
$location = 'North Europe'

Write-Host 'Enter the Password'
$password = Read-Host 
$username = 'iknowyou'
$password = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $username, $password

New-AzureRmResourceGroup -Name $rgName -Location $location -Force

New-AzureRmSqlServer -ServerName $serverName -SqlAdministratorCredentials $cred -Location 'North Europe' -ServerVersion 12.0 -ResourceGroupName $rgName -Verbose
New-AzureRmSqlDatabase -ServerName $serverName -DatabaseName $dbName -Edition $dbEdition -Collation 'SQL_Latin1_General_CP1_CI_AS' -ResourceGroupName $rgName


#Allow 30mins before you delete the databases during the testing
Get-AzureRmSqlDatabase -ServerName $serverName -ResourceGroupName $rgName | % {$_.DatabaseName}

$deleteddb = Get-AzureRmSqlDeletedDatabaseBackup -ServerName $serverName -ResourceGroupName $rgName -DatabaseName $dbName
if ($deleteddb -ne $null)
{
    Write-Host "Database {0} Deleted On 't{1}'t{3}" –f $deleteddb.DatabaseName,$deleteddb.DeletionDate, $deleteddb
}

Restore-AzureRmSqlDatabase -FromDeletedDatabaseBackup -DeletionDate $deleteddb.DeletionDate -ServerName $serverName -TargetDatabaseName $dbName `
     -Edition $dbEdition -ResourceGroupName $serverName -ResourceId $deleteddb.ResourceId

Get-AzureRmSqlDatabase -ServerName $serverName -ResourceGroupName $rgName | % {$_.DatabaseName}

