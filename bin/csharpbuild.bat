@ECHO OFF

SETLOCAL ENABLEEXTENSIONS

REM ---- PRINT CURRENT FOLDER ----

SET CURRENT_FOLDER=%CD%
ECHO CURRENT FOLDER = %CURRENT_FOLDER%

REM ---- VARIABLES ----

SET PROJECT_FOLDER=%CURRENT_FOLDER%
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
	
    ECHO "CLONING TAG INTO RELEASE_FOLDER %RELEASE_FOLDER%"

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

    ECHO "REMOVING -SNAPSHOT QUALIFIER FROM %VERSION_FILE%"

    CALL mvn dotnet:release
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    SET /p VERSION=< %VERSION_FILE%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    ECHO "CHANGING POM VERSION TO %VERSION%"

    CALL mvn versions:set -DnewVersion=%VERSION%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    ECHO "ACCEPTING POM VERSION TO %VERSION%"

    CALL mvn versions:commit
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    ECHO "APPLYING NEW VERSION TO AssemblyInfo.cs %VERSION%"

    CALL mvn dotnet:version
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    ECHO "COMMITTING RELEASE %VERSION%"

    git commit -a -m "[RELEASE] - released version %VERSION%"
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    ECHO "TAGGING RELEASE %VERSION%"

    git tag --file=%VERSION_FILE% %VERSION%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    SET LATEST_TAG=%VERSION%

    CALL mvn dotnet:next
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    SET /p VERSION=< %VERSION_FILE%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    CALL mvn versions:set -DnewVersion=%VERSION%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    CALL mvn versions:commit
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    CALL mvn dotnet:version
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    git commit -a -m "[RELEASE] - new development version set to %VERSION%"
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    git push --all --follow-tags
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    ECHO "PUBLISHING RELEASE %LATEST_TAG%"

    git clone --branch %1 %REPO%/%PROJECTNAME%.git target   
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    cd target
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    msbuild /t:Rebuild /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    iscc.exe buildsetup.iss
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    nuget pack %PROJECTNAME%.csproj
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    SET /p VERSION=< %VERSION_FILE%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    VERIFY OTHER 2>nul
    SETLOCAL ENABLEEXTENSIONS
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    IF DEFINED NUGET_SOURCE_URL (
        ECHO NUGET_SOURCE_URL IS defined
    ) ELSE (
        ECHO NUGET_SOURCE_URL is NOT defined
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )
    ENDLOCAL

    nuget push %PROJECTNAME%.%VERSION%.nupkg -source %NUGET_SOURCE_URL%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    scp dist/*.exe %USERNAME%@%WEBSERVER%:/var/www/html/releases
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
