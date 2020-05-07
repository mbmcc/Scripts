@ECHO OFF


CALL %USERPROFILE%\doskeys.cmd
::
::@ECHO OFF
::REM Doskeys, to emulate some posix / bash familiarity
::REM https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-xp/bb490894(v=technet.10)?redirectedfrom=MSDN
::REM
::
::doskey cd-=popd
::doskey cd=pushd $*
::doskey cd~=pushd %USERPROFILE%
::doskey clear=cls
::doskey cp=copy $*
::doskey la=dir /Q /O:G $*
::doskey lb=dir /S /B $*
::doskey ld=dir /A:D $*
::doskey lg=dir /O:G $*
::doskey ll=dir $*
::doskey ls=dir /D /O:G /O:N $*
::doskey lt=dir /T:W /O:D $*
::doskey lx=dir /D /O:G /O:E $*
::doskey md=mkdir $*
::doskey mv=move $*
::doskey rcp=robocopy $*
::doskey rm=del $*
::doskey rsync=robocopy $*
::doskey vi=explorer "%USERPROFILE%\Downloads\vim\gvim81\vim\vim81\gvim.exe" $*
::doskey vim=explorer "%USERPROFILE%\Downloads\vim\gvim81\vim\vim81\gvim.exe" $*
::doskey e=explorer $*
::

CALL %USERPROFILE%\shortcuts.cmd


CALL %USERPROFILE%\prompt.cmd
::
::prompt $S$S$T$S$D$S$C$P$F$L$+$G$_$S$S$S$G$S 
::
