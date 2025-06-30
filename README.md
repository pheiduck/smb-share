[ref] [[root tip] [Utility Script] GIO mount samba share ](https://forum.manjaro.org/t/root-tip-utility-script-gio-mount-samba-share)

# Utility to mount samba share as user

While gvfs is an acronym for Gnome Virtual File System it’s usage is not depending on Gnome. It comes with very few dependencies and even Manjaro Plasma has the gvfs package installed and as such this will work on any Linux.

The Linux mount utility does not allow for a user to mount a samba share and this results in Manjaro users setting up fstab to automount the share. Such automounts may cease working due to upstream changes e.g. when the SMB1 protocol was renamed to NT1 thus causing old shares to stop working.

## Install the toolset

This script relies on the packages gvfs-smb which will pull the necessary smb-client dependency. The following command will do the trick. If you want the dependencies to be explicitly installed add gvfs and smbclient to the command. The --needed argument will skip syncing packages already present.

```
sudo pacman -Syu gvfs-smb --needed
```

If does not exist create directory `~/.local/bin` place the script in `~/.local/bin` make it executable.

```
mkdir -p ~/.local/bin
cd ~/.local/bin
curl -LO https://raw.githubusercontent.com/pheiduck/smb-share/main/smb-share.sh
chmod +x ~/.local/bin/smb-share.sh
```

Modify the variables to use your samba server and share name.

```
# your samba server's hostname or IP address
HOST="my-server"

# list of share names on the server
SHARELIST="my-share1 my-share2"

# optional credentials
USERNAME=""
WORKGROUP=""
PASSWD=""
```

## user service

You can complement this with a systemd user service to automate things even more.

Create the folder

```
mkdir -p ~/.config/systemd/user
```

Dowload the service file

```
cd ~/.config/systemd/user
curl -LO https://raw.githubusercontent.com/pheiduck/smb-share/main/smb-share.service
```

Enable and start the service

```
systemctl enable --user smb-share.service
systemctl start --user smb-share.service
```

To simplify maintenance you can move the script to the service folder and change the ExecStart and ExecStop paths in the service file to /home/%u/.config/systemd/user/.
