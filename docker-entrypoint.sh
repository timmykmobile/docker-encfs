#!/bin/bash


# Making the /config directory
MOUNT_SOURCE=mount-source
MOUNT_TARGET=mount-target

# Set the PUID and GUID of the user
PUID=1000
PGID=1000

# Create a group for our gid if required
if [ -z "$(getent group abc)" ]; then
        echo "creating abc group for gid ${PGID}"
        groupadd -g ${PGID} -o abc >/dev/null 2>&1
fi



# Create a user for our uid if required
if [ -z "$(getent passwd abc)" ]; then
        echo "creating abc group for uid ${PUID}"
        useradd -u ${PUID} -g ${PGID} \
         -s /bin/bash -m -d "/config" \
         abc >/dev/null 2>&1
fi

echo "
GID/UID
-------------------------------------
User uid:    $(id -u abc)
User gid:    $(id -g abc)
-------------------------------------
"

# Create the folders for the mounts if required
if [ -z /$MOUNT_SOURCE ]; then
        echo "creating folder /$MOUNT_SOURCE"
        mkdir /$MOUNT_SOURCE
fi

if [ -z /$MOUNT_TARGET ]; then
        echo "creating folder /$MOUNT_SOURCE"
        mkdir /$MOUNT_TARGET
fi


        echo "taking ownership of /config for abc"
        chown ${PUID}:${PGID} /config
        chown ${PUID}:${PGID} /$MOUNT_SOURCE
        chown ${PUID}:${PGID} /$MOUNT_TARGET



# Cleanup any existing mount
umount -f $MOUNT_TARGET

# Mount away!
#if [ "$ENCFS_PASS" ]; then
    echo "Mounting at target"
    ENCFS6_CONFIG='/config/encfs.xml' encfs --extpass="cat /config/encfspass" -o allow_other /$MOUNT_SOURCE /$MOUNT_TARGET
    echo "Mounted now hopefully"
#else
#    encfs -o allow_other $MOUNT_SOURCE $MOUNT_TARGET
#fi


