all: interface ufw ssh

interface:
	@./title.sh "graphic interface"
	ssh -t $(VMNAME) "ls /usr/bin/*session | wc -l"
	ssh -t $(VMNAME) "dpkg -l | grep -E 'gnome|kde|xfce|mate|cinnamon|lxde' || echo 'no graphic interface'"
	@./title.sh " --- end ---"

ufw:
	@./title.sh "firewall rules"
	ssh -t $(VMNAME) "sudo ufw status"
	ssh -t $(VMNAME) "sudo systemctl status ufw"
	@./title.sh " --- end ---"

ssh:
	@./title.sh "testing ssh"
	ssh -t $(VMNAME) "systemctl is-active --quiet ufw && echo 'ssh up' || echo 'ssh down'"
	ssh -t $(VMNAME) "sudo cat /etc/ssh/ssh_config"
	@./title.sh " --- end ---"

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
