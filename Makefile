.PHONY: create re memnet disks start check clean del_disk setup stop

DEBIAN_URL	= https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso
VMNAME		?= debian_vm
ISO_PATH	= $(HOME)/sgoinfre/debian12.iso
ISOMOD_PATH	= $(HOME)/sgoinfre/$(VMNAME)_debian12_modded.iso
TEMP_DIR	= $(HOME)/sgoinfre/$(VMNAME)_temp
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
	$(MAKE) -f makebuild.mk
	@./title.sh "VM build finished, wait until debian is installed"
	$(MAKE) start

setup:
	$(MAKE) -f makesetup.mk

bonus:
	$(MAKE) -f makebonus.mk

fclean: stop
	$(MAKE) -f makebuild.mk cleanfiles
	$(MAKE) -f makebuild.mk cleanbuild
	$(MAKE) -f makebuild.mk removevm

signature:
	sha1sum $(DISK_PATH) | cut -d' ' -f1 > signature.txt

evalclone:
	vboxmanage clonevm $(VMNAME) --name $(VMNAME)eval --register --basefolder $(HOME)/sgoinfre/b2breval && vboxmanage startvm $(VMNAME)eval

eval:
	$(MAKE) -f makeeval.mk

########## CONTROL VM ###########
start:
	vboxmanage startvm $(VMNAME)

start-headless:
	vboxmanage startvm $(VMNAME) --type headless
	echo "$(CRYPTO)" > tmppass
	vboxmanage controlvm $(VMNAME) addencpassword ./tmppass
	rm -f tmppass

stop:
	sh -c 'STATE=$$(VBoxManage showvminfo "$(VMNAME)" | grep '\''^State:'\'' | awk '\''{print $$2}'\''); \
	if [ "$$STATE" = "running" ]; then VBoxManage controlvm "$(VMNAME)" savestate; fi'
	sleep 2

check:
	vboxmanage list vms

ssh:
	ssh -v $(VMNAME)
