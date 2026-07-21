#!/bin/bash
# ./fix_nas_shares.sh -o "path/dir/to/fix" -o "path/temp/dir"
# The dir that needs it's share config files fixing.
while getopts i:o: flag
do
    case "${flag}" in
        i) tempfolder=${OPTARG};;
        o) folder=${OPTARG};;
    esac
done
DIR="$(basename "${folder}")"
# The temporary dir that was setup with the correct permissions.
TEMP_DIR="$(basename "${tempfolder}")"
# Get the volume root name, print the second output after delimiting by /
ROOT_DIR="/"$(echo "$folder" | awk -F "/" '{print $2}')
echo $ROOT_DIR
# In readynas 6.10.X the share is located at volume root/._share/YOURSHARE
ROOT_SHARE_DIR=$(find "$ROOT_DIR/" -type d -name "._share" 2> /dev/null -print -quit)
echo "Share directory is: " $ROOT_SHARE_DIR
SHARE_DIR="$ROOT_SHARE_DIR/$DIR"
TEMP_SHARE_DIR="$ROOT_SHARE_DIR/$TEMP_DIR"
if [ -d "$SHARE_DIR" ] && [ -d "$TEMP_SHARE_DIR" ]; then
	echo "._share folders exists"
else
	echo "$folder and $tempfolder do not have a corresponding ._share/ folder"
	return 1 2> /dev/null || exit 1
fi
# Backup old config incase something goes wrong.
BACKUP_SHARE_DIR="$ROOT_SHARE_DIR"/."$DIR".old
i=0
while [ -d "$BACKUP_SHARE_DIR" ]; do
	i=$(( $i + 1 ))
	BACKUP_SHARE_DIR="$ROOT_SHARE_DIR"/."$DIR".old.$i
done
# if [ ! -d "$BACKUP_SHARE_DIR" ]; then
	mkdir "$BACKUP_SHARE_DIR"
# fi
echo "Backing up configs to: " $BACKUP_SHARE_DIR
cp -r "$SHARE_DIR"/. "$BACKUP_SHARE_DIR"

CONF_FILES=( "$SHARE_DIR"/*.conf )
for conf in "${CONF_FILES[@]}"; do
	BASENAME_CONF=$(basename "$conf")
	if [ ! -s "$conf" ]; then
		cp -v "$TEMP_SHARE_DIR/$BASENAME_CONF" "$conf"
		sed -i -e "s|$TEMP_DIR|$DIR|g" "$conf"
		# echo "$TEMP_SHARE_DIR/$BASENAME_CONF" "$SHARE_DIR/$conf"
	fi
done
