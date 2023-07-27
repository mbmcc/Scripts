# Setting a variable for the registry path we want to check
$KeyPath = 'Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing'
$KeyValue = 'State'



#Setting Remote Session
$ComputerName = ''
$RemoteSession = New-PSSession -ComputerName $ComputerName #Creating a persistant session
Write-Host "Establishing Connection with "$ComputerName
Try {
Enter-PSSession -Session $RemoteSession # Connecting to the remote perisntant session
}
Catch {
Write-Out "Unable to connect to "$ComputerName
}


# Get each user profile SID and Path to the profile
$UserProfiles = Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*"

#Add in the .DEFAULT user profile$DefaultProfile = "" | Select-Object SID, UserHive
$DefaultProfile.SID = ".DEFAULT"
$DefaultProfile.Userhive = "C:\Users\Public\NTuser.dat"
$UserProfiles += $DefaultProfile

#Loop through each profile on the machine
foreach ($UserProfile in $UserProfiles) {
  #Load User ntuser.dat if it's not already loaded
  if (($ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($UserProfile.PSChildName)) -eq $false) {
    "User Profile $($UserProfile.ProfileImagePath) being loaded..."
    Start-Process -FilePath "cmd.exe" -argumentlist "/c reg.exe load HKU\$($UserProfile.PSChildName) $($UserProfile.UserHive)" -Wait -WindowStyle Hidden | Out-Null
    #reg load "HKU\$($UserProfile.PSChildName)" "$($UserProfile.UserHive)"
  }
  "User Profile $($UserProfile.ProfileImagePath) loaded..."
  #Manipulate the registry
  Try {
    $Key = Get-ItemProperty -Path "Registry::HKEY_USERS\$($UserProfile.PSChildName)\$KeyPath"
  }
  Catch {
    Write-Out "Caught - Unable to find HKEY_USERS\$($UserProfile.PSChildName)\$KeyPath"
  }

  #$Key = Get-ItemProperty -Path "Registry::HKEY_USERS\$($UserProfile.PSChildName)\$KeyPath"
  # Output the key info
  Write-Host "
  ------------------------
  Profile : $ProfileList[$p]
  SID : $SID
  Key : $Key.Path $KeyValue"
  Write-host -NoNewline "Value : " $KeyValue "= "
  $Key.$KeyValue
  Write-Host "
  ------------------------
  "

  #If the profile hive was loaded by the script, unload it
  if ($ProfileWasLoaded -eq $false) {
    [gc]::Collect()
    Start-Sleep 1
    Start-Process -FilePath "cmd.exe" -argumentlist "/c reg.exe unload HKU\($ProfileList[$p].SID)" -Wait -WindowStyle Hidden | Out-Null
    # reg.exe unload "HKU\($ProfileList[$p].SID)"
  }
}

Write-Host "Ending Connection with $ComputerName"
Exit-PSSession
