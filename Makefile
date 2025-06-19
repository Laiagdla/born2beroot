.PHONY: create re memnet disks start check clean del_disk setup stop

DEBIAN_URL	= https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso
VMNAME		?= debian_vm
ISO_PATH	= $(HOME)/sgoinfre/debian.iso
DISK_PATH	= $(HOME)/sgoinfre/$(VMNAME)_disk.vdi


####### Installation Variables
LANGUAGE	= $(shell echo ${LANG} | cut -d '_' -f 1)
COUNTRY		= $(shell echo ${LANG} | cut -d'_' -f2 | cut -d'.' -f1)
TIME_ZONE	= $(subst /,\/,$(shell cat /etc/timezone))
USER		= $(shell who | awk '{print $$1}')
HOSTNAME	= $(SUB_USER)42
KEYBOARD	= $(shell localectl status | grep 'X11 Layout' | awk '{print $$3}')
CRYPTO		= hello
ROOTPASS	= hello
PASS		= 12345

all: create memnet disks start
files: .env mandatory.sh preseed.cfg

####### CREATE
$(ISO_PATH):
	wget $(DEBIAN_URL) -O $(ISO_PATH)

create: $(ISO_PATH)
	vboxmanage createvm --name $(VMNAME) --ostype "Debian_64" --register --basefolder `pwd`

memnet:
	vboxmanage modifyvm $(VMNAME) --ioapic on
	vboxmanage modifyvm $(VMNAME) --memory 1024 --vram 128
	vboxmanage modifyvm $(VMNAME) --nic1 nat
	vboxmanage modifyvm $(VMNAME) --natpf1 "ssh,tcp,,4242,,4242"

disks:
	vboxmanage createhd --filename $(DISK_PATH) --size 31540 --format VDI
	vboxmanage storagectl $(VMNAME) --name "SATA Controller" --add sata --controller IntelAhci
	vboxmanage storageattach $(VMNAME) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  $(DISK_PATH)
	vboxmanage storagectl $(VMNAME) --name "IDE Controller" --add ide --controller PIIX4
	vboxmanage storageattach $(VMNAME) --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $(ISO_PATH)
	vboxmanage modifyvm $(VMNAME) --boot1 disk --boot2 dvd --boot3 none --boot4 none


##### CONTROL
start:
	vboxmanage startvm $(VMNAME)

stop:
	vboxmanage controlvm $(VMNAME) poweroff

check:
	vboxmanage list vms

###### REMOVE
del_disk:
	rm $(DISK_PATH)

clean: del_disk
	vboxmanage unregistervm $(VMNAME) --delete

re: stop clean create setup start

###### FILES
clean-files:
	rm .env
	rm mandatory.sh
	rm preseed.cfg

.env:
	@echo 'Creating .env'
	@echo LANGUAGE=$(LANGUAGE) >> .env
	@echo COUNTRY=$(COUNTRY) >> .env
	@echo TIME_ZONE=$(TIME_ZONE) >> .env
	@echo USER=$(USER) >> .env
	@echo HOSTNAME=$(HOSTNAME) >> .env
	@echo KEYBOARD=$(KEYBOARD) >> .env

mandatory.sh:
	@echo 'Creating mandatory.sh'
	@sed 's/$$USER/$(USER)/g' template.mandatory.sh > mandatory.sh
	@chmod +x mandatory.sh

preseed.cfg:
	@echo 'Creating preseed.cfg'
	@sed \
		-e 's/\[LANGUAGE\]/$(LANGUAGE)/g' \
		-e 's/\[COUNTRY\]/$(COUNTRY)/g' \
		-e 's/\[LANG\]/${LANG}/g' \
		-e 's/\[KEYBOARD\]/$(KEYBOARD)/g' \
		-e 's/\[TIME_ZONE\]/$(TIME_ZONE)/g' \
		-e 's/\[CRYPTO\]/$(CRYPTO)/g' \
		-e 's/\[ROOTPASS\]/$(ROOTPASS)/g' \
		-e 's/\[USER\]/$(USER)/g' \
		-e 's/\[PASS\]/$(PASS)/g' \
		template.preseed.cfg > preseed.cfg
