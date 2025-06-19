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


########## CREATE VM ###########

all: create memnet disks start

$(ISO_PATH):
	wget $(DEBIAN_URL) -O $(ISO_PATH)

create: $(ISOMOD_PATH)
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
	vboxmanage storageattach $(VMNAME) --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $(ISOMOD_PATH)
	vboxmanage modifyvm $(VMNAME) --boot1 disk --boot2 dvd --boot3 none --boot4 none


########## CONTROL VM ###########
start:
	vboxmanage startvm $(VMNAME)

stop:
	vboxmanage controlvm $(VMNAME) poweroff

check:
	vboxmanage list vms


########## REMOVE VM ###########
del_disk:
	rm $(DISK_PATH)

remove: del_disk
	vboxmanage unregistervm $(VMNAME) --delete


########## FILES ###########
configfiles: config/preseed.cfg config/isolinux/txt.cfg config/isolinux.cfg config/isohdpfx.bin
cleanfiles:
	rm -f config/preseed.cfg
	rm -f config/txt.cfg
	rm -f config/isolinux.cfg
	rm -f config/isohdpfx.bin
	rm -f config/mandatory.sh
	rm -f config/.env

config/.env:
	@echo 'Creating .env'
	@echo LANGUAGE=$(LANGUAGE) >> .env
	@echo COUNTRY=$(COUNTRY) >> .env
	@echo TIME_ZONE=$(TIME_ZONE) >> .env
	@echo USER=$(USER) >> .env
	@echo HOSTNAME=$(HOSTNAME) >> .env
	@echo KEYBOARD=$(KEYBOARD) >> .env

config/mandatory.sh:
	@echo '▸ Creating mandatory.sh'
	@sed 's/$$USER/$(USER)/g' template.mandatory.sh > mandatory.sh
	@chmod +x mandatory.sh

config/preseed.cfg:
	@echo '▸ Creating preseed.cfg'
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
		config/template.preseed.cfg > config/preseed.cfg
	@cp config/preseed.cfg $(TEMP_DIR)/preseed.cfg

config/isolinux/txt.cfg:
	@echo '▸ Creating txt.cfg'
	@sed \
		-e 's/\[HOSTNAME\]/$(HOSTNAME)/g' \
		config/template.txt.cfg > config/txt.cfg
	@cp config/txt.cfg $(TEMP_DIR)/isolinux/txt.cfg

config/isolinux.cfg:
	@echo '▸ Copying isolinux.cfg'
	@cp config/template.isolinux.cfg config/isolinux.cfg
	@cp config/isolinux.cfg $(TEMP_DIR)/isolinux/isolinux.cfg

config/isohdpfx.bin:
	wget -O isolinux.deb  http://ftp.de.debian.org/debian/pool/main/s/syslinux/isolinux_6.04\~git20190206.bf6db5b4+dfsg1-3_all.deb
	ar x isolinux.deb
	tar -xf data.tar.xz ./usr/lib/ISOLINUX/isohdpfx.bin --strip-components=4
	mv isohdpfx.bin config/isohdpfx.bin
	rm data.tar.xz
	rm control.tar.xz
	rm debian-binary
	rm isolinux.deb


########## ISO ###########
build: $(TEMP_DIR) $(ISOMOD_PATH)
cleanbuild:
	rm -r $(TEMP_DIR)
	rm $(ISOMOD_PATH)

$(TEMP_DIR):
	mkdir $(TEMP_DIR)
	@xorriso -indev "$(ISO_PATH)" -osirrox on -extract / "$(TEMP_DIR)"
	chmod -R +w $(TEMP_DIR)

$(ISOMOD_PATH): $(ISO_PATH) $(TEMP_DIR) configfiles
	@xorriso -as mkisofs \
		-o "$(ISOMOD_PATH)" \
		-r -J \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		-eltorito-boot isolinux/isolinux.bin \
		-eltorito-catalog isolinux/boot.cat \
		-isohybrid-mbr config/isohdpfx.bin \
		-c isolinux/boot.cat \
		-b isolinux/isolinux.bin \
		"$(TEMP_DIR)"
