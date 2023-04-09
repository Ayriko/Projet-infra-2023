# **Projet-infra-2023**

## **I. Introduction**

Ce projet consiste à proposer un moyen de déployer et d'héberger localement FoundryVTT. Bien qu'il soit accessible en ligne une fois déployé il n'est pas destiné à être hébergé publiquement à destination d'un grand nombre d'utilisateurs. D'où l'absence d'instructions pour joindre le service dès cette introduction. Chaque utilisateur intéressé va pouvoir l'installer de son côté et en profiter personnellement, partageant le lien d'accès pour se connecter avec ses amis.

## **II. Requirements**

### **1. Machines :**

- 4 machines RockyLinux (dont les rôles seront : Ansible host, reverse proxy nginx, server nfs, server app)

### **2. Pour toutes les machines :**

- Désactiver SELINUX

```bash
sudo vim /etc/selinux/config
# remplacer "enforcing" par "permissive" sur la ligne non commentée
```

- Le mot de passe des users créés devra être le même pour tous

### **3. Pour chaque rôle :**

- Ansible host :
  - [Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) de Ansible
  - Cloner le repo

    ```text
    git clone https://github.com/Ayriko/Projet-infra-2023.git
    ```

  - ssh-copy-id vers les 3 autres machines (pour permettre une connexion ssh sans mot de passe)
  - Déclarer une variable d'environnement "NGROK_AUTHTOKEN" contenant le token NGROK qui sera utilisé.

- Reverse proxy nginx :
  - création d'un user "user" avec les droits sudo (si le nom du user choisi est différent, il faut en conséquence modifier le fichier [hosts.ini](ansible/inventories/foundry_infra/hosts.ini))

     ```text
     [reverseproxy:vars]
     ansible_ssh_user=*your_user_name*
     ```

- Server NFS :
  - création d'un user "user" avec les droits sudo(si le nom du user choisi est différent, il faut en conséquence modifier le fichier [hosts.ini](ansible/inventories/foundry_infra/hosts.ini))

     ```text
     [nfsserver:vars]
     ansible_ssh_user=*your_user_name*
     ```

- server App :
  - Création d'un user "aymerico", avec les droits sudo

### **4. Les IPs**

La configuration par défault des IP est la suivante :
| Machines | IP |
|----------|:-------------:|
| Ansible | 10.102.20.50 |
| Proxy | 10.102.20.11 |
| Foundry | 10.102.20.12 |
| NFS | 10.102.20.16 |

Pour utiliser d'autres IP, il faut modifier les fichier [all.yaml](ansible/inventories/foundry_infra/group_vars/all.yaml) et [hosts.ini](ansible/inventories/foundry_infra/hosts.ini) en remplaçant les IP par défault par les IP voulu.  

### **5. Fichiers de Foundry**

Posséder les 2 dossier "foundrydata.tar.gz" et "foundryvtt.tar.gz" (fournis en contactant un des auteurs de ce projet) puis les mettres dans le dossier "ansible/roles/app/files", ils seront utilisés pour installer Foundry sur le server App.

## **III. Ansible**

Soit PASSWD = le mot de passe utilisé pour les users créés sur les machines

### **1. Premier lancement**

Se mettre dans le répertoire "ansible/"

```bash
cd ansible/
```

Executer la commande suivante pour débuter la configuration des machines reverse-proxy, server NFS et App. (En pensant à bien remplacer PASSWD)

```text
ansible-playbook -i inventories/foundry_infra/hosts.ini playbooks/foundry_playbook.yaml -e "ansible_sudo_pass=PASSWD"
```

### **2. Pour les prochains lancement**

Une fois le premier lancement effectué, Foundry est donc installer.  
On peut executé la commande suivantes pour rejouer le script sans interférer avec le Foundry déjà installer :  

```text
ansible-playbook -i inventories/foundry_infra/hosts.ini playbooks/foundry_playbook.yaml -e "ansible_sudo_pass=PASSWD" --skip-tags "copy_foundry"
```

## **IV. Ngrok**

Pour accéder au serveur en ligne il faut se connecter en ssh
depuis la machine ansible à la machine du proxy il faut :

Aller sur le site Ngrok et se créer un compte pour pouvoir récuperer son token
puis sur la machine proxy :

```bash
ngrok config add-authtoken YOUR_TOKEN
ngrok tcp 443
```

puis rentrer l'url donné sur internet et vous voilà sur le serveur pour faire du JDR entre amis
