#!/usr/bin/bash

# Sudoers
adduser $USER sudo
addgroup user42
adduser $USER user42
sed -i \"/^root\\s*ALL=(ALL:ALL)\\s*ALL/a $USER\\tALL=(ALL:ALL) ALL\" /etc/sudoers
sed -i \"/^%sudo\\s*ALL=(ALL:ALL)\\s*ALL/a $USER\\tALL=(ALL) NOPASSWD: /usr/local/bin/monitoring.sh\" /etc/sudoers
mkdir -p /var/log/sudo
touch /var/log/sudo/sudo.log
sed -i '/^Defaults\\s\\+secure_path=.*/a Defaults\\tlog_input, log_output\\nDefaults\\tlogfile=\"/var/log/sudo/sudo.log\"' /etc/sudoers
sed -i '/^Defaults\\s\\+use_pty/c\\Defaults\\trequiretty' /etc/sudoers
sed -i '/^Defaults\\s\\+secure_path=/c\\Defaults\\tsecure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin\"' /etc/sudoers
sed -i '/^Defaults\\s\\+logfile*/a Defaults\\tpasswd_tries=3\\nDefaults\\tbadpass_message=\"Password is wrong!\"' /etc/sudoers

# SSH
sed -i 's/#Port 22/Port 4242/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
service ssh restart

# UFW
sed -i 's/ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf
echo '
*filter
:ufw-user-input - [0:0]
:ufw-user-output - [0:0]
:ufw-user-forward - [0:0]
:ufw-before-logging-input - [0:0]
:ufw-before-logging-output - [0:0]
:ufw-before-logging-forward - [0:0]
:ufw-user-logging-input - [0:0]
:ufw-user-logging-output - [0:0]
:ufw-user-logging-forward - [0:0]
:ufw-after-logging-input - [0:0]
:ufw-after-logging-output - [0:0]
:ufw-after-logging-forward - [0:0]
:ufw-logging-deny - [0:0]
:ufw-logging-allow - [0:0]
:ufw-user-limit - [0:0]
:ufw-user-limit-accept - [0:0]
### RULES ###

### tuple ### allow any 4242 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw-user-input -p tcp --dport 4242 -j ACCEPT
-A ufw-user-input -p udp --dport 4242 -j ACCEPT

### END RULES ###

### LOGGING ###
-A ufw-after-logging-input -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
-A ufw-after-logging-forward -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
-I ufw-logging-deny -m conntrack --ctstate INVALID -j RETURN -m limit --limit 3/min --limit-burst 10
-A ufw-logging-deny -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
-A ufw-logging-allow -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
### END LOGGING ###

### RATE LIMITING ###
-A ufw-user-limit -m limit --limit 3/minute -j LOG --log-prefix \"[UFW LIMIT BLOCK] \"
-A ufw-user-limit -j REJECT
-A ufw-user-limit-accept -j ACCEPT
### END RATE LIMITING ###
COMMIT
' > /etc/ufw/user.rules

echo '
*filter
:ufw6-user-input - [0:0]
:ufw6-user-output - [0:0]
:ufw6-user-forward - [0:0]
:ufw6-before-logging-input - [0:0]
:ufw6-before-logging-output - [0:0]
:ufw6-before-logging-forward - [0:0]
:ufw6-user-logging-input - [0:0]
:ufw6-user-logging-output - [0:0]
:ufw6-user-logging-forward - [0:0]
:ufw6-after-logging-input - [0:0]
:ufw6-after-logging-output - [0:0]
:ufw6-after-logging-forward - [0:0]
:ufw6-logging-deny - [0:0]
:ufw6-logging-allow - [0:0]
:ufw6-user-limit - [0:0]
:ufw6-user-limit-accept - [0:0]
### RULES ###

### tuple ### allow any 4242 0.0.0.0/0 any 0.0.0.0/0 in
-A ufw6-user-input -p tcp --dport 4242 -j ACCEPT
-A ufw6-user-input -p udp --dport 4242 -j ACCEPT

### END RULES ###

### LOGGING ###
-A ufw6-after-logging-input -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
-A ufw6-after-logging-forward -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
-I ufw6-logging-deny -m conntrack --ctstate INVALID -j RETURN -m limit --limit 3/min --limit-burst 10
-A ufw6-logging-deny -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
-A ufw6-logging-allow -j LOG --log-prefix \"[UFW BLOCK] \" -m limit --limit 3/min --limit-burst 10
### END LOGGING ###

### RATE LIMITING ###
-A ufw6-user-limit -m limit --limit 3/minute -j LOG --log-prefix \"[UFW LIMIT BLOCK] \"
-A ufw6-user-limit -j REJECT
-A ufw6-user-limit-accept -j ACCEPT
### END RATE LIMITING ###
COMMIT
' > /etc/ufw/user6.rules
service ufw restart

# Password
sed -i 's/PASS_MAX_DAYS\\t99999/PASS_MAX_DAYS\\t30/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\\t0/PASS_MIN_DAYS\\t2/' /etc/login.defs
chage --maxdays 30 --mindays 2 --warndays 7 $USER
chage --maxdays 30 --mindays 2 --warndays 7 root
sed -i 's/password\\t\\[success=1 default=ignore\\]\\tpam_unix.so obscure use_authtok try_first_pass yescrypt/password\\t\\[success=2 default=ignore\\]\\tpam_unix.so obscure sha512/' /etc/pam.d/common-password
sed -i 's/pam_pwquality.so retry=3/pam_pwquality.so retry=3 minlen=10 ucredit=-1 dcredit=-1 lcredit=-1 maxrepeat=3 usercheck=1 difok=7 enforce_for_root/' /etc/pam.d/common-password

# Crontab
cat << 'EOF' > \"/usr/local/bin/monitoring.sh\"
wall \\
\"
#Architecture: \$(uname -a)
#CPU physical : \$(lscpu | grep \"^Socket(s):\" | awk '{print \$2}')
#vCPU : \$(lscpu | awk '/^Socket\(s\)/ {s=\$2} /^Thread\(s\) per core/ {t=\$4} /^Core\(s\) per socket/ {c=\$4} END {print s * t * c}')
#Memory Usage: \$(free -m | awk '/^Mem:/ {used=\$3; total=\$2; printf \"%d/%dMB (%.2f%%)\", used, total, (used/total)*100}')
#Disk Usage: \$(df -h --total | awk '/^total/ {used=\$3; total=\$2; printf \"%d/%dGb (%d%%)\", used, total, \$5}')
#CPU load: \$(cat /proc/stat | awk '/^cpu / {idle=\$5; total=\$2+\$3+\$4+\$5+\$6+\$7+\$8+\$9+\$10+\$11; printf \"%.1f%%\", ((total-idle)/total)*100}')
#Last boot: \$(who -b | awk '{print \$3, \$4}')
#LVM use: \$(lsblk | grep \"lvm\" > /dev/null && echo \"yes\" || echo \"no\")
#Connections TCP : \$(ss -t state established | wc -l) ESTABLISHED
#User log: \$(who | wc -l)
#Network: \$(ip addr show | grep -E \"inet|link/ether\" | awk '{if (\$1 == \"inet\") ip=\$2; if (\$1 == \"link/ether\") mac=\$2} END {print \"IP\", ip, \"(\" mac \")\"}')
#Sudo : \$(grep -c \"COMMAND=\" /var/log/sudo/sudo.log) cmd
\"
EOF
echo -e \"\$(crontab -u root -l)*/10 * * * * bash /usr/local/bin/monitoring.sh\" | crontab -u root -
chmod 777 /usr/local/bin/monitoring.sh
service cron restart
