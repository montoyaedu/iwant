@ECHO OFF

SETLOCAL ENABLEEXTENSIONS

REM ---- PRINT CURRENT FOLDER ----

SET CURRENT_FOLDER=%CD%
ECHO CURRENT FOLDER = %CURRENT_FOLDER%

REM ---- VARIABLES ----

SET PROJECT_FOLDER=%CURRENT_FOLDER%\.iwant
SET VERSION_FILE=%PROJECT_FOLDER%\version.txt
SET PROJECTNAME_FILE=%PROJECT_FOLDER%\projectname.txt
SET REPOSITORY_FILE=%PROJECT_FOLDER%\repository.txt

REM ---- A SIMPLE MAP FOR ERROR DESCRIPTION LOOKUP ----

SET /A errno=0

SET /A ERROR_NOERROR=0
SET /A ERROR_BEGIN_SONARQUBE_RUNNER=2
SET /A ERROR_BUILD=3
SET /A ERROR_OPENCOVER=4
SET /A ERROR_END_SONARQUBE_RUNNER=5
SET /A ERROR_NUGET_RESTORE=6
SET /A ERROR_INNOSETUP=7
SET /A ERROR_GIT_LOG_ACQUIRE_LAST_COMMITTER=8
SET /A ERROR_GIT_LOG_ACQUIRE_LAST_COMMIT_MESSAGE=9

SET /A ERROR_IWANT_PROJECT_FOLDER_DOES_NOT_EXIST=100
SET /A ERROR_VERSION_FILE_DOES_NOT_EXIST=101
SET /A ERROR_PROJECTNAME_FILE_DOES_NOT_EXIST=102
SET /A ERROR_REPOSITORY_FILE_DOES_NOT_EXIST=103

SET /A ERROR_READING_VERSION=104
SET /A ERROR_READING_PROJECTNAME=105
SET /A ERROR_READING_REPOSITORY=106

SET /A ERROR_UNCATEGORIZED=255

SET errormap=^
%ERROR_NOERROR%-"No errors";^
%ERROR_PROJECT_FOLDER_DOES_NOT_EXIST%-"Folder %PROJECT_FOLDER% does not exist";^
%ERROR_VERSION_FILE_DOES_NOT_EXIST%-"File %VERSION_FILE% does not exist";^
%ERROR_PROJECTNAME_FILE_DOES_NOT_EXIST%-"File %PROJECTNAME_FILE% does not exist";^
%ERROR_REPOSITORY_FILE_DOES_NOT_EXIST%-"File %REPOSITORY_FILE% does not exist";^
%ERROR_READING_VERSION%-"Error reading %VERSION_FILE% file";^
%ERROR_READING_PROJECTNAME%-"Error reading %PROJECTNAME_FILE% file";^
%ERROR_READING_REPOSITORY%-"Error reading %REPOSITORY_FILE% file";^
%ERROR_UNCATEGORIZED%-"Generic Error"

IF NOT EXIST %IWANT_PROJECT_FOLDER% (
    SET /A errno^|=%ERROR_IWANT_PROJECT_FOLDER_DOES_NOT_EXIST%
    GOTO END
)

IF NOT EXIST %VERSION_FILE% (
    SET /A errno^|=%ERROR_VERSION_FILE_DOES_NOT_EXIST%
    GOTO END
)

IF NOT EXIST %PROJECTNAME_FILE% (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
    GOTO END
)

IF NOT EXIST %REPOSITORY_FILE% (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
    GOTO END
)

SET /p VERSION=< %VERSION_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_VERSION%
    GOTO END
) ELSE (
    ECHO VERSION = %VERSION%
)

SET /p PROJECTNAME=< %PROJECTNAME_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_PROJECTNAME%
    GOTO END
) ELSE (
	ECHO PROJECT NAME = %PROJECTNAME%
)

SET /p REPO=< %REPOSITORY_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_REPOSITORY%
    GOTO END
) ELSE (
	ECHO "REPO = %REPO%"
)

