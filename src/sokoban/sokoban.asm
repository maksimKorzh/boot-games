[bits 16]                                                 ; assemble 16-bit code
[org 0x7c00]                                              ; a number to calculate the address of variables
;=========================================================================================================
;                                               MAIN LOOP
;=========================================================================================================
game_loop:              mov di, 0x0000                    ; point DI to top left on screen
                        call clear_screen                 ; clear video memory
                        mov di, 0x04b8                    ; print DI one row below board
                        mov si, player                    ; point SI to player array
                        mov word [low_byte], 0x0004       ; set low byte to box destination graphics index
                        mov word [high_byte], 0x0006      ; set high byte to player grphics index
                        call print_map                    ; print box destination tiles and player
                        mov di, 0x04b8                    ; print DI one row below board
                        mov si, map                       ; point SI to map array
                        mov word [low_byte], 0x0000       ; set low byte to box graphics index
                        mov word [high_byte], 0x0002      ; set high byte to wall graphics index
                        call print_map                    ; print boxex and walls
                        mov ah, 0x00                      ; BIOS code to get a keystroke
                        int 0x16                          ; wait for keystroke from a user
                        mov byte [direction], 0x00        ; reset player direction
                        xor bx, bx
                        mov bl, byte [player_row]
                        cmp ah, 0x48                      ; on up arrow key pressed
                        je move_up                        ; move player up
                        cmp ah, 0x50                      ; on down arrow key pressed
                        je move_down                      ; move player down
                        cmp ah, 0x4b                      ; on left arrow key pressed
                        je move_left                      ; move player to the left
                        cmp ah, 0x4d                      ; on right arrow key pressed
                        je move_right                     ; move player to the right
                        jmp game_loop                     ; repeat game loop
;=========================================================================================================
;                                               CONTROLS
;=========================================================================================================
; set direction
; detect collisions
; move player
; mov box

move_up:                ;or byte [direction], 0x01        ; set direction to "up"
                        and word [player + bx], 0xff00
                        sub byte [player_row], 0x02       ; shift bit in player col 1 step to the right
                        sub bl, 2                         ; adjust player row look up index
                        mov dl, byte [player_col]
                        or byte [player + bx], dl
                        jmp game_loop

move_down:              or byte [direction], 0x02         ; set direction to "down"
                        and word [player + bx], 0xff00
                        add byte [player_row], 0x02       ; shift bit in player col 1 step to the right
                        add bl, 2                         ; adjust player row look up index
                        mov dl, byte [player_col]
                        or byte [player + bx], dl
                        jmp game_loop

move_left:              or byte [direction], 4
                        jmp detect_collisions
box_left:               mov cl, byte [player_col]
                        shl cl, 2
                        push cx
                        and cl, dl                        ; does box hit a box?
                        cmp cl, 0
                        jne game_loop
                        pop cx
                        and cl, dh                        ; does box hit a wall?
                        cmp cl, 0
                        jne game_loop
                        xor cx, cx
                        mov ch, byte [player_col]
                        shl ch, 1
                        xor word [map + bx], cx
                        shl ch, 1
                        or word [map + bx], cx
player_left:            and word [player + bx], 0xff00
                        shl byte [player_col], 1          ; shift bit in player col 1 step to the right
                        mov dl, byte [player_col]
                        or byte [player + bx], dl
                        jmp game_loop


move_right:             or byte [direction], 8
                        jmp detect_collisions             
box_right:              mov cl, byte [player_col]
                        shr cl, 2
                        push cx
                        and cl, dl                        ; does box hit a box?
                        cmp cl, 0
                        jne game_loop
                        pop cx
                        and cl, dh                        ; does box hit a wall?
                        cmp cl, 0
                        jne game_loop
                        xor cx, cx
                        mov ch, byte [player_col]
                        shr ch, 1
                        xor word [map + bx], cx
                        shr ch, 1
                        or word [map + bx], cx
player_right:           and word [player + bx], 0xff00
                        shr byte [player_col], 1          ; shift bit in player col 1 step to the right
                        mov dl, byte [player_col]
                        or byte [player + bx], dl
                        jmp game_loop


detect_collisions:      mov al, byte [direction]
                        mov cl, byte [player_col]
                        cmp al, 8
                        je shift_right
                        cmp al, 4
                        je shift_left
coll_cont:              mov dx, word [map + bx]
                        push cx
                        and cl, dl                        ; does player hit a wall?
                        cmp cl, 0                         ; if so then skip moving
                        jne game_loop                     ; and go back to the game loop
                        pop cx
                        and cl, dh                        ; does player hit a box?
                        cmp cl, 0                         ; if so then 
                        jne box_dir
                        cmp al, 8
                        je jump_right
                        cmp al, 4
                        je jump_left
box_dir:                cmp al, 8
                        je box_right
                        cmp al, 4
                        je box_left
shift_right:            shr cl, 1
                        jmp coll_cont
