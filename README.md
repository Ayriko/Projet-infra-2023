# Projet-infra-2023

## Requirements

Une machine serveur, une machine proxy, une machine "bastion". Le tout en Rocky Linux.

Node est requis sur le serveur, utilisez les commandes suivantes :

Red Hat

```bash
sudo yum install -y openssl-devel
curl --silent --location https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo yum install -y nodejs
```

Désactiver SELINUX

```bash
sudo vim /etc/selinux/config
# remplacer "enforcing" par "permissive" sur la ligne non commentée
```

Faire le nfs avant ces étapes ?

## 1/ Installation de FoundryVTT

Sur la machine qui servira de serveur, on va créer deux dossiers et se mettre dans l'un d'eux :

```bash
cd $HOME
mkdir foundryvtt
mkdir foundrydata
cd foundryvtt
```

Télécharger le zip de Foundry avec la commande suivante :

```bash
wget -O foundryvtt.zip "PASTED-URL-FROM-FOUNDRY-WEBSITE-HERE"
```

L'URL est récupérable via sa page de profil si on possède une license. Le lien a une durée de vie de 5 minutes.

Une fois téléchargé, il faut extraire l'archive :

```bash
unzip foundryvtt.zip
```

On va ensuite le lancer une première fois pour générer tout ce dont il a besoin puis on va configurer plusieurs paramètres.

```bash
node resources/app/main.js --dataPath=$HOME/foundrydata
```

On peut désormais se connecter à l'adresse du serveur au port 30000.

!tester de transférer le fichier license.json!

Il vous demande de rentrer une clé d'activation de license, aussi récupérable depuis votre page de profil.
Et d'accepter l'EULA, tout cela est nécessaire pour utiliser Foundry.

On va configurer le fichier options.json :

```bash
cd $HOME
vim foundrydata/Config/options.json
#set le datapath sur /home/your-user/foundrydata
#set upnp sur false
```

D'autres paramètres seront modifiés au moment de l'installation du proxy.

Foundry est désormais prêt à être utilisé, cependant on va maintenant configurer notre serveur pour s'assurer que Foundry soit toujours en marche.

## 2/ Installation de PM2

Egalement sur le serveur. Dans le home de son user.

Installation de PM2

```bash
npm install pm2@latest -g
```

On met en place un fichier de configuration pour Foundry.

```bash
vim foundry.config.js
    module.exports = {
    apps : [{
        name   : "foundry",
        script : "./foundryvtt/resources/app/main.js",
        env: {
            "FOUNDRY_VTT_DATA_PATH": "/home/<USER>/foundrydata"
        }
    }]
    }
```

Mise en place du Start-Up

```bash
pm2 startup
#utiliser la commande donnée en retour
pm2 start foundry.config.js
pm2 save
```

Désormais le serveur Foundry sera toujours lancé au démarrage de la machine et sera relancé si il est éteint.

On peut suivre ce qui se passe avec :

```bash
pm2 status
#permet de voir les services et leurs états sous pm2
pm2 logs
#permet de voir les logs du server Foundry
```

Si on souhaite voir les logs de ses services en cas de problème :

```bash
sudo journalctl -xe -u pm2-<USER>.service
```

## 3/ Mise en place du proxy

voir proxy.md

## 4/ Mise en place du ssl

voir ssl.md
