@echo off
echo usage Examples
echo iwant c# MyExecutable Com.Company.MySuite v4.5 WinExe 1.0.0.0 -SNAPSHOT
echo iwant c# MyLibrary Com.Company.MySuite v4.5 Library 1.0.0.0 -SNAPSHOT

set TEMPLATE=%1
set NAME=%2
set PACKAGE=%3
set VERSION=%4
set TYPE=%5
set ASSEMBLYVERSION=%6
set ASSEMBLYVERSIONQUALIFIER=%7

Uuidgen.exe>tmp
set /p PROJECTGUID=<tmp
rm tmp

Uuidgen.exe>tmp
set /p COMGUID=<tmp
rm tmp

set TEMPLATEDIR=templates\%TEMPLATE%
set FOLDER=%NAME%
echo using template %TEMPLATE%
echo using folder %FOLDER%
echo using name %NAME%
echo using package %PACKAGE%
echo using version %VERSION%
echo using type %TYPE%
echo using project guid %PROJECTGUID%
echo using COM guid %COMGUID%
echo using assembly version %ASSEMBLYVERSION%
echo using assembly version qualifier %ASSEMBLYVERSIONQUALIFIER%

rmdir /Q /S %FOLDER%

md %FOLDER%

xcopy /E /Y /Q %TEMPLATEDIR% %FOLDER%

echo s/${AssemblyName}/%NAME%/ > tmp
echo s/${RootNamespace}/%PACKAGE%/ >> tmp
echo s/${TargetFrameworkVersion}/%VERSION%/ >> tmp
echo s/${OutputType}/%TYPE%/ >> tmp
echo s/${ProjectGuid}/%PROJECTGUID%/ >> tmp
echo s/${ComGuid}/%COMGUID%/ >> tmp
echo s/${AssemblyVersion}/%ASSEMBLYVERSION%/ >> tmp
echo s/${AssemblyVersionQualifier}/%ASSEMBLYVERSIONQUALIFIER%/ >> tmp

sed.exe -f tmp %FOLDER%\App.csproj>%FOLDER%\%PACKAGE%.%NAME%.csproj
sed.exe -f tmp %FOLDER%\App.cs>%FOLDER%\%NAME%.cs
sed.exe -f tmp %FOLDER%\Properties\AssemblyInfo.cstemplate>%FOLDER%\Properties\AssemblyInfo.cs
sed.exe -f tmp %FOLDER%\pom.xmltemplate>%FOLDER%\pom.xml

del /Q tmp
del /Q %FOLDER%\App.csproj
del /Q %FOLDER%\App.cs
del /Q %FOLDER%\Properties\AssemblyInfo.cstemplate
del /Q %FOLDER%\pom.xmltemplate

dir %FOLDER%