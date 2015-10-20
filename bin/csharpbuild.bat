@ECHO OFF

CLS

@CALL :LOG "Starting build..."

SETLOCAL ENABLEEXTENSIONS

REM ---- PRINT CURRENT FOLDER ----

SET CURRENT_FOLDER=%CD%

REM ---- VARIABLES ----

SET PROJECT_FOLDER=%CURRENT_FOLDER%
SET VERSION_FILE=%PROJECT_FOLDER%\version.txt
SET PROJECTNAME_FILE=%PROJECT_FOLDER%\projectname.txt
SET REPOSITORY_FILE=%PROJECT_FOLDER%\repository.txt

REM ---- ECHOING VARIABLES ----

@CALL :LOG "CURRENT_FOLDER=%CURRENT_FOLDER%"
@CALL :LOG "VERSION_FILE=%VERSION_FILE%"
@CALL :LOG "PROJECTNAME_FILE=%PROJECTNAME_FILE%"
@CALL :LOG "REPOSITORY_FILE=%REPOSITORY_FILE%"

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

SET /A ERROR_PROJECT_FOLDER_DOES_NOT_EXIST=100
SET /A ERROR_VERSION_FILE_DOES_NOT_EXIST=101
SET /A ERROR_PROJECTNAME_FILE_DOES_NOT_EXIST=102
SET /A ERROR_REPOSITORY_FILE_DOES_NOT_EXIST=103
SET /A ERROR_SOLUTION_FILE_DOES_NOT_EXIST=104

SET /A ERROR_READING_VERSION=104
SET /A ERROR_READING_PROJECTNAME=105
SET /A ERROR_READING_REPOSITORY=106

SET /A ERROR_UNCATEGORIZED=255

SET errormap=^
%ERROR_NOERROR%-"No errors";^
%ERROR_BUILD%-"Error building project";^
%ERROR_PROJECT_FOLDER_DOES_NOT_EXIST%-"Folder %PROJECT_FOLDER% does not exist";^
%ERROR_VERSION_FILE_DOES_NOT_EXIST%-"File %VERSION_FILE% does not exist";^
%ERROR_PROJECTNAME_FILE_DOES_NOT_EXIST%-"File %PROJECTNAME_FILE% does not exist";^
%ERROR_REPOSITORY_FILE_DOES_NOT_EXIST%-"File %REPOSITORY_FILE% does not exist";^
%ERROR_SOLUTION_FILE_DOES_NOT_EXIST%-"Solution file does not exist";^
%ERROR_READING_VERSION%-"Error reading %VERSION_FILE% file";^
%ERROR_READING_PROJECTNAME%-"Error reading %PROJECTNAME_FILE% file";^
%ERROR_READING_REPOSITORY%-"Error reading %REPOSITORY_FILE% file";^
%ERROR_UNCATEGORIZED%-"Generic Error"

@CALL :LOG "VALIDATING FILESYSTEM STRUCTURE..."

@CALL :LOG "VERIFYING PROJECT_FOLDER %PROJECT_FOLDER%"
IF NOT EXIST %PROJECT_FOLDER% (
    SET /A errno^|=%ERROR_PROJECT_FOLDER_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG "VERIFYING VERSION_FILE %VERSION_FILE%"
IF NOT EXIST %VERSION_FILE% (
    SET /A errno^|=%ERROR_VERSION_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG "VERIFYING PROJECTNAME_FILE %PROJECTNAME_FILE%"
IF NOT EXIST %PROJECTNAME_FILE% (
    SET /A errno^|=%ERROR_PROJECTNAME_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG "VERIFYING REPOSITORY_FILE %REPOSITORY_FILE%"
IF NOT EXIST %REPOSITORY_FILE% (
    SET /A errno^|=%ERROR_REPOSITORY_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG "VERIFYING VERSION_FILE CONTENT %VERSION_FILE%"
SET /p VERSION=< %VERSION_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_VERSION%
    GOTO END
) ELSE (
    @CALL :LOG "VERSION = %VERSION%"
)

@CALL :LOG "VERIFYING PROJECTNAME_FILE CONTENT %PROJECTNAME_FILE%"
SET /p PROJECTNAME=< %PROJECTNAME_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_PROJECTNAME%
    GOTO END
) ELSE (
	@CALL :LOG "PROJECT NAME = %PROJECTNAME%"
)

@CALL :LOG "VERIFYING REPOSITORY_FILE CONTENT %REPOSITORY_FILE%"
SET /p REPO=< %REPOSITORY_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_REPOSITORY%
    GOTO END
) ELSE (
	@CALL :LOG "REPO = %REPO%"
)

SET SOLUTION_FILE=%PROJECTNAME%_vs2010.sln
IF NOT EXIST %SOLUTION_FILE% (
	@CALL :LOG_ERROR "Solution file does not exist %SOLUTION_FILE%"
    SET /A errno^|=%ERROR_SOLUTION_FILE_DOES_NOT_EXIST%
    GOTO END
)

nuget restore %SOLUTION_FILE% -verbosity quiet
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_NUGET_RESTORE%
    GOTO END
)

