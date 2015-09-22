#define MyAppName "${AssemblyName}"
#define MyAppVersion GetStringFileInfo('${ProjectName}\bin\Debug\${ProjectName}.${ArtifactExtension}', 'ProductVersion' )
#define MyAppPublisher "${PublisherName}"
#define MyAppURL "${PublisherSite}"
#define MyAppExeName "${ProjectName}.${ArtifactExtension}"

[Setup]
AppId={{${SetupGuid}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}\{#MyAppVersion}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-Setup
SetupIconFile=company.ico
Compression=lzma
SolidCompression=yes
ShowTasksTreeLines=True

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "${ProjectName}\bin\Debug\*.exe"; DestDir: "{app}"; Flags: replacesameversion
Source: "${ProjectName}\bin\Debug\*.pdb"; DestDir: "{app}"; Flags: replacesameversion
Source: "${ProjectName}\bin\Debug\*.config"; DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "${ProjectName}\bin\Debug\log4net.xml"; DestDir: "{app}"; Flags: onlyifdoesntexist
Source: "${ProjectName}\bin\Debug\*.dll"; DestDir: "{app}"; Flags: replacesameversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
