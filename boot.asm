[bits 16]
[org 0x7c00]
   
jmp start

; data section
gdt_start:
gdt_null:
   dd 0x0
   dd 0x0

gdt_code:
   dw 0xffff
   dw 0x0
   db 0x0
   db 10011010b
   db 11001111b
   db 0x0

gdt_data:
   dw 0xffff
   dw 0x0
   db 0x0
   db 10010010b
   db 11001111b
   db 0x0

gdt_end:

gdt_descriptor:
   dw gdt_end - gdt_start - 1
   dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

real_msg db "Starting in 16-bit Real Mode...", 13, 10, 0
protected_msg db "Now in 32-bit Protected Mode!", 0

start:
   ; set up segments
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7c00

   ; print real mode message
   mov si, real_msg
   call print_string

   ; prepare for protected mode
   cli
   
   ; load GDT register
   xor ax, ax
   mov ds, ax
   lgdt [gdt_descriptor]
   
   ; switch to protected mode
   mov eax, cr0
   or eax, 0x1
   mov cr0, eax

   ; far jump to flush pipeline and load CS
   jmp dword CODE_SEG:init_pm

; real mode print routine
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

[bits 32]
; initialize protected mode
init_pm:
   mov ax, DATA_SEG
   mov ds, ax
   mov ss, ax
   mov es, ax
   mov fs, ax
   mov gs, ax

   mov ebp, 0x90000
   mov esp, ebp

   ; print protected mode message
   mov esi, protected_msg
   call print_string_pm

   jmp $ ; hang

; protected mode print routine
print_string_pm:
   push eax
   push edx
   mov edx, 0xb8000
.loop:
   mov al, [esi]
   mov ah, 0x0f
   cmp al, 0
   je .done
   mov [edx], ax
   add esi, 1
   add edx, 2
   jmp .loop
.done:
   pop edx
   pop eax
   ret

; boot signature
times 510-($-$$) db 0
dw 0xaa55