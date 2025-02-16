# Use Live CD to boot
sudo su # Switch to root
fdisk -l # Get names of root, boot & EFI partition names. you can also use blkid

# unencrypt LUKS partition
cryptsetup luksOpen /dev/nvme0n1p8 root_encrypted
# mount btrfs root partition
mount -t btrfs -o subvol=@,compress=zstd:1 /dev/mapper/root_encrypted /mnt 
# check fedora version
cat /mnt/etc/fedora-release

# mount boot partition
mount /dev/nvme0n1p6 /mnt/boot
# mount EFI partition
mount /dev/nvme0n1p1 /mnt/boot/efi

ls /mnt/boot/efi/EFI # should show all OS names

# mount the virtual filesystems that the system uses to communicate with processes and devices
for fs in proc sys run dev sys/firmware/efi/efivars ; do mount -o bind /$fs /mnt/$fs ; done

# enter chroot
chroot /mnt

# fix /etc/fstab entries if needed and mount all others
mount -a

# Now you can do all the work e.g. fix grub
dnf reinstall shim-* grub2-*
grub2-mkconfig -o /boot/grub2/grub.cfg # Regenerate grub2

# Check BIOS boot details [ Note: this command won't work if you are inside chroot. ]
efibootmgr -v
# In case you need to create new entry in BIOS
efibootmgr -c -d /dev/nvme0n1p1 -p 1 -L Fedora -l '\EFI\fedora\grubx64.efi' # or, shimx64.efi
# To delete entry from efibootmgr use: efibootmgr -b <#entry> -B

exit
# Now you can reboot
