@ECHO OFF

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

@CALL :LOG Starting build...

@CALL :EXEC_CMD git fetch --all
IF %ERRORLEVEL% NEQ 0 (
	SET /A errno^|=%ERROR_UNCATEGORIZED%
	GOTO END
)

@CALL :EXEC_CMD git pull
IF %ERRORLEVEL% NEQ 0 (
	SET /A errno^|=%ERROR_UNCATEGORIZED%
	GOTO END
)

REM ---- PRINT CURRENT FOLDER ----

SET CURRENT_FOLDER=%CD%

REM ---- VARIABLES ----

SET PROJECT_FOLDER=%CURRENT_FOLDER%
SET VERSION_FILE=%PROJECT_FOLDER%\version.txt
SET PROJECTNAME_FILE=%PROJECT_FOLDER%\projectname.txt
SET REPOSITORY_FILE=%PROJECT_FOLDER%\repository.txt
SET WEBSERVER_FILE=%PROJECT_FOLDER%\webserver.txt

REM ---- ECHOING VARIABLES ----

@CALL :LOG CURRENT_FOLDER=%CURRENT_FOLDER%
@CALL :LOG VERSION_FILE=%VERSION_FILE%
@CALL :LOG PROJECTNAME_FILE=%PROJECTNAME_FILE%
@CALL :LOG REPOSITORY_FILE=%REPOSITORY_FILE%
@CALL :LOG WEBSERVER_FILE=%WEBSERVER_FILE%

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
SET /A ERROR_WEBSERVER_FILE_DOES_NOT_EXIST=105

SET /A ERROR_READING_VERSION=120
SET /A ERROR_READING_PROJECTNAME=121
SET /A ERROR_READING_REPOSITORY=122
SET /A ERROR_READING_WEBSERVER=123

SET /A ERROR_SCM_CHECKOUT=130

SET /A ERROR_UNCATEGORIZED=255

SET errormap=^
%ERROR_NOERROR%-"No errors";^
%ERROR_BUILD%-"Error building project";^
%ERROR_PROJECT_FOLDER_DOES_NOT_EXIST%-"Folder %PROJECT_FOLDER% does not exist";^
%ERROR_VERSION_FILE_DOES_NOT_EXIST%-"File %VERSION_FILE% does not exist";^
%ERROR_PROJECTNAME_FILE_DOES_NOT_EXIST%-"File %PROJECTNAME_FILE% does not exist";^
%ERROR_REPOSITORY_FILE_DOES_NOT_EXIST%-"File %REPOSITORY_FILE% does not exist";^
%ERROR_SOLUTION_FILE_DOES_NOT_EXIST%-"Solution file does not exist";^
%ERROR_WEBSERVER_FILE_DOES_NOT_EXIST%-"File %WEBSERVER_FILE% does not exist";^
%ERROR_READING_VERSION%-"Error reading %VERSION_FILE% file";^
%ERROR_READING_PROJECTNAME%-"Error reading %PROJECTNAME_FILE% file";^
%ERROR_READING_REPOSITORY%-"Error reading %REPOSITORY_FILE% file";^
%ERROR_READING_WEBSERVER%-"Error reading %WEBSERVER_FILE% file";^
%ERROR_SCM_CHECKOUT%-"Error checking out project from SCM";^
%ERROR_UNCATEGORIZED%-"Generic Error"

:loop
IF NOT "%1"=="" (
	IF "%1"=="--force" (
		SET FORCE=%1
	)
	IF "%1"=="--platform" (
		SET PLATFORM=%2
		SHIFT
	)
	SHIFT
	GOTO :loop
)

@CALL :LOG VALIDATING FILESYSTEM STRUCTURE...

