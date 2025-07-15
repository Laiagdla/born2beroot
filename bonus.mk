.DEFAULT_GOAL: bonus

bonus: server php wordpress mariadb server-restart navidrome music

server:
	ssh -t $(VMNAME) "yes | sudo apt install lighttpd"
	ssh -t $(VMNAME) "sudo ufw allow $(HTML_VM)"

php:
	ssh -t $(VMNAME) "yes | sudo apt install php-cgi php-mysql"

mariadb:
	ssh -t $(VMNAME) "yes | sudo apt install mariadb-server"
	ssh -t $(VMNAME) "echo \"n\nn\ny\ny\ny\ny\" | sudo mysql_secure_installation"
	ssh -t $(VMNAME) "sudo mysql -e \
		\"CREATE DATABASE wp_database; \
		CREATE USER '$(USER)'@'localhost' IDENTIFIED BY '$(PASS)'; \
		GRANT ALL PRIVILEGES ON wp_database.* TO '$(USER)'@'localhost'; FLUSH PRIVILEGES;\""

wordpress:
	ssh -t $(VMNAME) "sudo rm -rf /var/www/html"
	ssh -t $(VMNAME) "wget https://wordpress.org/latest.zip"
	ssh -t $(VMNAME) "sudo unzip latest.zip -d /var/www"
	ssh -t $(VMNAME) "sudo mv /var/www/wordpress /var/www/html"
	ssh -t $(VMNAME) "sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php"
	ssh -t $(VMNAME) "sudo sed -i \
		-e 's|database_name_here|wp_database|g' \
		-e 's|username_here|$(USER)|g' \
		-e 's|password_here|$(PASS)|g' \
		/var/www/html/wp-config.php"

server-restart:
	ssh -t $(VMNAME) "sudo lighty-enable-mod fastcgi"
	ssh -t $(VMNAME) "sudo lighty-enable-mod fastcgi-php"
	ssh -t $(VMNAME) "sudo service lighttpd force-reload"

# https://www.navidrome.org/docs/installation/linux/
navidrome:
	ssh -t $(VMNAME) "sudo apt update"
	ssh -t $(VMNAME) "yes | sudo apt upgrade"
	ssh -t $(VMNAME) "wget -O ~/navidrome_0.57.deb https://github.com/navidrome/navidrome/releases/download/v0.57.0/navidrome_0.57.0_linux_amd64.deb"
	ssh -t $(VMNAME) "yes | sudo apt install ~/navidrome_0.57.deb"
	ssh -t $(VMNAME) "sudo mkdir -p /var/opt/navidrome"
	ssh -t $(VMNAME) "sudo chown -R navidrome:navidrome /var/opt/navidrome"
	ssh -t $(VMNAME) "sudo chmod g+w /var/opt/navidrome/"
	ssh -t $(VMNAME) "sudo usermod -aG navidrome $(USER)"
	ssh -t $(VMNAME) "sudo sed -i 's|/opt/navidrome/music|/var/opt/navidrome|g' /etc/navidrome/navidrome.toml"
	ssh -t $(VMNAME) "sudo systemctl enable --now navidrome"
	ssh -t $(VMNAME) "sudo ufw allow $(NAVI_VM)"

navidrome-check:
	ssh -t $(VMNAME) "sudo systemctl status navidrome"
	ssh -t $(VMNAME) "sudo journalctl -u navidrome -f"

wordpress-check:
	ssh -t $(VMNAME) "sudo systemctl status lighttpd"

# https://github.com/scdl-org/scdl
music:
	ssh -t $(VMNAME) "yes | sudo apt install ffmpeg pipx"
	ssh -t $(VMNAME) "pipx install scdl"
	ssh -t $(VMNAME) "pipx ensurepath && \
		source ~/.zshrc && \
		scdl -l https://soundcloud.com/projectlazy/broken-5 --path /var/opt/navidrome"
	ssh -t $(VMNAME) "sudo chown -R navidrome:navidrome /var/opt/navidrome"
	ssh -t $(VMNAME) "sudo chmod -R u=rwX,go=rX /var/opt/navidrome"
