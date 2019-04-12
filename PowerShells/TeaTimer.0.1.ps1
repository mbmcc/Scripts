#Matthew McCourry
#last update 10-Apr-19 
$minutes=3
$totalSeconds=$minutes * 60
$note= "Tea is done"
#create WShell variable
$wshell = New-Object -ComObject Wscript.Shell; 

#function popUpTimer($totalSeconds ,$note){

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

#}