@CALL :LOG VERIFYING PROJECT_FOLDER %PROJECT_FOLDER%
IF NOT EXIST %PROJECT_FOLDER% (
    SET /A errno^|=%ERROR_PROJECT_FOLDER_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG VERIFYING VERSION_FILE %VERSION_FILE%
IF NOT EXIST %VERSION_FILE% (
    SET /A errno^|=%ERROR_VERSION_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG VERIFYING PROJECTNAME_FILE %PROJECTNAME_FILE%
IF NOT EXIST %PROJECTNAME_FILE% (
    SET /A errno^|=%ERROR_PROJECTNAME_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG VERIFYING REPOSITORY_FILE %REPOSITORY_FILE%
IF NOT EXIST %REPOSITORY_FILE% (
    SET /A errno^|=%ERROR_REPOSITORY_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG VERIFYING WEBSERVER_FILE %WEBSERVER_FILE%
IF NOT EXIST %WEBSERVER_FILE% (
    SET /A errno^|=%ERROR_WEBSERVER_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :LOG VERIFYING VERSION_FILE CONTENT %VERSION_FILE%
SET /p VERSION=< %VERSION_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_VERSION%
    GOTO END
) ELSE (
    @CALL :LOG VERSION = %VERSION%
)

@CALL :LOG VERIFYING PROJECTNAME_FILE CONTENT %PROJECTNAME_FILE%
SET /p PROJECTNAME=< %PROJECTNAME_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_PROJECTNAME%
    GOTO END
) ELSE (
	@CALL :LOG PROJECT NAME = %PROJECTNAME%
)

@CALL :LOG VERIFYING REPOSITORY_FILE CONTENT %REPOSITORY_FILE%
SET /p REPO=< %REPOSITORY_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_REPOSITORY%
    GOTO END
) ELSE (
	@CALL :LOG REPO = %REPO%
)

@CALL :LOG VERIFYING WEBSERVER_FILE CONTENT %WEBSERVER_FILE%
SET /p WEBSERVER=< %WEBSERVER_FILE%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_READING_WEBSERVER%
    GOTO END
) ELSE (
	@CALL :LOG WEBSERVER = %WEBSERVER%
)


SET SOLUTION_FILE=%PROJECTNAME%_vs2010.sln
IF NOT EXIST %SOLUTION_FILE% (
	@CALL :LOG_ERROR Solution file does not exist %SOLUTION_FILE%
    SET /A errno^|=%ERROR_SOLUTION_FILE_DOES_NOT_EXIST%
    GOTO END
)

@CALL :EXEC_CMD nuget restore %SOLUTION_FILE% -verbosity quiet
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_NUGET_RESTORE%
    GOTO END
)

@CALL :EXEC_BUILDONLY %VERSION%
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_BUILD%
    GOTO END
)

FOR /F %%I IN ('git log -n 1 "--format=%%ce"') DO SET LAST_COMMITTER_EMAIL=%%I
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_GIT_LOG_ACQUIRE_LAST_COMMITTER%
    GOTO END
)

FOR /F "tokens=*" %%I IN ('git log -n 1 "--format=%%s"') DO SET LAST_SUBJECT=%%I
IF %ERRORLEVEL% NEQ 0 (
    SET /A errno^|=%ERROR_GIT_LOG_ACQUIRE_LAST_COMMIT_MESSAGE%
    GOTO END
)

