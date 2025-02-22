[bits 16]
[org 0x7c00]

; set up segments
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

; print message
mov si, boot_msg
call print_string

; infinite loop (for now)
jmp $

; print routine
print_string:
   push ax
   mov ah, 0x0e
.loop:
   lodsb
   test al, al
   jz .done
   int 0x10
   jmp .loop
.done:
   pop ax
   ret 

; data
boot_msg db "Booting KatOS...", 13, 10, 0

; boot signature
times 510-($-$$) db 0
dw 0xaa55