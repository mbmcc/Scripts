# Setting a variable for the registry path we want to check
$KeyPath = 'Software\Microsoft\Windows\CurrentVersion\WinTrust\Trust Providers\Software Publishing'
$KeyValue = 'State'

#$KeyPath = 'Software\Adobe'
#$KeyValue = 'AppData'


#Setting Remote Session
$ComputerName = ''
$RemoteSession = New-PSSession -ComputerName $ComputerName #Creating a persistant session
Write-Host -ForegroundColor Green "Establishing Connection with "$ComputerName
$ErrorActionPreference = "Stop" 
# to cause all errors to be terminating errors,  Useful for catch
Try {
    Enter-PSSession -Session $RemoteSession -ErrorAction "Stop"# Connecting to the remote perisntant session
} Catch {
    Write-Host "Unable to connect to "$ComputerName
    Exit
}

# Get each user profile SID and Path to the profile
$UserProfiles = Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*"


#Add in the .DEFAULT user profile
$DefaultProfile = "" | Select-Object SID, UserHive
$DefaultProfile.SID = ".DEFAULT"
$DefaultProfile.Userhive = "C:\Users\Public\NTuser.dat"
$UserProfiles += $DefaultProfile


#Loop through each profile on the machine
foreach ($User in $UserProfiles) {
    Write-Host "    ------------------------"
    #Load User ntuser.dat if it's not already loaded
    if (($ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($User.PSChildName)) -eq $false) {
        "User Profile $($User.ProfileImagePath) being loaded..."
        Start-Process -FilePath "cmd.exe" -argumentlist "/c reg.exe load HKU\$($User.PSChildName) e" -Wait -WindowStyle Hidden | Out-Null
        #reg load "HKU\$($User.PSChildName)" "$($User.UserHive)"
    }
    "User Profile $($User.ProfileImagePath) loaded..."
    #Manipulate the registry
    Try {
        #Load the key 
        $Key = Get-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\$KeyPath" 
    } Catch {
        #Write-Host -ForegroundColor Red "Unable to display registry key. Key not found" 
    }
 # Create and object with the status info:
    $keyStatus = [PSCustomObject]@{
        'Profile' = $User.ProfileImagePath
        'SID'     = $User.PSChildName 
        'Key'     = $("$($KeyPath)\$($KeyValue)")
        'Value'   = $("$($KeyValue) = $('0x{0:x}' -f$Key.$KeyValue)")
    }

    # Output the key info
    $keyStatus | Format-List

    #If the profile hive was loaded by the script, unload it
    if ($ProfileWasLoaded -eq $false) {
        "User Profile $($User.ProfileImagePath) being unloaded..."
        [gc]::Collect()
        Start-Sleep 1
        #v Using command shell to run reg.exe to allow for -wait to finish
        Start-Process -FilePath "cmd.exe" -argumentlist "/c reg.exe unload HKU\($User.PSChildName)" -Wait -WindowStyle Hidden | Out-Null
        # reg.exe unload "HKU\($User.PSChildName)"
        "User Profile $($User.ProfileImagePath) unloaded..."
    }
    Write-Host "    ------------------------ `n`n"
}
Write-Host -ForegroundColor Green "Ending Connection with $ComputerName"
Exit-PSSession #exit the persistant session
Remove-PSSession $ComputerName #Remove the persistant session

