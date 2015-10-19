@ECHO OFF

SETLOCAL ENABLEEXTENSIONS

REM ---- A SIMPLE MAP FOR ERROR DESCRIPTION LOOKUP ----

SET /A errno=0

SET /A ERROR_NOERROR=0
SET /A ERROR_READING_VERSION=1
SET /A ERROR_BEGIN_SONARQUBE_RUNNER=2
SET /A ERROR_BUILD=3
SET /A ERROR_OPENCOVER=4
SET /A ERROR_END_SONARQUBE_RUNNER=5

SET /A ERROR_IWANT_PROJECT_FOLDER_DOES_NOT_EXIST=100


SET /A ERROR_UNCATEGORIZED=255

SET errormap=^
%ERROR_NOERROR%-"No errors";^
%ERROR_READING_VERSION%-"Error reading version file";^
%ERROR_IWANT_PROJECT_FOLDER_DOES_NOT_EXIST%-"IWANT PROJECT FOLDER .iwant DOES NOT EXIST";^
%ERROR_UNCATEGORIZED%-"Generic Error"

ECHO "CURRENT FOLDER = %CD%"

SET IWANT_PROJECT_FOLDER=.iwant
SET VERSION_FILE=version.txt
SET PROJECTNAME_FILE=%IWANT_PROJECT_FOLDER%/projectname.txt
SET REPOSITORY_FILE=%IWANT_PROJECT_FOLDER%/repository.txt

IF NOT EXIST %IWANT_PROJECT_FOLDER% (
    SET /A errno^|=%ERROR_IWANT_PROJECT_FOLDER_DOES_NOT_EXIST%
    GOTO END
)

IF NOT EXIST %VERSION_FILE% (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
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
	ECHO "VERSION = %VERSION%"
)

SET /p PN=< PROJECTNAME_FILE
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
    GOTO END
) ELSE (
	ECHO "PROJECT NAME = %PN%"
)

SET /p REPO=< REPOSITORY_FILE
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
    GOTO END
) ELSE (
	ECHO "REPO = %REPO%"
)

MSBuild.SonarQube.Runner.exe begin /k:"%PN%" /n:"%PN%" /v:"%VERSION%" /d:sonar.cs.nunit.reportsPaths="%CD%\TestResult.xml" /d:sonar.cs.opencover.reportsPaths="%CD%\opencover.xml"
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_BEGIN_SONARQUBE_RUNNER%
    GOTO END
)

nuget restore
if ERRORLEVEL 1 goto Error

msbuild /t:Rebuild /p:Configuration=Debug %PN%_vs2010.sln
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_BUILD%
    GOTO END
)

OpenCover.Console.exe -target:"%NUNIT_HOME%\bin\nunit-console-x86.exe" -targetargs:"/nologo /noshadow %CD%\bin\Debug\%PN%.dll" -output:"%CD%\opencover.xml" -register:user
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
if ERRORLEVEL 1 goto Error

FOR /F %%I IN ('git log -n 1 "--format=%%ce"') DO SET LAST_COMMITTER_EMAIL=%%I
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
    GOTO END
)

FOR /F %%I IN ('git log -n 1 "--format=%%f"') DO SET LAST_SUBJECT=%%I
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_UNCATEGORIZED%
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

    git clone --branch %LAST_CURRENT_BRANCH% %REPO%/%PN%.git %RELEASE_FOLDER%
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

git clone --branch %1 %REPO%/%PN%.git target   
if ERRORLEVEL 1 goto Error

cd target                                                                       
if ERRORLEVEL 1 goto Error

msbuild /t:Rebuild /p:Configuration=Debug %PN%_vs2010.sln
if ERRORLEVEL 1 goto Error

iscc.exe buildsetup.iss
if ERRORLEVEL 1 goto Error

nuget pack %PN%.csproj
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

nuget push %PN%.%VERSION%.nupkg -source %NUGET_SOURCE_URL%
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

