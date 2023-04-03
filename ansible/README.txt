Executer le playbook.yaml:

ansible-playbook -i inventory.yaml playbook.yaml -e "ansible_sudo_pass=root"


-i inventory.yaml: indique le fichier qu'on va utiliser comme inventaire

-e : permet de définir une/des variables supplémentaire (ici on attribue juste la valeur "root" à une variable existante qui sera utilisé à chaque monté en privilège)



Fonction actuel : 
 - Pour toutes les machines, modifie firewalld tel que:
   - création d'une nouvelle zone "allowed"
   - supprime les services et ports présent dans la zone public
   - change la target de la zone public en "DROP"
   - Ajoute dans les sources de la zone "allowed" une liste d'IP dont les valeurs dépendent du groupe Host sur lequel on travaille
 - Configure le bastion en créeant 2 user ( 1 permettant le jumping et 1 permettant de rentrer dans le bastion, autre que l'utilisateur user qui permet seulement à la machine Ansible de rentrer),

 - Configure le reverse_proxy : créer les certificats SSL, ajoute le fichier conf 
