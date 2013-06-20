#!/bin/bash
# MySQL backup script
# Author: Michael Shulichenko

USER="root"
PASSWD="rootpassword"
CHARSET="utf8"
DATADIR="/backup"

FTP_ADDR="my.ftpserver.net"
FTP_USER="anonymous"
FTP_PASS="mypass"
FTP_PATH="/Backup" 

DATABASES=$1

PREFIX=`date +%F`

function usage {
    echo Usage:
    echo `basename $0` dbname1,dbname2,dbname3,...
    exit 0;
}

function upload {
    FILE=$1
    echo "[++++++----][`date +%F--%H-%M`] Uploading backup to FTP."
    wput --basename=$DATADIR -u -q -n 5 -B ${FILE} ftp://${FTP_USER}:${FTP_PASS}@${FTP_ADDR}${FTP_PATH}/
    echo "[++++++++--][`date +%F--%H-%M`] Uploading backup to FTP - successfull."
}

function do_backup {
        DBNAME=$1
        mysqldump --user=$USER --host=$HOST --password=$PASSWD --default-character-set=$CHARSET $DBNAME \
        | bzip2 -9 > $DATADIR/$PREFIX/DB/$DBNAME-`date +%F--%H-%M`.sql.bz2
}

#-----------------------------------------------------------------------

if [ -z "${DATABASES}" ]
then
    usage
fi

mkdir -p $DATADIR/$PREFIX/DB;

# Split databases by ','
IFS=',' read -ra DBNAME <<< "$DATABASES"

echo "[--------------------------------[`date +%F--%H-%M`]--------------------------------]" 
echo "[----------][`date +%F--%H-%M`] Run the backup script..."
echo "[++--------][`date +%F--%H-%M`] Generate a database backup..."

# Create backup for each database
for db in "${DBNAME[@]}"; do
    do_backup $db
done;

echo "[++++------][`date +%F--%H-%M`] Backup database - successfull."

# Upload all backups to ftp server
upload $DATADIR/$PREFIX/DB

echo "[+++++++++-][`date +%F--%H-%M`] Free HDD space: `df -h /home|tail -n1|awk '{print $4}'`"
echo "[++++++++++][`date +%F--%H-%M`] All operations completed successfully!"

exit 0;

