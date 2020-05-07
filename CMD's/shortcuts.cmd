
@ECHO OFF
:: Doskeys, to create some shortcuts for my current work setup
:: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-xp/bb490894(v=technet.10)?redirectedfrom=MSDN
echo: 
echo gstigs - "%USERPROFILE%\Downloads\SQL STIGS"
echo gdown - "%USERPROFILE%\Downloads\" 
echo ghome - "%USERPROFILE%" 
echo gdocs - "%USERPROFILE%\Documents"
echo gnotes - "%USERPROFILE%\Notes"
echo Z Drive == "\\c27storkypt1\191\CSS\Athena\SQL STIG Team"
echo:

doskey gstigs=chdir "%USERPROFILE%\Downloads\SQL STIGS"
doskey gdown=chdir "%USERPROFILE%\Downloads\"
doskey ghome=chdir "%USERPROFILE%"
doskey gdocs=chdir "%USERPROFILE%\Documents\"
doskey gnotes=chdir "%USERPROFILE%\Notes\"

