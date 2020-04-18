#!/bin/bash

echo "hello!"
echo "$ENCFS_REVERSE"
echo "$ENCFS_XML_NAME"
echo "$ENCFS_PASSWORD_NAME"

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


        echo "taking ownership of /config, /$MOUNT_SOURCE & /$MOUNT_TARGET for abc"
        chown ${PUID}:${PGID} /config
        chown ${PUID}:${PGID} /$MOUNT_SOURCE
        chown ${PUID}:${PGID} /$MOUNT_TARGET

# Cleanup any existing mount
#echo "unmounting /$MOUNT_TARGET"
#umount -f $MOUNT_TARGET
#echo "changing ownership of /$MOUNT_TARGET to ${PUID}"
#        chown ${PUID}:${PGID} /$MOUNT_TARGET


# Check if existing mount
if grep -qs '/$MOUNT_TARGET ' /proc/mounts; then
    echo "Something is already mounted at $MOUNT_TARGET"
else
    # Mount away!
    if [ "$ENCFS_REVERSE" -eq "0" ]; then
        echo "Reverse is set to no, thus standard mount.  Ready to mount now."
        ENCFS6_CONFIG='/config/'$ENCFS_XML_NAME encfs --extpass="cat /config/$ENCFS_PASSWORD_NAME" -o allow_other /$MOUNT_SOURCE /$MOUNT_TARGET
        if grep -qs '/$MOUNT_TARGET ' /proc/mounts; then
                echo "Successfully mounted at $MOUNT_TARGET"
        fi
    else
        echo "Ready to set mount as reverse..."
#        encfs -o allow_other $MOUNT_SOURCE $MOUNT_TARGET
        encfs --extpass="cat /config/$ENCFS_PASSWORD_NAME" --reverse -o allow_other "/$MOUNT_SOURCE" "/$MOUNT_TARGET"
            if grep -qs '/$MOUNT_TARGET ' /proc/mounts; then
                echo "Successfully mounted at $MOUNT_TARGET"
            fi

fi
fi


#trap 'umount -f /"$MOUNT_TARGET"' SIGTERM
trap 'fusermount -u -z "$MOUNT_TARGET"' SIGTERM

# and below to keep the container running.
tail -f /dev/null



