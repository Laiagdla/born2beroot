.DEFAULT_GOAL: setup

setup: ssh-set ssh-config ohmy login pam crontab ufw

ssh-set:
	@./title.sh "setting up ssh"
	ssh-keygen -f "/home/lgrobe-d/.ssh/known_hosts" -R "[localhost]:$(SSH_HOST)"
	ssh-add ~/.ssh/vm_ed25519
	ssh-keyscan -p $(SSH_HOST) localhost >> ~/.ssh/known_hosts
# ssh-copy-id -p $(SSH_HOST) -i ~/.ssh/vm_ed25519 $(USER)@localhost
# ssh -v -i ~/.ssh/vm_ed25519 -p $(SSH_HOST) $(USER)@localhost


ssh-config:
	@./title.sh "adding vm to ssh config"
	if ! grep -qF "Host $(VMNAME)" ~/.ssh/config; then \
	echo "Host $(VMNAME)" >> ~/.ssh/config && \
	echo "    HostName localhost" >> ~/.ssh/config && \
	echo "    User $(USER)" >> ~/.ssh/config && \
	echo "    Port $(SSH_HOST)" >> ~/.ssh/config && \
	echo "    IdentityFile ~/.ssh/vm_ed25519" >> ~/.ssh/config && \
	chmod 600 ~/.ssh/config; \
	fi

ohmy:
	@./title.sh "downloading a nice terminal"
	ssh -t $(VMNAME) "wget -O ~/ohmy.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
	ssh -t $(VMNAME) "chmod +x ohmy.sh"
	ssh -t $(VMNAME) "sh -c ~/ohmy.sh > /dev/null 2>&1 & exit"

login:
	@./title.sh "updating login conditions"
	scp -i ~/.ssh/vm_ed25519 -P $(SSH_HOST) templates/login.sh $(USER)@localhost:/home/$(USER)/login.sh
	ssh -t $(VMNAME) "sudo chmod +x /home/$(USER)/login.sh"
	ssh -t $(VMNAME) "sudo /home/$(USER)/login.sh"

pam:
	@./title.sh "updating password security"
	scp -i ~/.ssh/vm_ed25519 -P $(SSH_HOST) templates/pam.sh $(USER)@localhost:/home/$(USER)/pam.sh
	ssh -t $(VMNAME) "sudo chmod +x /home/$(USER)/pam.sh"
	ssh -t $(VMNAME) "sudo /home/$(USER)/pam.sh"


crontab:
	@./title.sh "adding cron job"
	ssh -t $(VMNAME) "(crontab -l 2>/dev/null; echo '*/10 * * * * bash /home/$(USER)/monitoring.sh') | crontab -"

ufw:
	@./title.sh "rising firewall"
	ssh -t $(VMNAME) "sudo ufw allow 4242"
	ssh -t $(VMNAME) "yes | sudo ufw enable"
	ssh -t $(VMNAME) "sudo ufw status"
