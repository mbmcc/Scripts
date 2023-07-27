<###############################
Transcribed and editted by Matthew McCourry
matthew.b.mccourry.ctr@navy.mil

Referenced from Creating custom objects:
https://www.gngrninja.com/script-ninja/2016/6/18/powershell-getting-started-part-12-creating-custom-objects

###############################>


$adminPasswordStatus    = $null
$thermalState           = $null
$osInfo                 = Get-CimInstance Win32_OperatingSystem
$computerInfo           = Get-CimInstance Win32_ComputerSystem
$diskInfo               = Get-CimInstance Win32_LogicalDisk

Switch ($computerInfo.adminPasswordStatus) {
    0 {$adminPasswordStatus = 'Disabled'}
    1 {$adminPasswordStatus = 'Enabled'}
    2 {$adminPasswordStatus = 'Not Implemented'}
    3 {$adminPasswordStatus = 'Unknown'}
    Default {$adminPasswordStatus = 'Unable to determine'}
}
Switch ($computerInfo.thermalState) {
    1 {$thermalState = 'Other'}
    2 {$thermalState = 'Unknown'}
    3 {$thermalState = 'Safe'}
    4 {$thermalState = 'Warning'}
    5 {$thermalState = 'Critical'}
    6 {$thermalState = 'Non-recoverable'}
    Default {$thermalState = 'Unable to determine'}
}
# New Object $ourObject is going to be $systemStatus (changed from the reference site)
<# 
# Creating the new object and then using add-member to add properties to the object 
$systemStatus = New-Object -TypeName PSObject
$systemStatus | Add-Member -MemberType NoteProperty -Name 'Computer Name' -Value $computerInfo.Name
$systemStatus | Add-Member -MemberType NoteProperty -Name OS -Value $osInfo.Caption
$systemStatus | Add-Member -MemberType NoteProperty -Name 'OS Version' -Value $("$($osInfo.Version) Build $($osInfo.BuildNumber)")
$systemStatus | Add-Member -MemberType NoteProperty -Name Domain -Value $computerInfo.Domain
$systemStatus | Add-Member -MemberType NoteProperty -Name Workgroup -Value $computerInfo.Workgroup
$systemStatus | Add-Member -MemberType NoteProperty -Name 'Domain Joined' -Value $computerInfo.PartOfDomain
$systemStatus | Add-Member -MemberType NoteProperty -Name Disks -Value $diskInfo
$systemStatus | Add-Member -MemberType NoteProperty -Name 'Admin Password Status' -Value $adminPasswordStatus
$systemStatus | Add-Member -MemberType NoteProperty -Name 'Thermal State' -Value $thermalState
#>

<# 
# Creating the properties through a hashtable then adding them to an object
[hashtable]$objectProperty = @{} #empty hashtable
$objectProperty.Add('Computer Name',$computerInfo.Name)
$objectProperty.Add('OS',$osInfo.Caption)
$objectProperty.Add('OS Version',$("$($osInfo.Version) Build $($osInfo.BuildNumber)"))
$objectProperty.Add('Domain',$computerInfo.Domain)
$objectProperty.Add('Workgroup',$computerInfo.Workgroup)
$objectProperty.Add('Domain Joined',$computerInfo.PartOfDomain)
$objectProperty.Add('Disks',$diskInfo)
$objectProperty.Add('Admin Password Status',$adminPasswordStatus)
$objectProperty.Add('Thermal State',$thermalState)

$systemStatus = New-Object -TypeName PSObject -Property $objectProperty #creating the object "systemStatus" using the properties from the hashtable
#>
<#
# Creating an Ordered hashtable that contains the table property values in one go
$objectProperty = [ordered]@{
    'Computer Name'         = $computerInfo.Name
    'OS'                    = $osInfo.Caption
    'OS Version'            = $("$($osInfo.Version) Build $($osInfo.BuildNumber)")
    'Domain'                = $computerInfo.Domain
    'Workgroup'             = $computerInfo.Workgroup
    'Domain Joined'         = $computerInfo.PartOfDomain
    'Disks'                 = $diskInfo
    'Admin Password Status' = $adminPasswordStatus
    'Thermal State'         = $thermalState
}
$systemStatus = New-Object -TypeName PSObject -Property $objectProperty #creating an object with the previously created hashtable
#>
<##>
# Creating the hashtable and object all in one 
$systemStatus = [PSCustomObject]@{
    'Computer Name'         = $computerInfo.Name
    'OS'                    = $osInfo.Caption
    'OS Version'            = $("$($osInfo.Version) Build $($osInfo.BuildNumber)")
    'Domain'                = $computerInfo.Domain
    'Workgroup'             = $computerInfo.Workgroup
    'Domain Joined'         = $computerInfo.PartOfDomain
    'Disks'                 = $diskInfo
    'Admin Password Status' = $adminPasswordStatus
    'Thermal State'         = $thermalState
}

# Main #
$systemStatus
