# Mise en place du proxy

Créer une vm avec la même carte réseau que le serveur

```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-enp0s8
```

Inscrire dedans :

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

et on va modifier la conf de nginx :

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

Maintenant sur la machine qui contient le serveur :

```bash
vim foundrydata/Config/options.json
```

Remplacer les lignes suivantes actuels par celles-ci :

```bash
{
  "hostname": "10.102.20.12",
  "proxyPort": 80,
}
```

Sur la machine du proxy :

```bash
sudo firewall-cmd --add-port=80/tcp --permanent
```

Redémarrer nginx ainsi que le serveur.
```bash
sudo systemctl start nginx
```
Sur internet aller sur ce lien : `http://10.102.20.11`.
Si vous voyez la page d'accueil c'est que le proxy fonctionne.  

Maintenant il faut que l'ip du serveur ne soit plus joignable.  
Pour cela sur la machine du serveur on va utiliser une zone de notre firewall.  
La premiere chose à faire est de tout supprimer sur notre zone par default à part le ssh:  

```bash
sudo firewall-cmd --remove-port=30000/tcp --permanent
sudo firewall-cmd --remove-service cockpit
sudo firewall-cmd --remove-service dhcpv6-client
```
On va ensuite créer une nouvelle zone et lui ajouter une ip et le port  
pour faire en sorte que seulement le proxy puisse atteindre le serveur 

```bash
sudo firewall-cmd --new-zone=proxy --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=proxy --add-port=30000/tcp
sudo firewall-cmd --zone=proxy --add-source=10.102.20.11
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --reload
```

# Mise en place du ssl

Sur la machine du proxy il va falloir modifier le fichier de conf de nginx qu'on a crée precedemment :
```bash
# This goes in a file within /etc/nginx/sites-available/. By convention,
        # the filename would be either "your.domain.com" or "foundryvtt", but it
        # really does not matter as long as it's unique and descriptive for you.

        # Define Server
        server {

            # Enter your fully qualified domain name or leave blank
            server_name             10.102.20.11;

            # Listen on port 443 using SSL certificates
            listen                  443 ssl;
            ssl_certificate         "/etc/pki/nginx/certificate.crt";
            ssl_certificate_key     "/etc/pki/nginx/private/privateKey.key";

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

        # Optional, but recommend. Redirects all HTTP requests to HTTPS for you
        server {
            if ($host = 10.102.20.11) {
                return 301 https://$host$request_uri;
            }

            listen 80;
            listen [::]:80;

            server_name 10.102.20.11;
            return 404;
        }
```

la prochaine à faire de génerer des certificats:
```bash
mkdir /etc/pki/nginx
mkdir /etc/pki/nginx/private
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /etc/pki/nginx/private/privateKey.key -out /etc/pki/nginx/certificate.crt
```

puis sur la vm du serveur il faut modifier le fichier de conf du serveur
```bash
vim foundrydata/Config/options.json

{
  "dataPath": "/home/aymerico/foundrydata",
  "compressStatic": true,
  "fullscreen": false,
  "hostname": "10.102.20.12",
  "language": "en.core",
  "localHostname": null,
  "port": 30000,
  "protocol": null,
  "proxyPort": 443,
  "proxySSL": true,
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

puis on ouvre le port 443 et on ferme le port 80
```
sudo firewall-cmd --add-port=443/tcp
sudo firewall-cmd --remove-port=80/tcp
```

enfin relancer le serveur et nginx
```
sudo systemctl start nginx

node foundryvtt/resources/app/main.js --dataPath=$HOME/foundrydata
```

ensuite on va transformer nginx en service
Pour cela :
```bash
sudo vim /etc/systemd/nginx.service

[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

puis on va le enable pour qu'il se lance au redémarrage :
```
sudo systemctl enable nginx.service
```

puis on le restart:
```
sudo systemctl restart nginx.service
```