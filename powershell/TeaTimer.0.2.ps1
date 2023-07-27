#Matthew McCourry
#last update 12-Apr-19 
# Matthew McCourry github.com/mbmcc

#create WShell variable
$wshell = New-Object -ComObject Wscript.Shell; 
function TeaTimer {
<#


#>

     [CmdletBinding()]

     Param (

        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
            $minutes,
        [Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
            $note
    )

    if ($minutes -eq $null){
        [double]$minutes=Read-Host -Prompt "How many minutes are you steeping the tea?" 
    }
    if ($note -eq $null){
        $note= "Tea is done"
    }

    $totalSeconds=$minutes * 60
    $countdown=1;

    while ($countdown -le $totalSeconds) {
        $progressPercent=$countdown / $totalSeconds * 100
        $activity= "Brew tea for $totalSeconds seconds"
        $status= "Ready in ... "+($totalSeconds - $countdown)

        Write-Progress -Activity $activity -Status $status -PercentComplete ($progressPercent)
        Start-Sleep -Milliseconds 975 #sleep is less than 1 second to account for script execution time
        $countdown++
    }
    $wshell.Popup($note,0,"done",0x1)

}
