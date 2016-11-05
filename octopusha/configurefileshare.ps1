param (
 [string] $storageAccountKey,
 [string] $storageAccountName,
 [string] $azureFileShareName
)
function Configure-OctopusDeploy
{
  Write-Log "======================================"
  Write-Log "ReConfigure Octopus Deploy for HA Setup"
  Write-Log ""
  
  cmdkey /add:dioctofileshare.file.core.windows.net /user:dioctofileshare /pass:645dND6eparOXf5HSR+X5g8i6Kia+5HTBwKDUN/wnnRxPYrwIyNZAJ99+YNmtHV+yV3EClmuDc+gtF8/FclNbg==
    
  $exe = 'C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe'
    
  $count = 0
  while(!(Test-Path $exe) -and $count -lt 5)
  {
    Write-Log "$exe - not available yet ... waiting 10s ..."
    Start-Sleep -s 10
    $count = $count + 1
  }
    
   Write-Log "Stopping Octopus Deploy instance ..."
  $args = @(
    'service', 
    '--console',
    '--instance', 'OctopusServer', 
    '--stop'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  
  Write-Log "Setting Artifacts path for Octopus Deploy instance ..."
  $args = @(
    'path', 
    '--console',
    '--artifacts', '\\dioctofileshare.file.core.windows.net\dioctoshare\OctopusData\Artifacts'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  
  Write-Log "Setting TaskLogs path for Octopus Deploy instance ..."
  $args = @(
    'path', 
    '--console',
    '--taskLogs', '\\dioctofileshare.file.core.windows.net\dioctoshare\OctopusData\Packages'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
  
  Write-Log "Setting NuGetRepository path for Octopus Deploy instance ..."
  $args = @(
    'path', 
    '--console',
    '--nugetRepository', '\\dioctofileshare.file.core.windows.net\dioctoshare\OctopusData\TaskLogs'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
   Write-Log "Reconfigure and start Octopus Deploy instance ..."
  $args = @(
    'service',
    '--console', 
    '--instance', 'OctopusServer', 
    '--install', 
    '--reconfigure', 
    '--start'
  )
  $output = .$exe $args
  Write-CommandOutput $output
  Write-Log "done."
    
  Write-Log ""
} 
