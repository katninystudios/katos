# TODO: replace hardcoded iso name dynamically
# TODO: maybe allow other vms? unsure if i care to support other ones besides qemu, tho.
qemu-system-x86_64 -m 4096 -smp 4 -cdrom out/katos-2026.06.02-x86_64.iso -boot d