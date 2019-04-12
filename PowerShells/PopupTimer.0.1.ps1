#Matthew McCourry
#30MAR2018
#last update c05-Apr-19 
#create WShell variable
$seconds=2*60
$note= "Tea is done"
$wshell = New-Object -ComObject Wscript.Shell; 

#function popUpTimer($seconds ,$note){
sleep -seconds $seconds ; 
$wshell.Popup($note,0,"done",0x1);
#}
