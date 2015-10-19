@echo off

echo "REMOVING -SNAPSHOT QUALIFIER FROM version.txt"

call mvn dotnet:release
if ERRORLEVEL 1 goto Error

set /p VERSION=< version.txt
if ERRORLEVEL 1 goto Error

echo "CHANGING POM VERSION TO %VERSION%"

call mvn versions:set -DnewVersion=%VERSION%
if ERRORLEVEL 1 goto Error

echo "ACCEPTING POM VERSION TO %VERSION%"

call mvn versions:commit
if ERRORLEVEL 1 goto Error

echo "APPLYING NEW VERSION TO AssemblyInfo.cs %VERSION%"

call mvn dotnet:version
if ERRORLEVEL 1 goto Error

echo "COMMITTING RELEASE %VERSION%"

git commit -a -m "[RELEASE] - released version %VERSION%"
if ERRORLEVEL 1 goto Error

echo "TAGGING RELEASE %VERSION%"

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

echo "PUBLISHING RELEASE %LATEST_TAG%"

release.bat %LATEST_TAG%

goto:eof

:Error
echo Error. Verify Console Output.
EXIT /B 1

goto:eof
EXIT /B 0

