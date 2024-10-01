#!/usr/bin/env sh
#
#  User script for mounting and unmounting samba shares
#  Supports mounting multiple shares with options for credentials
#
#  - No fstab entry or mount units needed
#  - Use `-u` argument to unmount and remove the symlink
#  - Option to provide credentials interactively if not set
#  - Loop to handle multiple shares
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# @linux-aarhus - root.nix.dk
# Modified by @pheiduck
#

###########################################
# NECESSARY -  MODIFY THESE VARIABLES

# your samba server's hostname or IP address
HOST="my-server"

# list of share names on the server (space-separated)
SHARELIST="my-share1 my-share2 my-share3"  # Add more shares as needed

# credentials (optional, leave blank to be prompted)
USERNAME=""
WORKGROUP=""
PASSWD=""

###########################################
# don't modify below this line
#  - unless you know what you are doing

SCRIPTNAME=$(basename "$0")
VERSION="0.4"

# Check if the user wants to unmount
if [[ "$1" == "-u" ]]; then
    printf ":: Unmounting shares from %s...\n" "$HOST"
    for SHARE in $SHARELIST; do
        if gio mount -u "smb://$HOST/$SHARE"; then
            printf "Unmounted %s\n" "$SHARE"
        else
            printf "Failed to unmount %s\n" "$SHARE"
        fi
    done
    exit 0
elif [[ "$1" == "--dry-run" ]]; then
    printf ":: Dry run mode: displaying shares without mounting\n"
    for SHARE in $SHARELIST; do
        printf "Would mount: smb://%s/%s\n" "$HOST" "$SHARE"
    done
    exit 0
elif [[ $1 != "" ]]; then
    printf ":: %s v%s\n" "$SCRIPTNAME" "$VERSION"
    printf "==> Invalid argument: %s\n" "$1"
    printf "Usage: \n"
    printf "  Mount SMB : %s\n" "$SCRIPTNAME"
    printf "  Unmount SMB: %s -u\n" "$SCRIPTNAME"
    printf "  Dry Run: %s --dry-run\n" "$SCRIPTNAME"
    exit 1
fi

# Prompt for credentials if not provided
if [[ -z "${USERNAME}" ]]; then
    read -p "Enter Samba Username: " USERNAME
fi

if [[ -z "${PASSWD}" ]]; then
    read -sp "Enter Samba Password: " PASSWD
    echo ""
fi

if [[ -z "${WORKGROUP}" ]]; then
    read -p "Enter Workgroup (default: WORKGROUP): " WORKGROUP
    WORKGROUP=${WORKGROUP:-WORKGROUP}
fi

# Create credentials folder if not exists
if ! [ -d "$HOME/.credentials" ]; then
    mkdir -p "$HOME/.credentials"
    chmod 700 "$HOME/.credentials"
fi

# Create credentials file
CREDENTIALS_FILE="$HOME/.credentials/$USERNAME-$HOST"
printf "%s\n%s\n%s" "${USERNAME}" "${WORKGROUP}" "${PASSWD}" > "$CREDENTIALS_FILE"
chmod 600 "$CREDENTIALS_FILE"

# ----------------------------------------------------------------
# Loop through shares and mount them
printf ":: Mounting shares from %s...\n" "$HOST"
for SHARE in $SHARELIST; do
    if gio mount "smb://$HOST/$SHARE" < "$CREDENTIALS_FILE"; then
        printf "Mounted %s\n" "$SHARE"
    else
        printf "Failed to mount %s\n" "$SHARE"
    fi
done
