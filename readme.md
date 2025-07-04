# Born2beroot automated

here is an implementation of born2beroot project automated with makefiles commands.
It uses virtual box cli, vboxmanage.
It rebuilda a debian 12 image with a preseed.cfg file and configration scripts.
It setups ssh, and perform the installation and configuration of bonus excersices via ssh.

steps:
	- make (wait until finishes installation and add crypto password)
	- make setup
	- make bonus

bonus part, sets a working wordpress site, and a navidrome server
