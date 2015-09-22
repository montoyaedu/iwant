@echo on

reg.exe query "HKLM\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0" /v MSBuildToolsPath > nul 2>&1
if ERRORLEVEL 1 goto BuildError

for /f "skip=2 tokens=2,*" %%A in ('reg.exe query "HKLM\SOFTWARE\Microsoft\MSBuild\ToolsVersions\4.0" /v MSBuildToolsPath') do SET MSBUILDDIR=%%B

IF NOT EXIST %MSBUILDDIR%nul goto BuildError
IF NOT EXIST %MSBUILDDIR%msbuild.exe goto BuildError
rem pre-build project
"%MSBUILDDIR%msbuild.exe" /t:Rebuild /p:Configuration=Debug
if ERRORLEVEL 1 goto BuildError
rem pre-create setup package.
iscc.exe buildsetup.iss
if ERRORLEVEL 1 goto BuildError
rem change file version.txt from A.B.C.D-qualifierN-SNAPSHOT to A.B.C.D-qualifierN
call mvn dotnet:release
if ERRORLEVEL 1 goto BuildError
rem change file version.txt from A.B.C.D-qualifierN-SNAPSHOT to A.B.C.D
rem mvn dotnet:release -DremoveQualifier=true
set /p VERSION=< version.txt
rem set pom versions to VERSION.
call mvn versions:set -DnewVersion=%VERSION%
if ERRORLEVEL 1 goto BuildError
rem remove backup files.
call mvn versions:commit
if ERRORLEVEL 1 goto BuildError
rem synchronize assembly versions.
call mvn dotnet:version
if ERRORLEVEL 1 goto BuildError
rem commit to git local repo.
git commit -a -m "[RELEASE] - released version %VERSION%"
if ERRORLEVEL 1 goto BuildError
rem tag released version.
setlocal ENABLEDELAYEDEXPANSION
set vidx=0
for /F "tokens=*" %%A in (version.txt) do (
    SET /A vidx=!vidx! + 1
    set var!vidx!=%%A
)
git tag --file=version.txt %var1%
if ERRORLEVEL 1 goto BuildError
rem build project after tag
"%MSBUILDDIR%msbuild.exe" /t:Rebuild /p:Configuration=Debug
if ERRORLEVEL 1 goto BuildError
rem create setup package.
iscc.exe buildsetup.iss
if ERRORLEVEL 1 goto BuildError
rem deploy setup package to repository.
rem TODO
rem change file version.txt from A.B.C.D+1[-qualifierN+1] to A.B.C.D+1[-qualifierN+1]-SNAPSHOT
call mvn dotnet:next
if ERRORLEVEL 1 goto BuildError
rem change file version.txt from A.B.C.D to A.B.C.D-qualifier1
rem mvn dotnet:next -DversionQualifier=RC
set /p VERSION=< version.txt
rem set pom versions to VERSION.
call mvn versions:set -DnewVersion=%VERSION%
if ERRORLEVEL 1 goto BuildError
rem remove backup files.
call mvn versions:commit
if ERRORLEVEL 1 goto BuildError
rem synchronize assembly versions.
call mvn dotnet:version
if ERRORLEVEL 1 goto BuildError
rem commit to git local repo.
git commit -a -m "[RELEASE] - new development version set to %VERSION%"
if ERRORLEVEL 1 goto BuildError
rem push to repo
git push --all
if ERRORLEVEL 1 goto BuildError
git push --tags
if ERRORLEVEL 1 goto BuildError
goto:eof

::ERRORS
::---------------------
:BuildError
echo BuildError. Verify Console Output.
goto:eof
