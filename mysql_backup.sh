#!/bin/bash -x

# Based on percona xtrabackup tool
# https://www.percona.com/doc/percona-xtrabackup/2.2/howtos/recipes_xbk_inc.html

BACKUP_DIR="/backup/mysql";

#**********************************************************************

DAY_OF_MONTH=$(date +%d);
STORAGE_DIR=$(date +%Y_%B);

TARGET_DIR="$BACKUP_DIR/$STORAGE_DIR/$DAY_OF_MONTH";
INCREMENTAL_BASEDIR="$BACKUP_DIR/$STORAGE_DIR/incremental-basedir";

function raiseError {
    case "$1" in
        "601" ) echo "Can't complete task: Directory creation failed.";;
        "602" ) echo "Can't complete task: Disk space is low";;
        "603" ) echo "Can't complete task: Target directory already exists";;
        *     ) echo "Can't complete task: Unknown error occured";;
    esac;
    exit 1;
}

function createFullBackup {
    xtrabackup --backup --target-dir=${TARGET_DIR}
    ln -s ${TARGET_DIR} ${INCREMENTAL_BASEDIR};
}

function createIncrementBackup {
    xtrabackup --backup --target-dir=${TARGET_DIR} \
      --incremental-basedir=${INCREMENTAL_BASEDIR}
}

function checkCreateDir {
    if [ ! -d "$1" ]; then
        mkdir -p $1;
        if [ "$?" != "0" ]; then
            raiseError 601;
        fi;
    else
        raiseError 603;
    fi;
}

checkCreateDir ${TARGET_DIR};

if [ "$DAY_OF_MONTH" == "01" ] || [ ! -L "${INCREMENTAL_BASEDIR}" ]; then
    createFullBackup;
    exit 0;
fi;

createIncrementBackup;

exit 0;