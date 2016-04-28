Apache.
=======

modify /etc/apache2/sites-enabled/yoursite.conf

`````
    ProxyPreserveHost On
    ProxyRequests Off
    ProxyPass /nexus http://localhost:10035/nexus
    ProxyPassReverse /nexus http://localhost:10035/nexus
    ProxyPass /sonar http://localhost:9000/sonar
    ProxyPassReverse /sonar http://localhost:9000/sonar
`````
