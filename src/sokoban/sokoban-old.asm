;==========================
;          PROG_1
;==========================

[bits 16]                           ; tell NASM to assemble 16-bit code
[org 0x7c00]

              ; video memory
              mov bx, 0xb800
              mov es, bx

              
game_loop:    mov di, 0x0000
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
              
              xor bx, bx
              
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
              xor byte [box + bx], cl
              sub bx, 2
              ;pusha
              and cl, byte [box + bx]
              cmp cl, 0
              jne move_down
              popa
              and cl, byte [map + bx]
              cmp cl, 0
              jne move_down

              call clear_box
              sub bx, 2
              or byte [box + bx], cl
              jmp game_loop

box_down:
              ; 28 byte (x4 160)
              call clear_box
              xor byte [box + bx], cl
              add bx, 2
              pusha
              and cl, byte [box + bx]
              cmp cl, 0
              jne move_up
              popa
              and cl, byte [map + bx]
              cmp cl, 0
              jne move_up

              call clear_box
              add bx, 2
              or byte [box + bx], cl
              jmp game_loop



box_right:    call clear_box
              xor byte [box + bx], cl
              shr cx, 1
              pusha
              and cl, byte [box + bx]
              cmp cl, 0
              jne move_left
              popa
              
              
              and cl, byte [map + bx]
              cmp cl, 0
              jne move_left


              call clear_box
              shr cx, 1
              or byte [box + bx], cl
              jmp game_loop

box_left:     call clear_box
              xor byte [box + bx], cl
              shl cx, 1
              pusha
              and cl, byte [box + bx]
              cmp cl, 0
              jne move_right
              popa
              call clear_box
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

clear_player: mov bl, byte [player_row]
              and word [box + bx], 0x00ff
              ret

set_player:   mov bl, byte [player_row]
              mov cx, word [player_col]
              or word [box + bx], cx
              ret

clear_box:    call set_player
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
write_col:    push ax
              mov dl, bl
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
              mov ax, 0xe1b2
              stosw
              jmp write_next
print_box:    cmp word [es:di], 0x0c09
              je highlight
              mov ax, 0x06fe
              stosw
              jmp write_next
highlight:    mov ax, 0x02fe
              stosw
              jmp write_next
print_dest:   cmp bh, 1
              je print_player
              mov ax, 0x0c09
              stosw
              jmp write_next
print_player: mov ax, 0x0e01
              stosw
              jmp write_next
write_next:   pop ax
              shr bl, 1
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














