; boot sector from USB drive
; https://stackoverflow.com/questions/63099367/how-can-i-write-a-boot-sector-that-reads-data-from-the-usb-stick-that-its-on#63099834
; by 

;[bits 16]
;[org 0x7C00]

;    jmp 0x0000:start_16 ; ensure cs == 0x0000

;start_16:
;    ; initialise essential segment registers
;    xor ax, ax
;    mov ds, ax
;    mov es, ax



[bits 16]
[org 0x7C00]



;
;    Main code
;

; Clear segment registers, always necessary
mov ax, 0
mov ds, ax
mov es, ax

; set stack at 0x7C00, goes downwards addresses
xor ax, ax
cli         ; disable interrupts to update ss:sp atomically (AFAICT, only required for <= 286)
mov ss, ax
mov sp, 0x7C00
sti

; load string from sector2 to RAM
mov bx, 0x0000_7E00 ; Destination
mov cl, 2           ; Sector
call read_sector

; print loaded data
mov si, 0x0000_7E00
call print

; save source ;
mov cl, 3           ; Sector
mov ax, SOURCE
call save_source

;
;    CPU trap
;
jmp $

read_sector:
    ; Read sector 2 of this drive into memory
    mov ah, 2           ; Code to read data
    mov al, 1           ; Number of sectors to read
    mov ch, 0           ; Cylinder
    mov dh, 0           ; Head
    int 0x13            ; Fire in the hole!
    ret

save_source:
    mov ah, 0x03    ; save ;
    mov al, 1       ; Number of sectors to read
    mov ch, 0       ; Cylinder
    mov dh, 0       ; Head
    int 0x13
    jc .err
    ret
    
    .err:
        mov si, error_sector
        call print
        ret



;
;    Functions
;
print:
    cld
    mov ah, 0x0E

    .next_char:
    lodsb
    cmp al, 0
    je .end
    int 0x10
    jmp .next_char
    
    .end:
    ret

;
;    Padding and magic number
;
TIMES 510-($-$$) DB 0
DW 0xAA55

;
;    This is after the boot sector and so not initially loaded by the BIOS
;
DB 'Hello, world - from disc sector 2!', 0
SOURCE DB 'Hello, world - this would be duplicated on sector 3!', 0
error_sector DB 'failed writing sector!', 0
DB 0

; if you don't want your resulting file to be as big as a floppy, then comment the following line:
;times (1440 * 1024) - ($-$$) db 0 ; pad with zeroes to make a floppy-sized image

