#Matthew McCourry
#30MAR2018
#last update c05-Apr-19 
#create WShell variable
$seconds=10
$note= "Tea is done"
$wshell = New-Object -ComObject Wscript.Shell; 

#function popUpTimer($seconds ,$note){
$tick=1;

while ($tick -le $seconds) {
$progressPercent=$tick / $seconds * 100
Write-Progress -Activity "Tea is Brewing " -PercentComplete ($progressPercent)
sleep -Seconds 1
$tick++
}
$wshell.Popup($note,0,"done",0x1)

#}
