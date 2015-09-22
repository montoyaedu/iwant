@echo off
echo usage Examples
echo iwant c# MyExecutable Com.Company.MySuite v4.0 WinExe 1.0.0.0 -SNAPSHOT
echo iwant c# MyLibrary Com.Company.MySuite v4.0 Library 1.0.0.0 -SNAPSHOT

set TEMPLATE=%1
set NAME=%2
set PACKAGE=%3
set VERSION=%4
set TYPE=%5
set ASSEMBLYVERSION=%6
set ASSEMBLYVERSIONQUALIFIER=%7
set ARTIFACTEXTENSION=%8

if "%TEMPLATE%"=="" set TEMPLATE=c#
if "%NAME%"=="" set NAME=MyApp
if "%PACKAGE%"=="" set PACKAGE=MyPackage
if "%VERSION%"=="" set VERSION=v4.0
if "%TYPE%"=="" set TYPE=Exe
if "%ASSEMBLYVERSION%"=="" set ASSEMBLYVERSION=1.0.0.0
if "%ASSEMBLYVERSIONQUALIFIER%"=="" set ASSEMBLYVERSIONQUALIFIER=-SNAPSHOT
if "%ARTIFACTEXTENSION%"=="" set ARTIFACTEXTENSION=exe

Uuidgen.exe>tmp
set /p PROJECTGUID=<tmp
rm tmp

Uuidgen.exe>tmp
set /p COMGUID=<tmp
rm tmp

Uuidgen.exe>tmp
set /p SOLUTIONGUID=<tmp
rm tmp

set TEMPLATEDIR=templates\%TEMPLATE%
set PROJECTNAME=%PACKAGE%.%NAME%
set FOLDER=%PROJECTNAME%

echo using template %TEMPLATE%
echo using folder %FOLDER%
echo using name %NAME%
echo using package %PACKAGE%
echo using version %VERSION%
echo using type %TYPE%
echo using project guid %PROJECTGUID%
echo using COM guid %COMGUID%
echo using solution guid %SOLUTIONGUID%
echo using assembly version %ASSEMBLYVERSION%
echo using assembly version qualifier %ASSEMBLYVERSIONQUALIFIER%
echo using artifact extension %ARTIFACTEXTENSION%

rmdir /Q /S %FOLDER%

md %FOLDER%

xcopy /E /Y /Q %TEMPLATEDIR% %FOLDER%

echo s/${AssemblyName}/%NAME%/ > tmp
echo s/${RootNamespace}/%PACKAGE%/ >> tmp
echo s/${TargetFrameworkVersion}/%VERSION%/ >> tmp
echo s/${OutputType}/%TYPE%/ >> tmp
echo s/${ArtifactExtension}/%ARTIFACTEXTENSION%/ >> tmp
echo s/${ProjectName}/%PROJECTNAME%/ >> tmp
echo s/${ProjectGuid}/%PROJECTGUID%/ >> tmp
echo s/${ComGuid}/%COMGUID%/ >> tmp
echo s/${SolutionGuid}/%SOLUTIONGUID%/ >> tmp
echo s/${AssemblyVersion}/%ASSEMBLYVERSION%/ >> tmp
echo s/${AssemblyVersionQualifier}/%ASSEMBLYVERSIONQUALIFIER%/ >> tmp

sed.exe -f tmp %FOLDER%\App_vs2010.sln>%FOLDER%\%PROJECTNAME%_vs2010.sln
sed.exe -f tmp %FOLDER%\App.csproj>%FOLDER%\%PROJECTNAME%.csproj
sed.exe -f tmp %FOLDER%\App.cs>%FOLDER%\%NAME%.cs
sed.exe -f tmp %FOLDER%\Properties\AssemblyInfo.cstemplate>%FOLDER%\Properties\AssemblyInfo.cs
sed.exe -f tmp %FOLDER%\pom.xmltemplate>%FOLDER%\pom.xml
sed.exe -f tmp %FOLDER%\version.txttemplate>%FOLDER%\version.txt
sed.exe -f tmp %FOLDER%\buildsetup.isstemplate>%FOLDER%\buildsetup.iss
sed.exe -f tmp %FOLDER%\release.template>%FOLDER%\release
sed.exe -f tmp %FOLDER%\release.battemplate>%FOLDER%\release.bat

copy %FOLDER%\app_%VERSION%.configtemplate %FOLDER%\app.config

del /Q tmp
del /Q %FOLDER%\App_vs2010.sln
del /Q %FOLDER%\App.csproj
del /Q %FOLDER%\App.cs
del /Q %FOLDER%\Properties\AssemblyInfo.cstemplate
del /Q %FOLDER%\pom.xmltemplate
del /Q %FOLDER%\*.configtemplate
del /Q %FOLDER%\version.txttemplate
del /Q %FOLDER%\buildsetup.isstemplate
del /Q %FOLDER%\release.template
del /Q %FOLDER%\release.battemplate


dir %FOLDER%