MSBuild.SonarQube.Runner.exe begin /k:"%PROJECTNAME%" /n:"%PROJECTNAME%" /v:"%VERSION%" /d:sonar.cs.nunit.reportsPaths="%CD%\TestResult.xml" /d:sonar.cs.opencover.reportsPaths="%CD%\opencover.xml"
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_BEGIN_SONARQUBE_RUNNER%
    GOTO END
)

nuget restore
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_NUGET_RESTORE%
    GOTO END
)

rm -fr bin
rm -fr obj
rm -fr target

msbuild /t:Rebuild /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_BUILD%
    GOTO END
)

OpenCover.Console.exe -target:"%NUNIT_HOME%\bin\nunit-console-x86.exe" -targetargs:"/nologo /noshadow %CD%\bin\Debug\%PROJECTNAME%.dll" -output:"%CD%\opencover.xml" -register:user
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_OPENCOVER%
    GOTO END
)

MSBuild.SonarQube.Runner.exe end
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_END_SONARQUBE_RUNNER%
    GOTO END
)

iscc.exe buildsetup.iss
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_INNOSETUP%
    GOTO END
)

FOR /F %%I IN ('git log -n 1 "--format=%%ce"') DO SET LAST_COMMITTER_EMAIL=%%I
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_GIT_LOG_ACQUIRE_LAST_COMMITTER%
    GOTO END
)

FOR /F %%I IN ('git log -n 1 "--format=%%f"') DO SET LAST_SUBJECT=%%I
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_GIT_LOG_ACQUIRE_LAST_COMMIT_MESSAGE%
    GOTO END
)

SET LAST_CURRENT_BRANCH=%GIT_BRANCH%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
    GOTO END
)

SET LAST_CURRENT_BRANCH=%GIT_BRANCH:origin/=%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
    GOTO END
)

ECHO "LAST_SUBJECT = %LAST_SUBJECT%"
SET RELEASE_FOLDER="releaseFolder"
ECHO "RELEASE FOLDER = %RELEASE_FOLDER%"

IF "%LAST_SUBJECT%" == "please-release" (
	ECHO "MAKING RELEASE"

    IF EXIST %RELEASE_FOLDER% (
        rm -fr %RELEASE_FOLDER%
        IF %ERRORLEVEL% NEQ 0 (
            SET /A errno^|=%ERROR_UNCATEGORIZED%
            GOTO END
        )
    )
	
	echo "CLONING TAG INTO RELEASE_FOLDER %RELEASE_FOLDER%"

    git clone --branch %LAST_CURRENT_BRANCH% %REPO%/%PROJECTNAME%.git %RELEASE_FOLDER%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    IF EXIST %RELEASE_FOLDER% (
    CD %RELEASE_FOLDER%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

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

git clone --branch %1 %REPO%/%PROJECTNAME%.git target   
if ERRORLEVEL 1 goto Error

cd target                                                                       
if ERRORLEVEL 1 goto Error

msbuild /t:Rebuild /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
if ERRORLEVEL 1 goto Error

iscc.exe buildsetup.iss
if ERRORLEVEL 1 goto Error

nuget pack %PROJECTNAME%.csproj
if ERRORLEVEL 1 goto Error

set /p VERSION=< version.txt
if ERRORLEVEL 1 goto Error

VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO Unable to enable extensions
IF DEFINED NUGET_SOURCE_URL (ECHO NUGET_SOURCE_URL IS defined) ELSE (
    ECHO NUGET_SOURCE_URL is NOT defined
    goto Error
)
ENDLOCAL

nuget push %PROJECTNAME%.%VERSION%.nupkg -source %NUGET_SOURCE_URL%
if ERRORLEVEL 1 goto Error

scp dist/*.exe %USERNAME%@192.168.1.20:/var/www/html/releases
if ERRORLEVEL 1 goto Error
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    rm -fr %RELEASE_FOLDER%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )
    ) ELSE (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )
) ELSE (
	ECHO "NOT MAKING RELEASE"
)

:END
ECHO EXIT CODE = %errno%

CALL SET errordesc=%%errormap:*%errno%-=%%
SET errordesc=%errordesc:;=&rem.%
ECHO.%errordesc%

EXIT /B %errno%

