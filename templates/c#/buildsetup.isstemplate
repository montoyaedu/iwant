#define MyAppName "${ProjectName}"
#define MyAppVersion GetStringFileInfo('bin\Debug\${ProjectName}.${ArtifactExtension}', 'ProductVersion' )
#define MyAppPublisher "Your Company Inc."
#define MyAppURL "http://www.yourcompany.com"
#define MyAppExeName "${ProjectName}.${ArtifactExtension}"
#define MyAppPath StringChange(MyAppName, ".", "\")

[Setup]
AppId={{{#MyAppName}-{#MyAppVersion}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={drive:}\{#MyAppPath}\{#MyAppVersion}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename={#MyAppName}-{#MyAppVersion}-Setup
SetupIconFile=setup.ico
Compression=lzma
SolidCompression=yes
ShowTasksTreeLines=True

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "bin\Debug\*"; DestDir: "{app}"; Flags: replacesameversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
