;==========================
;          PROG_1
;==========================

[bits 16]                           ; tell NASM to assemble 16-bit code

%define SHELL_SEGMENT 0x800         ; shell segment
[org 0x7c00]

              ; init video mode
start:        mov ah, 0x00
              mov al, 0x03
              int 0x10

              ; hide cursor
              mov ah, 1
              mov ch, 32
              int 10h

              ; video memory
              mov bx, 0xb800
              mov es, bx

              ; print map
game_loop:    mov bh, 0       ; map flag
              mov di, 0x4b8   ; print at center 548
              mov si, map
              call print_board
and word [box + 4], 0x00ff
              ; print boxes
              mov bh, 1       ; boxes flag
              mov di, 0x4b8   ; print at center 548
              mov si, box
              call print_board
              
              
              
              mov ah, 0x00
              int 0x16
              
              
              
              cmp ah, 0x48
              je move_up
              
              ;cmp ah, 0x01              
              ;je quit
                 
              jmp game_loop

move_up:      
              mov word [box + 4], 0x20ff
              jmp game_loop

quit:         mov ah, 0x00
              mov al, 0x03
              int 0x10
              jmp 0x800:0x0000
              

print_board:  cld

write_row:    add di, 0x90
              lodsw
              cmp al, 0xee
              je end_write
              mov bl, 0x80
              mov cl, 0
write_col:    mov dl, bl
              and dl, al
              cmp dl, 0
              jne print_wall
              mov dl, bl
              and dl, ah
              cmp dl, 0
              jne print_dest
              add di, 2
              jmp write_next
print_wall:   cmp bh, 1
              je print_box
              push ax
              mov ax, 0xe1b2
              stosw
              pop ax
              jmp write_next
print_box:    cmp word [es:di], 0x0c09
              je highlight
              push ax
              mov ax, 0x06fe
              stosw
              pop ax
              jmp write_next
highlight:    push ax
              mov ax, 0x02fe
              stosw
              pop ax              
              jmp write_next
print_dest:   cmp bh, 1
              je print_player
              push ax
              mov ax, 0x0c09
              stosw
              pop ax
              jmp write_next
print_player: push ax
              mov ax, 0x0e01
              stosw
              pop ax
              jmp write_next
write_next:   shr bl, 1
              inc cl
              cmp cl, 8
              je write_row
              jmp write_col

end_write:    ret


player_row db 0x04
player_col db 0x20
map dw 0x003e, 0x00e2, 0x4082, 0x04e2, 0x40b2, 0x08a3, 0x1281, 0x0881, 0x00ff, 0x00ee
box dw 0x0000, 0x0000, 0x2010, 0x0008, 0x0008, 0x0000, 0x005c, 0x0000, 0x0000, 0x00ee,

times 512 - ($ - $$) db 0           ; fill trailing zeros to get exactly 512 bytes long binary file














