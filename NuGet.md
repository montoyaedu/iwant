Configure NuGet.
================

Set credentials and remembering ApiKey

        nuget sources
        Registered Sources:
            1.  nuget.org [Enabled]
                https://www.nuget.org/api/v2/
            2.  mynexusserver [Enabled]
                http://address:port/nexus/service/local/nuget/MyNuGetRepo/
        nuget sources update -name mynexusserver -source http://address:port/nexus/service/local/nuget/MyNuGetRepo/ -username user -password pass
        nuget setapikey your-api-key -source http://address:port/nexus/service/local/nuget/MyNuGetRepo/
