<#
  Creates three SQL Server Virtual Machines using Windows Azure
  Setup for mirroring configuration (VM1,VM2 and Witness)
  Use Get-AzurePublishSettingsFile and Import-AzurePublishSettings file to import your subscription settings

  Author: Michael Washam
  Website: http://michaelwasham.com
  Twitter: MWashamMS
#> 

# Retrieve with Get-AzureSubscription 
$subscriptionName = '[SPECIFY SUBSCRIPTION NAME]'  

# Retrieve with Get-AzureStorageAccount
$storageAccountName = '[SPECIFY STORAGE ACCOUNT]'   

# Enumerate available locations with Get-AzureLocation
$location = 'West US'

# Retrieve current SQL Server image name with Get-AzureVMImage
$imageName = 'MSFT__Sql-Server-11EVAL-11.0.2215.0-08022012-en-us-30GB.vhd'

# ExtraSmall, Small, Medium, Large, ExtraLarge
$instanceSize = 'Medium' 

# Has to be a unique name. Verify with Test-AzureService
$serviceName = 'sqlsvc1' 

# SQL Server Names
$vmname1 = 'sqlvm1'
$vmname2 = 'sqlvm2' 
$vmname3 = 'sqlwitness'

# Availability Set Name - ensures virtual machines with the same workloads 
# are on physically seperated racks in the data center
# 99.95% SLA using AV sets
$avsetName = 'sqlavset' 

# Administrator password
$admpwd = '[SPECIFY PASSWORD]'

$dataDiskSizeGB = 500
$logDiskSizeGB = 100


# Specify the storage account location to store the newly created VHDs
Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName

# Select the correct subscription (allows multiple subscription support)
Select-AzureSubscription -SubscriptionName $subscriptionName

# Create the virtual machine configuration for SQLVM1
$sqlvm1 = New-AzureVMConfig -ImageName $imageName -InstanceSize $instanceSize -Name $vmname1 -AvailabilitySetName $avsetName |
			Add-AzureProvisioningConfig -Windows -Password $admpwd |
			Add-AzureDataDisk -CreateNew -DiskLabel 'data1' -DiskSizeInGB $dataDiskSizeGB -LUN 0 | 
			Add-AzureDataDisk -CreateNew -DiskLabel 'logs' -DiskSizeInGB $logDiskSizeGB -LUN 1 
	
# Create the virtual machine configuration for SQLVM2
$sqlvm2 = New-AzureVMConfig -ImageName $imageName -InstanceSize $instanceSize -Name $vmname2 -AvailabilitySetName $avsetName |
			Add-AzureProvisioningConfig -Windows -Password $admpwd |
			Add-AzureDataDisk -CreateNew -DiskLabel 'data1' -DiskSizeInGB $dataDiskSizeGB -LUN 0 | 
			Add-AzureDataDisk -CreateNew -DiskLabel 'logs' -DiskSizeInGB $logDiskSizeGB -LUN 1 	


# Create the virtual machine configuration for SQLVM3 (witness)
$sqlwitness = New-AzureVMConfig -ImageName $imageName -InstanceSize $instanceSize -Name $vmname3 |
			Add-AzureProvisioningConfig -Windows -Password $admpwd 
			
# Create the virtual machines
New-AzureVM -ServiceName $serviceName -Location $location -VMS $sqlvm1,$sqlvm2,$sqlwitness

### RDP into each VM and Configure Mirroring  ###
## http://msdn.microsoft.com/en-us/library/ms191140.aspx to configure mirroring ##