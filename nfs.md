# Mis en place du nfs

## Machine hôte

```bash
sudo dnf install nfs-utils
sudo mkdir /exports/foundrydata -p
sudo chown nobody /exports/foundrydata/
sudo vim /etc/exports
/exports/foundrydata    10.102.20.12(rw,sync,no_subtree_check,no_root_squash,all_squash,anonuid=65534,anongid=65534)
sudo exportfs -a
sudo systemctl enable nfs-server
sudo systemctl start nfs-server
sudo systemctl status nfs-server                                                             
```

sudo exportfs -a dès qu'on modifie le exports

Note sur les options du exports:

```bash
#rw pour read and write access
#sync to write changes avant de répondre
#no_subtree pour pas check la dispo du file dans le tree à chaque requete
#no_root_squash désactive la sécu qui impose un user non root pour mount
#all_squash option to map all client user IDs to the anonymous user on the NFS server
#Add the anonuid=<uid> and anongid=<gid> options to specify the UID and GID of the anonymous user on the NFS server
#65534 = nobody
```

le sudo export a l'air très important dans la possibilité de mount ou non

On edit le firewall

```bash
firewall-cmd --permanent --add-service=nfs
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload
```

## Machine client

```bash
sudo dnf install nfs-utils
#pas nécessaire de sudo pour le mkdir (moyen que ça soit important même)
mkdir nfs/foundrydata -p
sudo mount 10.102.20.16:/exports/foundrydata nfs/foundrydata
#pour le mount une fois, plus tard pas besoin car fait lors du boot
df -h #permet de voir les mounts actuels
sudo vim /etc/fstab
-> 10.102.20.16:/exports/foundrydata /home/aymerico/nfs/foundrydata nfs rw 0 0
#d'autres options pour le fstab, voir si certaines sont utiles
sudo vim foundry.config.js
-> edit le DATA-PATH vers /home/aymerico/nfs/foundrydata
```

Refaire le pm2 startup est nécessaire pour que ce soit pris en compte.
Voir dans readme.md
