#!/bin/bash
# Aymeric MOISKA
# Permet de réaliser une backup du data de Foundry présent dans le dossier partagé en nfs à intervalle régulier

DATE=`date +"%Y%m%d%H%M"`
backupfile=foundrydata_backup_${DATE}

tar -cf {{ Path_to_backups }}${backupfile}.tar.gz /exports/foundrydata/
echo "Le dossier Foundrydata a été compressé en ${backupfile}.gz"
