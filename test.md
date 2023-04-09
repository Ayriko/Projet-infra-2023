# Projet-infra-2023

## Introduction

Ce projet consiste à proposer un moyen de déployer et d'héberger localement FoundryVTT. Bien qu'il soit accessible en ligne une fois déployé il n'est pas destiné à être hébergé publiquement à destination d'un grand nombre d'utilisateurs. D'où l'absence d'instructions pour joindre le service dès cette introduction. Chaque utilisateur intéressé va pouvoir l'installer de son côté et en profiter personnellement, partageant le lien d'accès pour se connecter avec ses amis.

## Requirements

Une machine serveur, une machine proxy, une machine "ansible", une machine nfs. Le tout en Rocky Linux.

Désactiver SELINUX

```bash
sudo vim /etc/selinux/config
# remplacer "enforcing" par "permissive" sur la ligne non commentée
```

Il faudra set-up différentes ip sur vos machines :
| Machines | IP |
|----------|:-------------:|
| Ansible | 10.102.20.50 |
| Proxy | 10.102.20.11 |
| Foundry | 10.102.20.12 |
| NFS | 10.102.20.16 |

Ensuit sur chaque machine il faudra créer un utilisateur "user" et lui ajouter un mdp root:

```bash
useradd user
sudo passwd user
```

Puis ajouter "user" dans visudo

Enfin depuis la machine ansible il faut faire un échange de clés avec les autres machines:

```bash
ssh-keygen
ssh-copy-id user@"IP_DES_MACHINES"
```
