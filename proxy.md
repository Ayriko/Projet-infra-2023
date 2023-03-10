Créer une vm avec la même carte réseau que le serveur
```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-enp0s8
```
inscrire dedans :
```bash
DEVICE=enp0s8

BOOTPROTO=static
ONBOOT=yes

IPADDR=10.102.20.11
NETMASK=255.255.255.0
```

ensuite il faut installer nginx :
```bash
sudo dnf install nginx
```

ensuite on va modifier la conf de nginx :
```bash
sudo vim /etc/nginx/conf.d/proxy.conf
```

puis y mettre ce code :
```bash
# Define Server
server {

    # Enter your fully qualified domain name or leave blank
    server_name             10.102.20.11;

    # Listen on port 80 without SSL certificates
    listen                  80;

    # Sets the Max Upload size to 300 MB
    client_max_body_size 300M;

    # Proxy Requests to Foundry VTT
    location / {

        # Set proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # These are important to support WebSockets
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";

        # Make sure to set your Foundry VTT port number
        proxy_pass http://10.102.20.12:30000;
    }
}
```

Puis maintenant sur la machine qui contient le serveur :
```
sudo vim foundrydata/Config/options.json
```

remplacer le fichier actuel par celui là :
```bash
{
  "dataPath": "/home/aymerico/foundrydata",
  "compressStatic": true,
  "fullscreen": false,
  "hostname": "10.102.20.12",
  "language": "en.core",
  "localHostname": null,
  "port": 30000,
  "protocol": null,
  "proxyPort": 80,
  "proxySSL": false,
  "routePrefix": null,
  "updateChannel": "stable",
  "upnp": false,
  "upnpLeaseDuration": null,
  "awsConfig": null,
  "passwordSalt": null,
  "sslCert": null,
  "sslKey": null,
  "world": null,
  "serviceConfig": null
}
```

sur la machine du proxy :
```bash
sudo firewall-cmd --add-port=80/tcp --permanent
```

redemarrer nginx ainsi que le serveur
sur internet allé sur ce lien : http://10.102.20.11
si vous voyez la page d'accueil c'est que le proxy fonctionne
Maintenant il faut que l'ip du serveur ne soit plus joignable
pour cela sur la machine du serveur on va utiliser une zone de notre firewall
la premiere chose à faire est de tout supprimer sur notre zone par default à part le ssh:
```bash
sudo firewall-cmd --remove-port=30000/tcp --permanent
sudo firewall-cmd --remove-service cockpit
sudo firewall-cmd --remove-service dhcpv6-client
```

puis dans la zone internal on va ajouter le port 30000 ainsi que l'ip du proxy en source
comme ça seulement le proxy pourra atteindre le serveur :
```bash
sudo firewall-cmd --zone=internal --remove-service=cockpit
sudo firewall-cmd --zone=internal --remove-service=dhcpv6-client
sudo firewall-cmd --zone=internal --remove-service=mdns
sudo firewall-cmd --zone=internal --remove-service=samba-client
sudo firewall-cmd --zone=internal --remove-service=ssh
sudo firewall-cmd --zone=internal --add-source=10.102.20.11
sudo firewall-cmd --zone=internal --add-port=30000/tcp
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --reload
```