IF "%GIT_BRANCH%" == "" (
	@CALL :LOG environment variable GIT_BRANCH is not set. assuming origin/master
	SET GIT_BRANCH=origin/master
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

@CALL :LOG LAST_SUBJECT = %LAST_SUBJECT%

@CALL :LOG LOOK FOR RELEASE...
ECHO %LAST_SUBJECT% | findstr "RELEASE" > NUL
IF %ERRORLEVEL% NEQ 0 (
    @CALL :LOG RELEASE NOT FOUND...
	SET LAST_SUBJECT=please-release
) ELSE (
    @CALL :LOG RELEASE FOUND...
	SET LAST_SUBJECT=do-not-release
)

IF "%FORCE%" == "--force" (
	SET LAST_SUBJECT=please-release
)

@CALL :LOG LAST_SUBJECT = %LAST_SUBJECT%

IF "%LAST_SUBJECT%" == "please-release" (
    @CALL :LOG MAKING RELEASE
	@CALL :EXEC_CMD git clone --quiet --branch %LAST_CURRENT_BRANCH% %REPO%/%PROJECTNAME%.git %RELEASE_FOLDER%
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_SCM_CHECKOUT%
        GOTO END
    )

    @CALL :LOG VERIFYING RELEASE_FOLDER %RELEASE_FOLDER%
    IF NOT EXIST %RELEASE_FOLDER% (
	    SET /A errno^|=%ERROR_SCM_CHECKOUT%
	    GOTO END
    )
	
	PUSHD %RELEASE_FOLDER%
	
	SET VERSION_FILE=%PROJECT_FOLDER%\%RELEASE_FOLDER%\version.txt
	
	CALL :LOG NEW VERSION FILE IS !VERSION_FILE!
	
    @CALL :LOG REMOVING -SNAPSHOT QUALIFIER FROM !VERSION_FILE!
    @CALL :EXEC_MVN dotnet:release
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )
	
    SET /P VERSION=< !VERSION_FILE!

    @CALL :LOG CHANGING POM VERSION TO !VERSION!

    @CALL :EXEC_MVN versions:set -DnewVersion=!VERSION!
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG ACCEPTING POM VERSION TO !VERSION!

    @CALL :EXEC_MVN versions:commit
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG APPLYING NEW VERSION TO AssemblyInfo.cs !VERSION!

    @CALL :EXEC_MVN dotnet:version
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG COMMITTING RELEASE !VERSION!

    @CALL :EXEC_CMD git commit --quiet -a -m "[RELEASE] - released version !VERSION!"
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG TAGGING RELEASE !VERSION!

    @CALL :EXEC_CMD git tag -a --file=!VERSION_FILE! !VERSION!
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    SET LATEST_TAG=!VERSION!

    @CALL :EXEC_MVN dotnet:next
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    SET /P VERSION=< !VERSION_FILE!
	
	@CALL :LOG NEW DEVELOPMENT VERSION !VERSION!

    @CALL :EXEC_MVN versions:set -DnewVersion=!VERSION!
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG ACCEPTING POM VERSION TO !VERSION!

    @CALL :EXEC_MVN versions:commit
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG APPLYING NEW VERSION TO AssemblyInfo.cs !VERSION!

    @CALL :EXEC_MVN dotnet:version
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG COMMITTING RELEASE !VERSION!

    @CALL :EXEC_CMD git commit --quiet -a -m "[RELEASE] - new development version set to !VERSION!"
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :EXEC_CMD git push --quiet --all --follow-tags
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :LOG "PUBLISHING RELEASE !LATEST_TAG!"

    @CALL :EXEC_GIT clone --quiet --branch !LATEST_TAG! %REPO%/%PROJECTNAME%.git target
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

	PUSHD target
	
	SET VERSION_FILE=%PROJECT_FOLDER%\%RELEASE_FOLDER%\target\version.txt
	
	CALL :LOG NEW VERSION FILE IS !VERSION_FILE!
	
    SET /p VERSION=< !VERSION_FILE!

	CALL :LOG NEW VERSION IS !VERSION!

	@CALL :EXEC_CMD nuget restore -verbosity quiet
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

	IF "%PLATFORM%"=="" (
        @CALL :EXEC_CMD msbuild /nologo /noconsolelogger /m /t:Rebuild /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
		IF !ERRORLEVEL! NEQ 0 (
			SET /A errno^|=%ERROR_UNCATEGORIZED%
			GOTO END
		)
	) ELSE (
        @CALL :EXEC_CMD msbuild /nologo /noconsolelogger /m /t:Rebuild /p:Platform=%PLATFORM% /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
		IF !ERRORLEVEL! NEQ 0 (
			SET /A errno^|=%ERROR_UNCATEGORIZED%
			GOTO END
		)
	)

    @CALL :EXEC_CMD iscc.exe /Q buildsetup.iss
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :EXEC_CMD nuget pack -verbosity quiet %PROJECTNAME%.csproj
    IF !ERRORLEVEL! NEQ 0 (
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

    @CALL :EXEC_CMD nuget push -verbosity quiet %PROJECTNAME%.!VERSION!.nupkg -source %NUGET_SOURCE_URL%
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )

    @CALL :EXEC_CMD scp -q dist/*.exe %USERNAME%@%WEBSERVER%:/var/www/html/releases
    IF !ERRORLEVEL! NEQ 0 (
        SET /A errno^|=%ERROR_UNCATEGORIZED%
        GOTO END
    )
	POPD
	POPD
	
	@CALL :EXEC_CMD git fetch --all
	IF !ERRORLEVEL! NEQ 0 (
		SET /A errno^|=%ERROR_UNCATEGORIZED%
		GOTO END
	)

	@CALL :EXEC_CMD git pull
	IF !ERRORLEVEL! NEQ 0 (
		SET /A errno^|=%ERROR_UNCATEGORIZED%
		GOTO END
	)
	
	SET VERSION_FILE=%PROJECT_FOLDER%\version.txt
	
	CALL :LOG NEW VERSION FILE IS !VERSION_FILE!
	
    SET /p VERSION=< !VERSION_FILE!

	CALL :LOG NEW VERSION IS !VERSION!
	
	@CALL :EXEC_BUILDONLY !VERSION!
	IF !ERRORLEVEL! NEQ 0 (
		SET /A errno^|=%ERROR_BUILD%
		GOTO END
	)
	
) ELSE (
    @CALL :LOG NOT MAKING RELEASE
)

@CALL :LOG "FINISHING..."

:END
@CALL :LOG "EXIT CODE = %errno%"

CALL SET errordesc=%%errormap:*%errno%-=%%
SET errordesc=%errordesc:;=&rem.%
@CALL :LOG EXIT CODE DESCRIPTION = %errordesc%

EXIT /B %errno%

:LOG
  @ECHO %DATE% %TIME% : [INFO ] - %*
  GOTO :EOF
  
:LOG_ERROR
  @ECHO %DATE% %TIME% : [ERROR] - %*
  GOTO :EOF

:EXEC_CMD
  @CALL :LOG %*
  @CALL %* >NUL 2>NUL
  @CALL :LOG %* ERRORLEVEL=!ERRORLEVEL!
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )
  EXIT /B 0
  
:EXEC_MVN
  @CALL :LOG mvn %*
  @CALL mvn --batch-mode %* >NUL 2>NUL
  @CALL :LOG mvn %* ERRORLEVEL=!ERRORLEVEL!
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )
  EXIT /B 0
  
:EXEC_GIT
  @CALL :LOG git %*
  @CALL git %* >NUL 2>NUL
  @CALL :LOG git %* ERRORLEVEL=!ERRORLEVEL!
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )
  EXIT /B 0

:EXEC_BUILDONLY

  @CALL :EXEC_CLEAN
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  @CALL :EXEC_CMD MSBuild.SonarQube.Runner.exe begin /k:"%PROJECTNAME%" /n:"%PROJECTNAME%" /v:"%1" /d:sonar.cs.nunit.reportsPaths="%CD%\TestResult.xml" /d:sonar.cs.opencover.reportsPaths="%CD%\opencover.xml"
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  
  IF "%PLATFORM%"=="" (
	@CALL :EXEC_CMD msbuild /nologo /noconsolelogger /m /t:Rebuild /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
	  IF !ERRORLEVEL! NEQ 0 (
		EXIT /B !ERRORLEVEL!
	  )
  ) ELSE (
	@CALL :EXEC_CMD msbuild /nologo /noconsolelogger /m /t:Rebuild /p:Platform=%PLATFORM% /p:Configuration=Debug %PROJECTNAME%_vs2010.sln
	  IF !ERRORLEVEL! NEQ 0 (
		EXIT /B !ERRORLEVEL!
	  )
  )

  @CALL :EXEC_CMD OpenCover.Console.exe -target:"%NUNIT_HOME%\bin\nunit-console-x86.exe" -targetargs:"/nologo /trace:Off /noshadow %CD%\bin\Debug\%PROJECTNAME%.dll" -output:"%CD%\opencover.xml" -register:user -log:Off
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  @CALL :EXEC_CMD MSBuild.SonarQube.Runner.exe end
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  @CALL :EXEC_CMD iscc.exe /Q buildsetup.iss
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )
  
  @CALL :EXEC_CLEAN
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )
  
  EXIT /B 0
  
:EXEC_CLEAN
  @CALL :LOG Remove bin folder...
  @CALL :EXEC_CMD rm -fr bin
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  @CALL :LOG Remove obj folder...
  @CALL :EXEC_CMD rm -fr obj
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  @CALL :LOG Remove target folder...
  @CALL :EXEC_CMD rm -fr target
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  @CALL :LOG Remove dist folder...
  @CALL :EXEC_CMD rm -fr dist
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )

  @CALL :LOG Remove *.nupkg folder...
  @CALL :EXEC_CMD rm -fr *.nupkg
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )
  
  SET RELEASE_FOLDER=releaseFolder
  @CALL :LOG RELEASE FOLDER = %RELEASE_FOLDER%

  @CALL :LOG Remove folder %RELEASE_FOLDER%...
  @CALL :EXEC_CMD rm -fr %RELEASE_FOLDER%
  IF !ERRORLEVEL! NEQ 0 (
    EXIT /B !ERRORLEVEL!
  )
  
  EXIT /B 0
