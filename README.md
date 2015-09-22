# iwant
An effort to create a simple programming project starter. (Something like mvn archetype:generate but easier)

The following command, creates a new c# project.

`````
    ./iwant
    using template c#
    using folder MyApp
    using name MyApp
    using package MyPackage
    using version v4.5
    using type WinExe
    using project guid BAF96FB3-374D-4EE2-AB7C-0768F393FB5F
    using COM guid BC103D59-4F9E-46E8-996A-E2663360A278
    using assembly version 1.0.0.0
    using assembly version qualifier -SNAPSHOT
    using substitution command sed -e s/\${AssemblyName}/MyApp/ -e s/\${RootNamespace}/MyPackage/ -e s/\${TargetFrameworkVersion}/v4.5/ -e s/\${OutputType}/WinExe/ -e s/\${ProjectGuid}/BAF96FB3-374D-4EE2-AB7C-0768F393FB5F/ -e s/\${ComGuid}/BC103D59-4F9E-46E8-996A-E2663360A278/ -e s/\${AssemblyVersion}/1.0.0.0/ -e s/\${AssemblyVersionQualifier}/-SNAPSHOT/
`````
