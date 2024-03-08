[ref] [[root tip] [Utility Script] GIO mount samba share ](https://forum.manjaro.org/t/root-tip-utility-script-gio-mount-samba-share/100723)

# Utility to mount samba share as user

While gvfs is an acronym for Gnome Virtual File System it’s usage is not depending on Gnome. It comes with very few dependencies and even Manjaro Plasma has the gvfs package installed and as such this will work on any Linux.

The Linux mount utility does not allow for a user to mount a samba share and this results in Manjaro users setting up fstab to automount the share. Such automounts may cease working due to upstream changes e.g. when the SMB1 protocol was renamed to NT1 thus causing old shares to stop working.

## Install the toolset

This script relies on the packages gvfs-smb which will pull the necessary smb-client dependency. The following command will do the trick. If you want the dependencies to be explicitly installed add gvfs and smbclient to the command. The --needed argument will skip syncing packages already present.

sudo pacman -Syu gvfs-smb --needed

Create a new script in ~/.local/bin and name it smb-share.sh.

```
mkdir -p ~/.local/bin
touch ~/.local/bin/smb-share.sh
chmod +x ~/.local/bin/smb-share.sh
```

Paste below content and modify the variables to use your samba server and share name.

```
# your samba server's hostname or IP address
HOST="my-server"

# the share name on the server
SHARENAME="my-share"

# credentials
USERNAME=
WORKGROUP=
PASSWD=
```
