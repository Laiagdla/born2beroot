.PHONY: build create memnet disks cleanfiles cleanbuild removevm

CONFIGFILES	:=	config/preseed.cfg \
				config/txt.cfg \
				config/isolinux.cfg \
				config/isohdpfx.bin \
				config/sudo_rules.conf \
				config/monitoring.sh \
				~/.ssh/vm_ed25519.pub

all: build create memnet disks
build: $(TEMP_DIR) $(CONFIGFILES) $(ISOMOD_PATH)

########## REMOVE VM ###########
cleanfiles:
	@./title.sh "removing config files"
	rm -f $(CONFIGFILES)
	rm -f ~/.ssh/vm_ed25519

cleanbuild:
	@./title.sh "removing iso and temp files"
	rm -rf $(TEMP_DIR)
	rm -f $(ISOMOD_PATH)

removevm:
	@./title.sh "deleting VM"
	vboxmanage unregistervm $(VMNAME) --delete
	rm $(DISK_PATH)

########## ISO ###########
$(ISO_PATH):
	wget $(DEBIAN_URL) -O $(ISO_PATH)

create: $(ISOMOD_PATH)
	@./title.sh "Registering VM"
	vboxmanage createvm --name $(VMNAME) --ostype "Debian_64" --register --basefolder `pwd`

memnet:
	@./title.sh "VM settings"
	vboxmanage modifyvm $(VMNAME) --ioapic on
	vboxmanage modifyvm $(VMNAME) --memory 1024 --vram 128
	vboxmanage modifyvm $(VMNAME) --nic1 nat
	vboxmanage modifyvm $(VMNAME) --natpf1 "ssh,tcp,,$(SSH_HOST),,$(SSH_VM)"
	vboxmanage modifyvm $(VMNAME) --natpf1 "html,tcp,,$(HTML_HOST),,$(HTML_VM)"
	vboxmanage modifyvm $(VMNAME) --natpf1 "navi,tcp,,$(NAVI_HOST),,$(NAVI_VM)"

disks:
	@./title.sh "Creating VM disks"
	vboxmanage createhd --filename $(DISK_PATH) --size 31528 --format VDI
	vboxmanage storagectl $(VMNAME) --name "SATA Controller" --add sata --controller IntelAhci
	vboxmanage storageattach $(VMNAME) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  $(DISK_PATH)
	vboxmanage storagectl $(VMNAME) --name "IDE Controller" --add ide --controller PIIX4
	vboxmanage storageattach $(VMNAME) --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $(ISOMOD_PATH)
	vboxmanage modifyvm $(VMNAME) --boot1 disk --boot2 dvd --boot3 none --boot4 none

########## ISO ###########
$(TEMP_DIR):
	@./title.sh "Decompresing iso into temp folder"
	mkdir $(TEMP_DIR)
	@xorriso -indev "$(ISO_PATH)" -osirrox on -extract / "$(TEMP_DIR)"
	chmod -R +w $(TEMP_DIR)

$(ISOMOD_PATH): $(ISO_PATH)
	@./title.sh "rebuilding iso"
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


########## FILES ###########
config/preseed.cfg:
	@./title.sh "Creating preseed.cfg"
	@sed \
		-e 's|<LANGUAGE>|$(LANGUAGE)|g' \
		-e 's|<COUNTRY>|$(COUNTRY)|g' \
		-e 's|<LANG>|${LANG}|g' \
		-e 's|<KEYBOARD>|$(KEYBOARD)|g' \
		-e 's|<TIME_ZONE>|$(TIME_ZONE)|g' \
		-e 's|<CRYPTO>|$(CRYPTO)|g' \
		-e 's|<ROOTPASS>|$(ROOTPASS)|g' \
		-e 's|<USER>|$(USER)|g' \
		-e 's|<PASS>|$(PASS)|g' \
		templates/preseed.cfg > config/preseed.cfg
	@cp config/preseed.cfg $(TEMP_DIR)/preseed.cfg

config/txt.cfg:
	@./title.sh "Creating txt.cfg"
	@sed \
		-e 's|<HOSTNAME>|$(HOSTNAME)|g' \
		templates/txt.cfg > config/txt.cfg
	@cp config/txt.cfg $(TEMP_DIR)/isolinux/txt.cfg

config/isolinux.cfg:
	@./title.sh "Copying isolinux.cfg"
	@cp templates/isolinux.cfg config/isolinux.cfg
	@cp config/isolinux.cfg $(TEMP_DIR)/isolinux/isolinux.cfg

config/isohdpfx.bin:
	@./title.sh "Copying isohdpfx.bin"
	wget -O isolinux.deb  http://ftp.de.debian.org/debian/pool/main/s/syslinux/isolinux_6.04\~git20190206.bf6db5b4+dfsg1-3_all.deb
	ar x isolinux.deb
	tar -xf data.tar.xz ./usr/lib/ISOLINUX/isohdpfx.bin --strip-components=4
	mv isohdpfx.bin config/isohdpfx.bin
	rm data.tar.xz
	rm control.tar.xz
	rm debian-binary
	rm isolinux.deb

# VM SETUP files
config/sudo_rules.conf:
	@./title.sh "Creating sudo_rules"
	@sed \
		-e 's|<USER>|$(USER)|g' \
		templates/sudo_rules > config/sudo_rules.conf
	@cp config/sudo_rules.conf $(TEMP_DIR)/sudo_rules.conf

~/.ssh/vm_ed25519.pub:
	@./title.sh "Creating key pairs"
	@ssh-keygen -f ~/.ssh/vm_ed25519 -t ed25519 -q -N ""
	@cp ~/.ssh/vm_ed25519.pub $(TEMP_DIR)/vm_ed25519.pub

config/monitoring.sh:
	@./title.sh "Copying monitoring.sh"
	@cp templates/monitoring.sh config/monitoring.sh
	@cp config/monitoring.sh $(TEMP_DIR)/monitoring.sh
