#!/bin/bash
sudo perl -pi -e 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t30/g' /etc/login.defs
sudo perl -pi -e 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t2/g' /etc/login.defs
chage --maxdays 30 --mindays 2 --warndays 7 "$(whoami)"
chage --maxdays 30 --mindays 2 --warndays 7 root
