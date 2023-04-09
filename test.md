# **Projet-infra-2023**

## **I. Introduction**

Ce projet consiste à proposer un moyen de déployer et d'héberger localement FoundryVTT. Bien qu'il soit accessible en ligne une fois déployé il n'est pas destiné à être hébergé publiquement à destination d'un grand nombre d'utilisateurs. D'où l'absence d'instructions pour joindre le service dès cette introduction. Chaque utilisateur intéressé va pouvoir l'installer de son côté et en profiter personnellement, partageant le lien d'accès pour se connecter avec ses amis.

## **II. Requirements**

### **A. Machines :**
 - 4 machines RockyLinux (dont les rôles seront : Ansible host, reverse proxy nginx, server nfs, server app)
### **B. Pour toutes les machines :**

- Désactiver SELINUX

```bash
sudo vim /etc/selinux/config
# remplacer "enforcing" par "permissive" sur la ligne non commentée
```

- Le mot de passe des users créés devra être le même pour tous

### **C. Pour chaque rôle :**
 - Ansible host :
   - [Installation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) de Ansible
   - Cloner le repo
    ```
    git clone https://github.com/Ayriko/Projet-infra-2023.git
    ```
   - ssh-copy-id vers les 3 autres machines (pour permettre une connexion ssh sans mot de passe)

 - Reverse proxy nginx :
   - création d'un user "user" avec les droits sudo (si le nom du user choisi est différent, il faut en conséquence modifier le fichier [hosts.ini](ansible/inventories/foundry_infra/hosts.ini))
     ```
     [reverseproxy:vars]
     ansible_ssh_user=*your_user_name*
     ```
 - Server NFS :
   - création d'un user "user" avec les droits sudo(si le nom du user choisi est différent, il faut en conséquence modifier le fichier [hosts.ini](ansible/inventories/foundry_infra/hosts.ini))
     ```
     [nfsserver:vars]
     ansible_ssh_user=*your_user_name*
     ```
 - server App :
   - Création d'un user "aymerico", avec les droits sudo

## **D. Les IPs**
La configuration de base des IP est la suivante :
| Machines | IP |
|----------|:-------------:|
| Ansible | 10.102.20.50 |
| Proxy | 10.102.20.11 |
| Foundry | 10.102.20.12 |
| NFS | 10.102.20.16 |

Pour utiliser d'autres IP, il faut en conséquence modifier les fichier [all.yaml](ansible/inventories/foundry_infra/group_vars/all.yaml) et [hosts.ini](ansible/inventories/foundry_infra/hosts.ini) en remplaçant les IP par défault par les IP voulu.  

