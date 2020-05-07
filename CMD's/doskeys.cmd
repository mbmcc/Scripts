
:: Doskeys, to emulate some posix / bash familiarity
:: https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-xp/bb490894(v=technet.10)?redirectedfrom=MSDN
@ECHO OFF
doskey cd-=popd
doskey cd=pushd $*
doskey cd~=pushd %USERPROFILE%
doskey clear=cls
doskey cp=copy $*
doskey e=explorer $*
doskey la=dir /Q /O:G $*
doskey lb=dir /S /B $*
doskey ld=dir /A:D $*
doskey lf=dir /A:-D $*
doskey lg=dir /O:G $*
doskey ll=dir $*
doskey ls=dir /D /O:G /O:N $*
doskey lt=dir /T:W /O:D $*
doskey lx=dir /D /O:G /O:E $*
doskey md=mkdir $*
doskey mv=move $*
doskey py=explorer "%USERPROFILE%\Downloads\python\python-3.8.2\python.exe" $*
doskey python=explorer "%USERPROFILE%\Downloads\python\python-3.8.2\python.exe" $*
doskey rcp=robocopy $*
doskey rm=del $*
doskey rsync=robocopy $*
doskey run=explorer.exe "Shell:::{2559a1f3-21d7-11d4-bdaf-00c04f60b9f0}" $*
doskey vi=explorer "%USERPROFILE%\Downloads\vim\gvim81\vim\vim81\gvim.exe" $*
doskey vim=explorer "%USERPROFILE%\Downloads\vim\gvim81\vim\vim81\gvim.exe" $*
doskey ~=%USERPROFILE%
