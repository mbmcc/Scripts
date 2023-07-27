cls
# Initialize variables
# --------------------
$sender      = ""
$recipient   = ""
$subject     = ""
$filenames   = ""
$attachments = ""

Function Get-TextInput($inputName, $text, $defaultValue)
{

  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
  [Microsoft.VisualBasic.Interaction]::InputBox($text, $title, $defaultValue)

}



Function Get-Filename()
{
  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.MultiSelect = $true
  #$OpenFileDialog.initalDirectory = $initialDirectory
  $OpenFileDialog.title  = "Select Attachments..."
  $OpenFileDialog.filter = "ArgleBargle |*.*"     # "CSV (*.csv)| *.csv"
  $OpenFileDialog.ShowDialog() | Out-Null
  $OpenFileDialog.FileNames
}



# Prompt for user inputs
# ----------------------
$sender    = Get-TextInput "Sender" "Input sender email address:" "arglebargle@your.email.com"
$recipient = Get-TextInput "Recipient" "Input recipient email address:" ""
$subject   = Get-TextInput "Subject"   "Input subject line:" "Files from $sender"
$filenames = Get-Filename "."

$sender
$recipient
$subject
"-----"

# Wrap user inputs in quotes as appropriate
# -----------------------------------------
$sender    = "`"$sender`""
$recipient = "`"$recipient`""
$subject   = "`"$subject`""
foreach($file in $filenames) { $attachments = "$attachments,`"$attachment`"" }
$attachments.Trim(",")

$sender
$recipient
$subject
"-----"


 "Send-MailMessage -From $sender -To $recipient -Subject $subject -Body $subject -Attachments $attachments -SmtpServer `"kpwamfb.your.email.com`""

# $filesize = $attachments | Measure-Object -property length -sum




