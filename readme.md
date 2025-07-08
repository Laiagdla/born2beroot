# Born2beroot automated

here is an implementation of born2beroot project automated with makefiles commands.

It uses virtual box cli, `vboxmanage`.

It rebuilda a debian 12 image with a `preseed.cfg` file and configration scripts.

It setups `ssh`, and perform the installation and configuration of bonus excersices via ssh.

## steps:

- `make` (wait until finishes installation and add crypto password)
- `make setup`
- `make bonus`

bonus part, sets a working wordpress site, and a navidrome server

## notes:

### pressed lvm config:
some exaplanations about how to set them up [link](https://secopsmonkey.com/custom-partioning-using-preseed.html)

### lvm size:
[source](https://askubuntu.com/questions/1340402/ubuntu-preseed-expert-recipe-priority-max-size-dont-translate-into-correct-resu)
while lsblk display sizes in MiB preseed uses MB, sizes needs to be translated

### TODO:
Passwords are set on the makefile.
A better method needs to be implemented.
For streamlining the setup through ssh, sudo password for the user is dropped. this configuration needs to be removed after the installation is finished
