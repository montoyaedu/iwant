@echo on

call mvn dotnet:release
if ERRORLEVEL 1 goto Error

set /p VERSION=< version.txt
if ERRORLEVEL 1 goto Error

call mvn versions:set -DnewVersion=%VERSION%
if ERRORLEVEL 1 goto Error

call mvn versions:commit
if ERRORLEVEL 1 goto Error

call mvn dotnet:version
if ERRORLEVEL 1 goto Error

git commit -a -m "[RELEASE] - released version %VERSION%"
if ERRORLEVEL 1 goto Error

git tag --file=version.txt %VERSION%
if ERRORLEVEL 1 goto Error

set LATEST_TAG=%VERSION%

call mvn dotnet:next
if ERRORLEVEL 1 goto Error

set /p VERSION=< version.txt
if ERRORLEVEL 1 goto Error

call mvn versions:set -DnewVersion=%VERSION%
if ERRORLEVEL 1 goto Error

call mvn versions:commit
if ERRORLEVEL 1 goto Error

call mvn dotnet:version
if ERRORLEVEL 1 goto Error

git commit -a -m "[RELEASE] - new development version set to %VERSION%"
if ERRORLEVEL 1 goto Error

git push --all --follow-tags
if ERRORLEVEL 1 goto Error

release.bat %LATEST_TAG%

goto:eof

:Error
echo Error. Verify Console Output.

goto:eof
