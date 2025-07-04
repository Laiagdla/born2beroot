.PHONY: create re memnet disks start check clean del_disk setup stop

DEBIAN_URL	= https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso
VMNAME		?= debian_vm
ISO_PATH	= $(HOME)/sgoinfre/debian.iso
ISOMOD_PATH	= $(HOME)/sgoinfre/debian_mod.iso
TEMP_DIR	= $(HOME)/sgoinfre/debian_temp
DISK_PATH	= $(HOME)/sgoinfre/$(VMNAME)_disk.vdi


####### Installation Variables
LANGUAGE	= $(shell echo ${LANG} | cut -d '_' -f 1)
COUNTRY		= $(shell echo ${LANG} | cut -d'_' -f2 | cut -d'.' -f1)
TIME_ZONE	= $(subst /,\/,$(shell cat /etc/timezone))
USER		= $(shell who | awk '{print $$1}')
HOSTNAME	= $(USER)42
KEYBOARD	= $(shell localectl status | grep 'X11 Layout' | awk '{print $$3}')
CRYPTO		= hello
ROOTPASS	= hello
PASS		= 12345
# ports
SSH_VM		= 4242
HTML_VM		= 80
NAVI_VM		= 4533
SSH_HOST	= 4243
HTML_HOST	= 4244
NAVI_HOST	= 4245

export DEBIAN_URL VMNAME ISO_PATH ISOMOD_PATH TEMP_DIR DISK_PATH
export LANGUAGE COUNTRY TIME_ZONE USER HOSTNAME KEYBOARD CRYPTO ROOTPASS PASS
export SSH_VM HTML_VM NAVI_VM SSH_HOST HTML_HOST NAVI_HOST

.DEFAULT_GOAL: build

########## MANAGE VM ###########
build:
	$(MAKE) -f build.mk
	@./title.sh "VM build finished, wait until debian is installed"
	$(MAKE) start

setup:
	$(MAKE) -f setup.mk

bonus:
	$(MAKE) -f bonus.mk

fclean:
	$(MAKE) -f build.mk cleanfiles
	$(MAKE) -f build.mk cleanbuild
	$(MAKE) -f build.mk removevm

########## CONTROL VM ###########
start:
	vboxmanage startvm $(VMNAME)

start-headless:
	vboxmanage startvm $(VMNAME) --type headless
	echo "$(CRYPTO)" > tmppass
	vboxmanage controlvm $(VMNAME) addencpassword "identifier" ./tmppass
	rm -f tmppass

stop:
	vboxmanage controlvm $(VMNAME) poweroff

check:
	vboxmanage list vms

ssh:
	ssh -v $(VMNAME)
