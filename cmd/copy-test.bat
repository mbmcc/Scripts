
SET folder='Matt M'

ECHO "Copying remote %folder% to local %folder%

Echo "robocopy /E /MT:128 /XO /LOG:.\stig_robocopy.log "Z:\CKLs ready for scoring\%folder%" ".\CKLs ready for scoring\%folder%"

