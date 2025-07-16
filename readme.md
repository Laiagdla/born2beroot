# Born2beroot automated

here is an implementation of born2beroot project automated with makefiles commands.

It uses virtual box cli, `vboxmanage`.
It is set with the minimun requirements for the bonus part

It rebuilds a a debian 12 image with a `preseed.cfg` file and configration scripts.
A debian iso file is downloaded, unpacked using chorriso and new configuration files are injected for rebuilding the iso.
the main files that affects the automation of the installatino are isolinux.cfg and txt.cfg
Other files and scripts with a ssh public key are also injected on the iso and repacked before installation.

For the configuration, being adjusted to the user, the makefile takes the variables from the host system, like localization, language, timezone, etc, passwords are hardcoded.
The makefile creates new configuration files based on templates replacing the specific enviroment variables.

It setups `ssh`, and perform the installation and configuration of bonus excersices via ssh.
A key pair is generated and stored in the host system, that later is used to connect without passwors
sudo password for the user is disabled, so all commands happen without interaction.

## steps:

- `make` (wait until finishes installation and add crypto password)
- `make setup`
- `make bonus`

for the bonus part, a working wordpress site with lighttpd and mariabd is installed.
for the specific service of my own choirce I used navidrome. A self-hosted music streaming platform. 

## notes:

### multiple VMS.
`VMNAME` is set in the makefile as `debian_vm`, but can be overwritten with running the command `export VMNAME=<newname>`
then multiple machines can be created simultaneously. 

### pressed lvm config:
some exaplanations about how to set lvms with debian preseeds [link](https://secopsmonkey.com/custom-partioning-using-preseed.html)

### lvm size:
[source](https://askubuntu.com/questions/1340402/ubuntu-preseed-expert-recipe-priority-max-size-dont-translate-into-correct-resu)
while lsblk display sizes in MiB preseed uses MB, sizes needs to be translated

### TODO:
Passwords are set on the makefile.
A better method needs to be implemented like using a .env or a script that blocks the current passwordless sudo, etc.
For streamlining the setup through ssh, sudo password for the user is dropped. this configuration needs to be removed after the installation is finished
