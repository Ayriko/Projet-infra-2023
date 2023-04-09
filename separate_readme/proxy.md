# Mise en place du proxy

Créer une vm dans le même réseau que le serveur avec pour ip 10.102.20.11

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
