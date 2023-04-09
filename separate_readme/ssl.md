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

```bash
sudo firewall-cmd --add-port=443/tcp
sudo firewall-cmd --remove-port=80/tcp
```

enfin relancer le serveur et nginx

```bash
sudo systemctl start nginx

node foundryvtt/resources/app/main.js --dataPath=$HOME/foundrydata
```

pour faire en sorte que nginx se lance au démarrage du PC il suffit :
```bash
sudo systemctl enable nginx
```
