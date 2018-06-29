#!/bin/bash

PUID=${PUID:-0}
PGID=${PGID:-0}

# Create a group for our gid if required
if [ -z "$(getent group abc)" ]; then
        echo "creating abc group for gid ${PGID}"
        groupadd --gid ${PGID} --non-unique abc >/dev/null 2>&1
fi

# Create a user for our uid if required
if [ -z "$(getent passwd abc)" ]; then
        echo "creating abc group for uid ${PUID}"
        useradd --gid ${PGID} --non-unique --comment "abc" \
         --home-dir "/config" --create-home \
         --uid ${PUID} abc >/dev/null 2>&1

        echo "taking ownership of /config for abc"
        chown ${PUID}:${PGID} /config
fi

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
            exec su abc -l -c ENCFS6_CONFIG='/config/encfs.xml' encfs -o allow_other -f --extpass='/bin/echo $ENCFS_PASS' $MOUNT_SOURCE $MOUNT_TARGET
        else
            exec su abc -l -c ENCFS6_CONFIG='/config/encfs.xml' encfs -o allow_other -f --extpass='cat /config/encfspass' $MOUNT_SOURCE $MOUNT_TARGET
        fi
