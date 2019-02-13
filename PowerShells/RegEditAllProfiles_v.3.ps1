<#
Creator Matthew McCourry
matthew.b.mccourry.ctr@navy.mil
Development support from
Aaron W Campbell
aaron.w.campbell@navy.mil
last edit 31102018

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
[x] add New-Key function (in Set-Key
[x] add set function for existing key
[x] add Remove-Key function

v0.4 - polish and publish
[ ] sanitized / validate user input
[ ] ensure sane defaults
[ ] 
#>

$RegistryAction = 'Default'
$ComputerName = 'LocalHost'

#$TestKey = 'Control Panel\Desktop'
#$TestValue = "Wallpaper"

#### Key Functions ;-P #######
function Get-Key {
# Create and object with the status info:
        $keyStatus = [PSCustomObject]@{
            'Profile' = $User.ProfileImagePath
            'SID'     = $User.PSChildName 
            'Key'     = $("HKU\SID\\$($KeyPath)")
            'Value'   = $($KeyValue)
            'Data'    = $($Key.$KeyValue)
            'Hex'     = $('0x{0:x}' -f$Key.$KeyValue)
        }
        if(!(Test-Path -Path $KeyPath)) {
            #Failed to find the key
            Write-Host -ForegroundColor DarkYellow "Unable to load the key path. Maybe it does not exist."
            #$KeyStatus =''
        }else{
            #Load the key 
            $Key = Get-ItemProperty -Path "Registry::HKEY_USERS\$($User.PSChildName)\$KeyPath" 
        }
        

        # Output the key info
        $keyStatus | Format-List
}


function Set-Key { #change key or make new key

    #https://en.wikiversity.org/wiki/PowerShell/Registry
    if(!(Test-Path -Path $KeyPath)) {
        New-Item -Path $KeyPath
    }    
    if(!(Test-Path -Path "$KeyPath\$KeyValue")) {
        New-ItemProperty -Path $KeyPath -Name $KeyValue -PropertyType $ValueType -Value $ValueData
    }    

}

function Remove-Key {
    if(Test-Path -Path $KeyPath){
        Remove-Item -Path $KeyPath -Confirm -Recurse
    }
}
#### END Key Functions ####>

#### Session Functions ####
function Connect-Session {
    
    $RemoteSession = New-PSSession -ComputerName $ComputerName #Creating a persistant session
    Write-Host -ForegroundColor Green "Establishing Connection with "$ComputerName
    #$ErrorActionPreference = "Stop" 
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
#### END Session Functions ####>

#### Enumerate Profiles function ####
function Edit-Profiles {  

#################
<#
Test to see if you can create multiple functions that break the Edit-Profiles function into smaller parts
Load Profiles
# Do stuff
Unload Profiles
##################
#>

 
    # Get each user profile SID and Path to the profile
    # All profiles
    Switch($UserMode){
        Test {
            <# TEST Profile #>
            $UserProfiles = [PSCustomObject] @{
            'ProfileImagePath' = ''
            'PSChildName' = 'S-1-5-21-3813003615-122544535-2973631361-9419'
            }
        }
        All {
            $UserProfiles = Get-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\*"
            <#Add in the .DEFAULT user profile
            $DefaultProfile = [PSCustomObject] @{
            'PSChildName' = '.DEFAULT'
            'ProfileImagePath' = 'C:\Users\Public\NTuser.dat'
            }
            $UserProfiles += $DefaultProfile
            #>
        }
        
         Default {
                <# TEST Profile #>
                $UserProfiles = [PSCustomObject] @{
                'ProfileImagePath' = ''
                'PSChildName' = 'S-1-5-21-3813003615-122544535-2973631361-9419'
                }
            }
    }
    #Loop through each profile on the machine
    foreach ($User in $UserProfiles) {
        Write-Host "`n    ------------------------"

        #Load User ntuser.dat if it's not already loaded
        if (!($ProfileWasLoaded = Test-Path -path Registry::HKEY_USERS\$($User.PSChildName))) {
            "User Profile $($User.ProfileImagePath) being loaded..."
            Start-Process -FilePath "cmd.exe" -argumentlist "/c reg.exe load HKU\$($User.PSChildName)" -Wait -WindowStyle Hidden | Out-Null
            #reg load "HKU\$($User.PSChildName)" "$($User.UserHive)"
        } else {"Unable to load profile. Is it already loaded?"}
        
                
        #Manipulate the registry
        Switch ($RegistryAction) {
            Set {Set-Key}
            Get {Get-Key}
            Delete {Remove-Key}
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
#### END Enumerate Profiles Function ####>

#### Main Functions ####
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
        [string] $KeyValue ='',
        [parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string] $UserMode 

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
    .PARAMETER Value Type
    The possible type are String, ExpandString, Binary, DWord, MultiString, QWord, Unknown
    One of the Registry data value types: 
    .PARAMETER Value
    The value of the subkey
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
        [string] $KeyValue ='',
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] $ValueType ='',
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] $ValueData ='',
        [parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [switch] $UserMode 
    )
    
    PROCESS {

    $RegistryAction = 'Set'; 
    Connect-Session
    Edit-Profiles
    Disconnect-Session

    }
}
    
function Remove-KeyAllUsers {
           
    <#
    .SYNOPSIS
    Connect to a remote host, enumerate all user profiles and remove a registry key
    .DESCRIPTION
    Establish a static PSSession to a host, or list of hosts, recursively walk down the profiles on the host, 
    load thier individual NTUSER.DAT files into HKU, remove a Key, within the specified registry path.
    .PARAMETER computer
    The hostname or IP to connect to, localhost is default
    .PARAMETER path
    The key path to be checked in the registry
    .PARAMETER key
    The subkey to be checked
    .PARAMETER Value Type
    The possible type are String, ExpandString, Binary, DWord, MultiString, QWord, Unknown
    One of the Registry data value types: 
    .PARAMETER Value
    The value of the subkey
    .EXAMPLE
    Remove-KeyAllUsers -ComputerName <e.g."LocalHost"> -KeyPath <e.g."Control Panel\Desktop"> -KeyValue <e.g."Wallpaper">
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
        [parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string] $KeyValue ='',
        [parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [switch] $UserMode 
    )
    
    PROCESS {

    $RegistryAction = 'Delete'; 
    Connect-Session
    Edit-Profiles
    Disconnect-Session

    }
}
#### END Main Functions ####

#Export Functions used for the module. Comment out for testing.
<#
Export-ModuleMember -Function Get-KeyAllUsers
Export-ModuleMember -Function Set-KeyAllUsers
Export-ModuleMember -Function Remove-KeyAllUsers
#>
