:Matthew McCourry
:Pinglist.cmd
@ECHO OFF
SET list=%1
SET response="undef"

:Grab the list from the command prompt or just use machines.txt in the local directory
IF DEFINED list (
  SET list=%1
  ) ELSE (
  SET list=machines.txt
    ) 

ECHO Checking machines in %list%

: Go through the list, Output the list item, and ping the list item, then display a modified result
FOR /F "eol=; tokens=1,* delims=" %%z IN (
   %list%
   ) DO (
       ECHO. && ECHO %%z && FOR /F "usebackq delims==" %%i IN (
         `ping -n 1 %%z`
         ) DO (
              SET response='ECHO %%i | find "Reply"'
             )
       ) && ECHO %response% && ECHO ----------
     )

:          IF DEFINED %%i (
:            ECHO Not Responding
:            ) ELSE (
:              ECHO %%i | find "Reply"

