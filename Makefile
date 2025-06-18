
DEBIAN_URL	= https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso
ISO_PATH	= $(HOME)/sgoinfre/debian.iso
MACHINENAME	?= debian_vm
DISK_PATH	= $(HOME)/sgoinfre/$(MACHINENAME)_disk.vdi

$(ISO_PATH):
	wget $(DEBIAN_URL) -O $(ISO_PATH)

create: $(ISO_PATH)
	vboxmanage createvm --name $(MACHINENAME) --ostype "Debian_64" --register --basefolder `pwd`

preseed:
	python3 -m http.server --bind 0.0.0.0
	echo "url=http://192.168.122.1:8000/preseed.cfg"
	echo "vmlinuz initrd=initrd.gz auto=true priority=critical url=http://192.168.122.1:8000/preseed.cfg --- quiet"
	echo "https://tinyurl.com/preseedlaia"

memnet:
	vboxmanage modifyvm $(MACHINENAME) --ioapic on
	vboxmanage modifyvm $(MACHINENAME) --memory 1024
	vboxmanage modifyvm $(MACHINENAME) --nic1 nat
	vboxmanage modifyvm $(MACHINENAME) --natpf1 "ssh,tcp,,4242,,4242"

disk:
	vboxmanage createhd --filename $(DISK_PATH) --size 30800 --format VDI
	vboxmanage storagectl $(MACHINENAME) --name "SATA Controller" --add sata --controller IntelAhci
	vboxmanage storageattach $(MACHINENAME) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  $(DISK_PATH)

iso:
	vboxmanage storagectl $(MACHINENAME) --name "IDE Controller" --add ide --controller PIIX4
	vboxmanage storageattach $(MACHINENAME) --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $(ISO_PATH)

clipboard:
	VBoxManage modifyvm $(MACHINENAME) --clipboard-mode=bidirectional

boot:
	vboxmanage modifyvm $(MACHINENAME) --efi on
	vboxmanage modifyvm $(MACHINENAME) --boot1 disk --boot2 dvd --boot3 none --boot4 none

setup: memnet disk iso boot clipboard

start:
	vboxmanage startvm $(MACHINENAME)

startheadless:
	vboxheadless --startvm $(MACHINENAME)

stop:
	vboxmanage controlvm $(MACHINENAME) poweroff

check:
	vboxmanage list vms

del_disk:
	rm $(DISK_PATH)

remove: del_disk
	vboxmanage unregistervm $(MACHINENAME) --delete

make re: stop remove create setup start

.PHONY: create re memnet disk iso boot start startheadless check remove del_disk setup clipboard stop
