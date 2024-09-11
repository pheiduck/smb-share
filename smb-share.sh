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
    echo ":: Unmounting shares from $HOST..."
    for SHARE in $SHARELIST; do
        gio mount -u "smb://$HOST/$SHARE" && echo "Unmounted $SHARE" || echo "Failed to unmount $SHARE"
    done
    exit 0
elif [[ "$1" == "--dry-run" ]]; then
    echo ":: Dry run mode: displaying shares without mounting"
    for SHARE in $SHARELIST; do
        echo "Would mount: smb://$HOST/$SHARE"
    done
    exit 0
elif [[ $1 != "" ]]; then
    echo ":: $SCRIPTNAME v$VERSION"
    echo "==> Invalid argument: $1"
    echo "Usage: "
    echo "  Mount SMB : $SCRIPTNAME"
    echo "  Unmount SMB: $SCRIPTNAME -u"
    echo "  Dry Run: $SCRIPTNAME --dry-run"
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
echo -e "${USERNAME}\n${WORKGROUP}\n${PASSWD}" > "$CREDENTIALS_FILE"
chmod 600 "$CREDENTIALS_FILE"

# ----------------------------------------------------------------
# Loop through shares and mount them
echo ":: Mounting shares from $HOST..."
for SHARE in $SHARELIST; do
    gio mount "smb://$HOST/$SHARE" < "$CREDENTIALS_FILE" && echo "Mounted $SHARE" || echo "Failed to mount $SHARE"
done
