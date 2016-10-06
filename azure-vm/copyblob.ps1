$rgName = 'name'
$storageAccountName = 'dicustomimages'
$customimagebloguri = "https://$storageAccountName.blob.core.windows.net/system/Microsoft.Compute/Images/customvhds/dicustom-osDisk.a50ce7c4-0128-441e-a69f-bf712f4c4d93.vhd"
$location = 'North Europe'
#Create Below only if its first time
New-AzureRmResourceGroup -Name $rgName -Location $location -Force

$stoexists = Find-AzureRmResource -ResourceNameContains $storageAccountName 
if ($stoexists -eq $null)
{ 
    New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -Location $location -SkuName Standard_LRS -Verbose
    $stoctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $rgName -Name $storageAccountName).Value[0] 
    New-AzureStorageContainer -Name divhds  -Context $stoctx
}
else
{ 
$stoctx = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey (Get-AzureRmStorageAccountKey -ResourceGroupName $rgName -Name $storageAccountName).Value[0] 
}
Set-AzureStorageContainerAcl -Name divhds -Permission Blob -Context $stoctx
$sto = Get-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccountName
$stouri = -Join($sto.PrimaryEndpoints.Blob, 'divhds/dibasecustomimage' , '.vhd')
$stouri

Start-AzureStorageBlobCopy -AbsoluteUri $customimagebloguri -DestContainer 'divhds' -DestBlob 'dibasecustomimage.vhd' -DestContext $stoctx

                         
