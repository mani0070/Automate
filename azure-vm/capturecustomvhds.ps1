$vmName = 'nameofvm'
$rgName = 'nameofresourcegroup'

Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force

Set-AzureRmVM -ResourceGroupName $rgname -Name $vmName -Generalized

Save-AzureRmVMImage -ResourceGroupName $rgName -Name $vmName -DestinationContainerName 'customvhds' -VHDNamePrefix 'dicustom' -Path C:\Packer\dicustom.json

#The image will be available under 
https://<storageaccountofthevm>.blob.core.windows.net/system/Microsoft.Compute/Images/customvhds/dicustom-osDisk.<uniqueGUID>.vhd
