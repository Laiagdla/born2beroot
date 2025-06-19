# Change Kernel Options
echo \"
default auto
label auto
    menu label ^Automated Install
    kernel /install.amd/vmlinuz
    append vga=788 initrd=/install.amd/initrd.gz auto=true debian-installer/probe/verbose=true DEBCONF_DEBUG=5 priority=critical url=file:///cdrom/preseed.cfg netcfg/hostname=$HOSTNAME netcfg/get_hostname=unasigned_hostname netcfg/get_domain=
\" > \"$EXTRACT_DIR/isolinux/txt.cfg\"

# Change Init Options
echo \"
path
prompt 0
timeout 0
include menu.cfg
default auto
\" > \"$EXTRACT_DIR/isolinux/isolinux.cfg\"

cd \"$EXTRACT_DIR\"
genisoimage -o \"$ISO_PATH\" -r -J -no-emul-boot -boot-load-size 4 -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat .
isohybrid \"$ISO_PATH\"

# Clean
rm -rf \"$EXTRACT_DIR\"
"