@CALL :LOG "Remove bin folder..."
rm -fr bin

@CALL :LOG "Remove obj folder..."
rm -fr obj

@CALL :LOG "Remove target folder..."
rm -fr target

@CALL :LOG "Begin SonarQube Runner..."
MSBuild.SonarQube.Runner.exe begin /k:"%PROJECTNAME%" /n:"%PROJECTNAME%" /v:"%VERSION%" /d:sonar.cs.nunit.reportsPaths="%CD%\TestResult.xml" /d:sonar.cs.opencover.reportsPaths="%CD%\opencover.xml" > SonarQubeBeginOut.txt
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_BEGIN_SONARQUBE_RUNNER%
    GOTO END
)

@CALL :LOG "Begin Build..."
msbuild /nologo /noconsolelogger /m /t:Rebuild /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_BUILD%
    GOTO END
)

OpenCover.Console.exe -target:"%NUNIT_HOME%\bin\nunit-console-x86.exe" -targetargs:"/nologo /trace:Off /out:TestResultOut.txt /err:TestResultErr.txt /noshadow %CD%\bin\Debug\%PROJECTNAME%.dll" -output:"%CD%\opencover.xml" -register:user -log:Off
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_OPENCOVER%
    GOTO END
)

MSBuild.SonarQube.Runner.exe end > SonarQubeEndOut.txt
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_END_SONARQUBE_RUNNER%
    GOTO END
)

iscc.exe /Q buildsetup.iss
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

@CALL :LOG "LAST_SUBJECT = %LAST_SUBJECT%"
SET RELEASE_FOLDER="releaseFolder"
@CALL :LOG "RELEASE FOLDER = %RELEASE_FOLDER%"

IF "%LAST_SUBJECT%" == "please-release" (
    @CALL :LOG "MAKING RELEASE"

    IF EXIST %RELEASE_FOLDER% (
        rm -fr %RELEASE_FOLDER%
        IF %ERRORLEVEL% NEQ 0 (
            SET /A errno^|=%ERROR_UNCATEGORIZED%
            GOTO END
        )
    )
	
    @CALL :LOG "CLONING TAG INTO RELEASE_FOLDER %RELEASE_FOLDER%"

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

    @CALL :LOG "REMOVING -SNAPSHOT QUALIFIER FROM %VERSION_FILE%"

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

    @CALL :LOG "CHANGING POM VERSION TO %VERSION%"

    CALL mvn versions:set -DnewVersion=%VERSION%
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG "ACCEPTING POM VERSION TO %VERSION%"

    CALL mvn versions:commit
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG "APPLYING NEW VERSION TO AssemblyInfo.cs %VERSION%"

    CALL mvn dotnet:version
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG "COMMITTING RELEASE %VERSION%"

    git commit -a -m "[RELEASE] - released version %VERSION%"
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG "TAGGING RELEASE %VERSION%"

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

    @CALL :LOG "PUBLISHING RELEASE %LATEST_TAG%"

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

    msbuild /nologo /noconsolelogger /m /t:Rebuild /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    iscc.exe /Q buildsetup.iss
    IF %ERRORLEVEL% NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    nuget -verbosity quiet pack %PROJECTNAME%.csproj
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
        @CALL :LOG "NUGET_SOURCE_URL is defined as %NUGET_SOURCE_URL%"
    ) ELSE (
        @CALL :LOG_ERROR "NUGET_SOURCE_URL is not defined"
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )
    ENDLOCAL

    nuget -verbosity quiet push %PROJECTNAME%.%VERSION%.nupkg -source %NUGET_SOURCE_URL%
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
    @CALL :LOG "NOT MAKING RELEASE"
)

:END
@CALL :LOG "EXIT CODE = %errno%"

CALL SET errordesc=%%errormap:*%errno%-=%%
SET errordesc=%errordesc:;=&rem.%
ECHO %errordesc%
@CALL :LOG "EXIT CODE DESCRIPTION = .%errordesc%"

EXIT /B %errno%

:LOG
  @ECHO %DATE% %TIME% : [INFO ] - %~1
  @EXIT /b
  
:LOG_ERROR
  @ECHO %DATE% %TIME% : [ERROR] - %~1
  @EXIT /b