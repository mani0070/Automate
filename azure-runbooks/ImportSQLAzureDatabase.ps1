param
    (
        [parameter(Mandatory=$true)] 
        [string] $TargetSqlServerName, #

        [parameter(Mandatory=$true)] 
        [string] $TargetDatabaseName, #

        [parameter(Mandatory=$true)] 
        [string] $TargetRGName, #

        [parameter(Mandatory=$true)] 
        [string] $storageAccountName, #

        [parameter(Mandatory=$true)] 
        [string] $svcObjective,         #
		
		 [parameter(Mandatory=$true)] 
        [string] $dbEdition,  #Basic

		[parameter(Mandatory=$true)] 
        [string] $blobname,         #
		
         [parameter(Mandatory=$true)] 
        [string] $ContainerName, #
		
        [parameter(Mandatory=$true)] 
        [string] $rgNameStorage # 
    )

    # 
$credential = Get-AutomationPSCredential –Name 'subscriptionaccess'
$sqlcredential = Get-AutomationPSCredential –Name 'sqlcred'
Add-AzureRmAccount -Credential $credential
$sqlpassword = (Get-AutomationVariable –Name 'sqlpassword') | ConvertTo-SecureString -AsPlainText -Force

Set-AzureRmContext -SubscriptionId (Get-AutomationVariable –Name 'subid')
$stoexists = Find-AzureRmResource -ResourceNameContains $storageAccountName 
if ($stoexists -eq $null)
{ 
    Write-Output 'Storage Account does not exists, Please run the Export runbook'
}
else
{
    $stoctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $rgNameStorage -Name $storageAccountName).Value[0] 
}

$sto = Get-AzureRmStorageAccount -ResourceGroupName $rgNameStorage -Name $storageAccountName
try
{
    $blob = Get-AzureStorageBlob -Container $ContainerName -Context $stoctx -Blob $blobname -ErrorAction Stop
}
catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException]
{
    Write-Error 'Blob Does Not exists, Please Check Export process is completed'
}

$stouri = -Join($sto.PrimaryEndpoints.Blob, $ContainerName , '/', $blobname)

$ruleList = Get-AzureRmSqlServerFirewallRule -ServerName $TargetSqlServerName -ResourceGroupName $TargetRGName
if (!($ruleList.FirewallRuleName.Contains('AllowAllAzureIPs')))
{
    New-AzureRmSqlServerFirewallRule -ServerName $TargetSqlServerName -ResourceGroupName $TargetRGName -AllowAllAzureIPs -Verbose
}

Remove-AzureRmSqlDatabase -DatabaseName $TargetDatabaseName -ServerName $TargetSqlServerName -ResourceGroupName $TargetRGName -Force
Write-Output 'Removed the target database'
 $statusImport = New-AzureRmSqlDatabaseImport -DatabaseName $TargetDatabaseName -ServerName $TargetSqlServerName -Edition $dbEdition -ResourceGroupName $TargetRGName -ServiceObjectiveName $svcObjective `
    -DatabaseMaxSizeBytes 2048 -AuthenticationType Sql -AdministratorLogin  (Get-AutomationVariable –Name 'targetsqlusername') -AdministratorLoginPassword $sqlpassword -StorageKeyType StorageAccessKey `
        -StorageKey (Get-AzureRmStorageAccountKey -ResourceGroupName $rgNameStorage -Name $storageAccountName).Value[0] -StorageUri $stouri -Verbose
		
while ((Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $statusImport.OperationStatusLink).Status -ne 'Succeeded' )

 { 
  	Start-Sleep(10)
	if ($statusImport.Status -eq 'Failed')
	{
			Write-Output $statusImport.Status
			Exit 
	}
  }
  
  Write-Output 	'Import Operation Completed'
	