shift_left:             shl cl, 1
                        jmp coll_cont
jump_right:             jmp player_right
jump_left:              jmp player_left

;=========================================================================================================
;                                               PRINT MAP
;=========================================================================================================
print_map:              add di, 0x90                      ; point DI to next row
                        lodsw                             ; load next row to AX (AH=box, AL=wall)
                        cmp al, 0xee                      ; are there no more rows left?
                        je done_print                     ; if so printing is done
                        mov dh, 0x80                      ; init bit to detect map elements (10000000b)
                        mov cl, 0                         ; reset column counter
print_tile:             push ax                           ; preserve current row of map/player                        
                        mov bx, word [high_byte]          ; init high byte graphics
                        mov dl, dh                        ; copy box/wall elements detection bit
                        and dl, al                        ; detect wall/player on the map
                        cmp dl, 0                         ; found a one?
                        jne draw_tile                     ; if so then print it
                        mov bx, word [low_byte]           ; draw graphics for low byte next
                        mov dl, dh                        ; copy destination/player elements detection bit
                        and dl, ah                        ; detect box/destination on the map
                        cmp dl, 0                         ; found one?
                        jne draw_tile                     ; if so then print it
                        mov bx, word [high_byte]          ; draw graphics for high byte next
                        add di, 2                         ; print nothing but skip empty tile
next_tile:              pop ax                            ; restore current row map/player
                        shr dh, 1                         ; shift detection bit to the next tile
                        inc cl                            ; increment tile counter
                        cmp cl, 8                         ; if no more tiles left in the row
                        je print_map                      ; go to next row
                        jmp print_tile                    ; otherwise print next tile in the row
done_print:             ret                               ; return from procedure
draw_tile:              cmp word [es:di], 0x0c09          ; box occupies it's destination tile
                        je highlight_box                  ; if so then highlight it
                        mov ax, word [graphics + bx]      ; pick up tile graphics
                        stosw                             ; draw tile
                        jmp next_tile                     ; continue print routine
highlight_box:          mov ax, 0x02fe                    ; pick up highlight graphics
                        stosw                             ; highlight box
                        jmp next_tile                     ; continue print routine
;=========================================================================================================
;                                              CLEAR SCREEN
;=========================================================================================================
clear_screen:           mov bx, 0xb800                    ; point BX to video memory
                        mov es, bx                        ; point ES to video memory
clear_next_byte:        mov ax, 0x0000                    ; zero word to clear chars and attrs        
                        stosw                             ; erase cell in video memory (clear screen)
                        cmp di, 0x0fa0                    ; visidhe screen has been exhausted?
                        je done_clear                     ; if so then return
                        jmp clear_next_byte               ; otherwise clear next byte
done_clear:             ret                               ; retyrn from procedure
;=========================================================================================================
;                                               GAME DATA
;=========================================================================================================
graphics:               dw 0x06fe                         ; box tile
                        dw 0xe1b2                         ; wall tile
                        dw 0x0c09                         ; box destination tile
                        dw 0x0e01                         ; player tile
low_byte:               dw 0x00                           ; low byte graphics index (wall/player)
high_byte:              dw 0x00                           ; high byte graphics index (box/destination)
player_col:             db 0x20                           ; current player's X position (00100000b)
player_row:             db 0x04                           ; current player's Y position (player + 4b)
map:                    dw 0x003e                         ; boxes: 00000000    walls: 00111110
                        dw 0x00e2                         ;        00000000           11100010
                        dw 0x1082                         ;        00010000           10000010
                        dw 0x08e2                         ;        00001000           11100010
                        dw 0x08b2                         ;        00001000           10110010
                        dw 0x00a3                         ;        00000000           10100011
                        dw 0x5c81                         ;        01011100           10000001
                        dw 0x0081                         ;        00000000           10000001
                        dw 0x00ff                         ;        00000000           11111111
                        dw 0x00ee                         ; end of map array marker
player:                 dw 0x0000                         ; dest:  00000000   player: 00000000
                        dw 0x0000                         ;        00000000           00000000
                        dw 0x4020                         ;        01000000           00100000
                        dw 0x0400                         ;        00000100           00000000
                        dw 0x4000                         ;        01000000           00000000
                        dw 0x0800                         ;        00001000           00000000
                        dw 0x1200                         ;        00010010           00000000
                        dw 0x0800                         ;        00001000           00000000
                        dw 0x0000                         ;        00000000           00000000
                        dw 0x00ee                         ; end of player array marker
direction:              db 0x00                           ; 0001 - up, 0010 - down, 0100 - left, 1000 - right
;=========================================================================================================
;                                            BYTES PADDING
;=========================================================================================================
times 510 - ($-$$)      db 0                              ; boot sector padding
                        dw 0xaa55                         ; BIOS boot signature
times 1474560 - ($-$$)  db 0                              ; floppy image padding















