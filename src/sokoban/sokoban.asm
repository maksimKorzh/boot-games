;==========================
;          PROG_1
;==========================

[bits 16]                           ; tell NASM to assemble 16-bit code

%define SHELL_SEGMENT 0x800         ; shell segment
[org 0x7c00]

              ; init video mode
start         mov ah, 0x00
              mov al, 0x03
              int 0x10

              ; hide cursor
              mov ah, 1
              mov ch, 32
              int 10h

              ; video memory
              mov bx, 0xb800
              mov es, bx

              
game_loop:    mov di,0x0b8
              call clear_screen

              mov bh, 0       ; map flag
              mov di, 0x4b8   ; print at center 548
              mov si, map
              call print_board

              ; print boxes
              mov bh, 1       ; boxes flag
              mov di, 0x4b8   ; print at center 548
              mov si, box
              call print_board
              
              mov ah, 0x00
              int 0x16
              
              cmp ah, 0x48
              je move_up
              
              cmp ah, 0x50
              je move_down
              
              cmp ah, 0x4b
              je move_left
              
              cmp ah, 0x4d
              je move_right

update:       shr cx, 1
              
                 
              jmp game_loop

move_up:      call clear_player
              sub byte [player_row], 0x02
              call set_player
              call collision
              cmp cl, 1
              je move_down
              cmp dl, 1
              je box_up
              jmp game_loop

move_down:    call clear_player
              add byte [player_row], 0x02
              call set_player
              call collision
              cmp cl, 1
              je move_up
              cmp dl, 1
              je box_down
              jmp game_loop

move_left:    call clear_player
              shl word [player_col], 1
              call set_player
              call collision
              cmp cl, 1
              je move_right
              cmp dl, 1
              je box_left
              jmp game_loop

move_right:   call clear_player
              shr word [player_col], 1
              call set_player
              call collision
              cmp cl, 1
              je move_left
              cmp dl, 1
              je box_right
              jmp game_loop

box_up:       call clear_box
              sub bx, 2
              or byte [box + bx], cl
              jmp game_loop

box_down:     xor bx, bx
              mov bl, byte [player_row]
              mov cx, word [player_col]
              shr cx, 8
              
              
              add bx, 2
              
              and cl, byte [box + bx]
              cmp cl, 0
              jne move_up
              ;and cl, byte [map + bx]
              ;cmp cl, 0
              ;jne move_up
              

              call clear_box
              add bx, 2
              or byte [box + bx], cl
              jmp game_loop



box_right:    ;call set_player
              call clear_box
              shr cx, 1
              or byte [box + bx], cl
              jmp game_loop

box_left:     call clear_box
              shl cx, 1
              or byte [box + bx], cl
              jmp game_loop

collision:    mov cx, word [player_col]
              and ch, byte [map + bx]
              cmp ch, 0
              jne hit_wall
              mov cl, 0
              mov cx, word [player_col]
              and ch, byte [box + bx]
              cmp ch, 0
              jne hit_box
              mov dl, 0
              ret
hit_wall:     mov cl, 1
              ret
hit_box:      mov dl, 1
              ret

quit:         mov ah, 0x00
              mov al, 0x03
              int 0x10
              jmp 0x800:0x0000

clear_player: xor bx, bx
              mov bl, byte [player_row]
              and word [box + bx], 0x00ff
              ret

set_player:   xor bx, bx
              mov bl, byte [player_row]
              mov cx, word [player_col]
              or word [box + bx], cx
              ret

clear_box:    xor bx, bx
              mov bl, byte [player_row]
              mov cx, word [player_col]
              shr cx, 8
              xor byte [box + bx], cl
              ret

clear_screen: mov ax, 0x0000
              stosw
              cmp di, 0xb48
              je done_clear
              jmp clear_screen

done_clear:   ret

print_board:
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
player_col dw 0x2000
map dw 0x003e, 0x00e2, 0x4082, 0x04e2, 0x40b2, 0x08a3, 0x1281, 0x0881, 0x00ff, 0x00ee
box dw 0x0000, 0x0000, 0x2010, 0x0008, 0x0008, 0x0000, 0x005c, 0x0000, 0x0000, 0x00ee,

times 510 - ($ - $$) db 0           ; fill trailing zeros to get exactly 512 bytes long binary file
dw 0xaa55

times (2880 * 512) - ($-$$) db 0














