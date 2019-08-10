#!/bin/bash


PUID=${PUID:-911}
PGID=${PGID:-911}

if [ ! "$(id -u abc)" -eq "$PUID" ]; then usermod -o -u "$PUID" abc ; fi
if [ ! "$(id -g abc)" -eq "$PGID" ]; then groupmod -o -g "$PGID" abc ; fi

. "/usr/bin/variables"

echo "
GID/UID
-------------------------------------
User uid:    $(id -u abc)
User gid:    $(id -g abc)
-------------------------------------
"
chmod -R 777 \
	/var/lock \
        /data \
        /raw \

chmod a+r /etc/fuse.conf

chown -R abc:abc \
    /config \
    /data \
    /raw \
    /usr/bin/* 

MOUNT_SOURCE="/raw"
MOUNT_TARGET="/data"

# Ensure source is defined
if [ -z "$MOUNT_SOURCE" ]; then
    echo "Need to set MOUNT_SOURCE"
    exit 1
fi

# Ensure target is defined
if [ -z "$MOUNT_TARGET" ]; then
    echo "Need to set MOUNT_TARGET"
    exit 1
fi

# Wait for any required mounts
if [ "$WAIT_FOR_MNT" ]; then
    while true ; do
        if mount | grep -q "$WAIT_FOR_MNT" ; then
            break
        fi

        echo "Waiting for mount $WAIT_FOR_MNT";
        sleep 5
    done
fi

# Make directories if required

        echo "making mount source and target folders if required"
        mkdir -p $MOUNT_SOURCE
        mkdir -p $MOUNT_TARGET
        echo "taking ownership of mount source and target for user"
        chown ${PUID}:${PGID} $MOUNT_SOURCE
        chown ${PUID}:${PGID} $MOUNT_TARGET

# Cleanup any existing mount
        umount -f $MOUNT_TARGET

# Mount away!
        if [ "$ENCFS_PASS" ]; then
            exec su -l -c abc "ENCFS6_CONFIG='/config/encfs.xml' encfs -o allow_other -f --extpass='/bin/echo $ENCFS_PASS' $MOUNT_SOURCE $MOUNT_TARGET"
        else
            exec su -l -c abc "ENCFS6_CONFIG='/config/encfs.xml' encfs -o allow_other -f --extpass='cat /config/encfspass' $MOUNT_SOURCE $MOUNT_TARGET"
        fi
