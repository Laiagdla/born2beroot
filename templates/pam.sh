#!/bin/bash
passorig="password\t\\[success=1 default=ignore\\]\tpam_unix.so obscure use_authtok try_first_pass yescrypt"
passdest="password\t[success=2 default=ignore]\tpam_unix.so obscure sha512"
qaorig="pam_pwquality.so retry=3"
qadest="pam_pwquality.so retry=3 minlen=10 ucredit=-1 dcredit=-1 lcredit=-1 maxrepeat=3 usercheck=1 difok=7 enforce_for_root"

sudo perl -pi -e 's|${passorig}|${passdest}|g' /etc/pam.d/common-password
sudo perl -pi -e 's|${qaorig}|${qadest}|g' /etc/pam.d/common-password
