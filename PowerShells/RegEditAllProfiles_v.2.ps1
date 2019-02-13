<#
Creator Matthew McCourry
matthew.b.mccourry.ctr@navy.mil
Co-Author Aaron W Campbell
aaron.w.campbell@navy.mil
last edit 18102018

Changelog
V0.1 - Building out Initial structure

[x] ennumerate user profiles
[x] connect to remote server registry
[x] load each user profile hive
[x] check registry key / value for each user profile

v0.2 - adding interface
[x] refactor code for modular execution
[x] Provide Help data
[x] Add get function
[x] Select remote server
[x] Set default localhost
[x] allow selection of registry key

v0.3 - create modifier functions
[ ] add New-Key function
[ ] add set function for existing key
[ ] add Remove-Key function
#>

$RegistryAction = 'Default'

function Get-Key {
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
            'Key'     = $("HKU\SID\\$($KeyPath)\$($KeyValue)")
            'Value'   = $("$($KeyValue) = $('0x{0:x}' -f$Key.$KeyValue)")
        }

        # Output the key info
        $keyStatus | Format-List
}
function Set-Key {

}


function Connect-Session {
    
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
}

function Disconnect-Session {
    
    Write-Host -ForegroundColor Green "Ending Connection with $ComputerName"
    Exit-PSSession #exit the persistant session
    Remove-PSSession $ComputerName #Remove the persistant session
}


function Edit-Profiles {
 
    # Get each user profile SID and Path to the profile
    # All profiles
    $UserProfiles = Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*"
    <#Add in the .DEFAULT user profile
    $DefaultProfile = [PSCustomObject] @{
        'PSChildName' = '.DEFAULT'
        'ProfileImagePath' = 'C:\Users\Public\NTuser.dat'
    }
    $UserProfiles += $DefaultProfile
    #>
    
    <# TEST Profile #>
    $UserProfiles = [PSCustomObject] @{
      'ProfileImagePath' = ''
      'PSChildName' = 'S-1-5-21-3813003615-122544535-2973631361-9419'
    }
    #>

    #Loop through each profile on the machine
    foreach ($User in $UserProfiles) {
        Write-Host "`n    ------------------------"
        #Load User ntuser.dat if it's not already loaded
        if (($ProfileWasLoaded = Test-Path Registry::HKEY_USERS\$($User.PSChildName)) -eq $false) {
            "User Profile $($User.ProfileImagePath) being loaded..."
            Start-Process -FilePath "cmd.exe" -argumentlist "/c reg.exe load HKU\$($User.PSChildName) $($User.UserHive)" -Wait -WindowStyle Hidden | Out-Null
            #reg load "HKU\$($User.PSChildName)" "$($User.UserHive)"
        }
        "User Profile $($User.ProfileImagePath) loaded..."
                
        #Manipulate the registry
        Switch ($RegistryAction) {
            Set {Set-Key}
            Get {Get-Key}
            Default {Get-Key}
        }
        #### Done with Registry
        
        #If the profile hive was loaded by the script, unload it
        if ($ProfileWasLoaded -eq $false) {
            "User Profile $($User.ProfileImagePath) being unloaded..."
            [gc]::Collect()
            Start-Sleep 1
            #v Using command shell to run reg.exe to allow for -wait to finish
            Start-Process -FilePath "cmd.exe" -argumentlist "/c reg.exe unload HKU\($User.PSChildName)" -Wait -WindowStyle Hidden | Out-Null
            # reg.exe unload "HKU\($User.PSChildName)"
            "User Profile $($User.ProfileImagePath) unloaded..."
        } else {
        "Unable to unload $($User.ProfileImagePath)"
        }
        Write-Host "    ------------------------ `n"
    }
 }


function  Get-KeyAllUsers {

 <#
    .SYNOPSIS
    Connect to a remote host, enumerate all user profiles and provide the status of a registry key
    .DESCRIPTION
    Establish a static PSSession to a host, or list of hosts, recursively walk down the profiles on the host, 
    load thier individual NTUSER.DAT files into HKU, display the value of a Key, within the specified registry path.
    Output of value is in Hex.
    .PARAMETER computer
    The hostname or IP to connect to, localhost is default
    .PARAMETER path
    The key path to be checked in the registry
    .PARAMETER key
    The subkey to be checked
    .EXAMPLE
    Get-KeyAllUsers -ComputerName <e.g."LocalHost"> -KeyPath <e.g."Control Panel\Desktop"> -KeyValue <e.g."Wallpaper">
    .NOTES
    This will need to be ran with Administrator credentials
    .LINK

    #>
    
    param (
        [AllowEmptyString()]
        [parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [string] $ComputerName = 'localhost',
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] $KeyPath ='',
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] $KeyValue =''
    )
    
    PROCESS {

    $RegistryAction = 'Get'; 
    Connect-Session
    Edit-Profiles
    Disconnect-Session



    }
}


function Set-KeyAllUsers {
           
    <#
    .SYNOPSIS
    Connect to a remote host, enumerate all user profiles and provide the status of a registry key
    .DESCRIPTION
    Establish a static PSSession to a host, or list of hosts, recursively walk down the profiles on the host, 
    load thier individual NTUSER.DAT files into HKU, display the value of a Key, within the specified registry path.
    Output of value is in Hex.
    .PARAMETER computer
    The hostname or IP to connect to, localhost is default
    .PARAMETER path
    The key path to be checked in the registry
    .PARAMETER key
    The subkey to be checked
    .EXAMPLE
    Get-KeyAllUsers -ComputerName <e.g."LocalHost"> -KeyPath <e.g."Control Panel\Desktop"> -KeyValue <e.g."Wallpaper">
    .NOTES
    This will need to be ran with Administrator credentials
    .LINK

    #>
    
    param (
        [AllowEmptyString()]
        [parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]

        [string] $ComputerName = 'localhost',
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] $KeyPath ='',
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] $KeyValue =''
    )
    
    PROCESS {

    $RegistryAction = 'Set'; 
    Connect-Session
    Edit-Profiles
    Disconnect-Session

    }
}

#Export-ModuleMember -Function Get-KeyAllUsers
#Export-ModuleMember -Function Set-KeyAllUsers
