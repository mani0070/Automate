param
    (
        [parameter(Mandatory=$true)] 
        [string] $SourceSqlServerName,

        [parameter(Mandatory=$true)] 
        [string] $SoruceDatabaseName,

        [parameter(Mandatory=$true)] 
        [string] $SourceRGName,

        [parameter(Mandatory=$true)] 
        [string] $storageAccountName,

        [parameter(Mandatory=$true)] 
        [string] $location,

         [parameter(Mandatory=$true)] 
        [string] $ContainerName,
		
        [parameter(Mandatory=$true)] 
        [string] $rgNameStorage
    )
$credential = Get-AutomationPSCredential –Name 'subscriptionaccess'
$sqlcredential = Get-AutomationPSCredential –Name 'sqlcred'
$blobname = -Join($SoruceDatabaseName , '.bacpac')

Add-AzureRmAccount -Credential $credential
$sqlpassword = (Get-AutomationVariable –Name 'sqlpassword') | ConvertTo-SecureString -AsPlainText -Force

Set-AzureRmContext -SubscriptionId (Get-AutomationVariable –Name 'subid')

$stoexists = Find-AzureRmResource -ResourceNameContains $storageAccountName 

if ($stoexists -eq $null)
{ 
    Write-Output "Creating New Stroage Account"
	New-AzureRmStorageAccount -ResourceGroupName $rgNameStorage -Name $storageAccountName -Location $location -SkuName Standard_LRS -Verbose
    $stoctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $rgNameStorage -Name $storageAccountName).value[0] 
    New-AzureStorageContainer -Name $ContainerName  -Context $stoctx
}
else
{
    $stoctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $rgNameStorage -Name $storageAccountName).value[0] 
}

$sto = Get-AzureRmStorageAccount -ResourceGroupName $rgNameStorage -Name $storageAccountName
try
{
    $blob = Get-AzureStorageBlob -Container $ContainerName -Context $stoctx -Blob $blobname -ErrorAction Stop
	Remove-AzureStorageBlob -Blob $blobname  -Context $stoctx -Container $ContainerName -Force
}
catch [Microsoft.WindowsAzure.Commands.Storage.Common.ResourceNotFoundException]
{
    Write-Output 'Blob Does Not exists'
    $blob = $null
}
$stouri = -Join($sto.PrimaryEndpoints.Blob, $ContainerName , '/', $blobname)

$ruleList = Get-AzureRmSqlServerFirewallRule -ServerName $SourceSqlServerName -ResourceGroupName $SourceRGName
if (!($ruleList.FirewallRuleName.Contains('AllowAllAzureIPs')))
{
    Write-Output "Adding New Rule"
	New-AzureRmSqlServerFirewallRule -ServerName $SourceSqlServerName -ResourceGroupName $SourceRGName -AllowAllAzureIPs -Verbose
}

 $statusExport = New-AzureRmSqlDatabaseExport -DatabaseName $SoruceDatabaseName -ServerName $SourceSqlServerName -AdministratorLogin (Get-AutomationVariable –Name 'sqlusername') -AdministratorLoginPassword $sqlpassword `
        -AuthenticationType Sql -ResourceGroupName $SourceRGName -StorageKeyType StorageAccessKey `
        -StorageKey (Get-AzureRmStorageAccountKey -ResourceGroupName $rgNameStorage -Name $storageAccountName).value[0] -StorageUri $stouri -Verbose
		
 while ((Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $statusExport.OperationStatusLink).Status -ne 'Succeeded')
 { 
  	Write-Output $statusExport.Status
  	Start-Sleep(10)
  }
   
 