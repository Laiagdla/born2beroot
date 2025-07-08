graphic-interface:
	ls /usr/bin/*session

ufw:
	sudo ufw status
	sudo systemctl status ufw
ssh:
	systemctl is-active --quiet ufw && echo "ssh up" || echo "ssh down"
	sudo cat /etc/ssh/ssh_config

pam:
	sudo cat /etc/pam.d/common-password

login:
	sudo cat /etc/login.defs

sudoers:
	sudo visudo -f /etc/sudoers.d/rules

kernel:
	uname --kernel-version

groups:
	getent group sudo user42

sudo:
	apt show sudo

cron:
	sudo systemctl disable cron
# sudo systemctl enable cron

user:
	sudo adduser name_user
	sudo addgroup evaluating
	sudo adduser name_user evaluating

hostnames:
	hostname
	sudo nano /etc/hostname
	sudo nano /etc/hosts
	sudo reboot

partitions:
	lsblk
