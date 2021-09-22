;=========================================================================================================
;                             SOKOBANOS by Code Monkey King (bootable version)
;=========================================================================================================
[bits 16]                                                 ; assemble 16-bit code
[org 0x7c00]                                              ; variables adress offset
;=========================================================================================================
;                                               MAIN LOOP
;=========================================================================================================
game_loop:              call clear_screen                 ; clear video memory
                        mov si, player                    ; point SI to player array
                        mov byte [low_byte], 0x04         ; set low byte to box destination graphics index
                        mov byte [high_byte], 0x06        ; set high byte to player grphics index
                        call print_map                    ; print box destination tiles and player 
                        mov si, map                       ; point SI to map array
                        mov byte [low_byte], 0x00         ; set low byte to box graphics index
                        mov byte [high_byte], 0x02        ; set high byte to wall graphics index
                        call print_map                    ; print boxex and walls
                        mov si, map                       ; saves bytes during effective address lookup
                        mov di, player                    ; saves bytes during effective address lookup
                        xor bx, bx                        ; BX is a board row counter, reset it
                        mov ah, 0x00                      ; BIOS code to get a keystroke
                        int 0x16                          ; wait for keystroke from a user
                        cmp ah, 0x48                      ; on up arrow key pressed
                        je move_up                        ; move player up
                        cmp ah, 0x50                      ; on down arrow key pressed
                        je move_down                      ; move player down
                        cmp ah, 0x4b                      ; on left arrow key pressed
                        je move_left                      ; move player to the left
                        cmp ah, 0x4d                      ; on right arrow key pressed
                        je move_right                     ; move player to the right
;=========================================================================================================
;                                               CONTROLS
;=========================================================================================================
move_up:                call clear_player                 ; extra clean up to avoid dehighlighting boxes
                        sub byte [player_row], 0x02       ; decrease player Y offset row index by 2 bytes
                        call clean_up                     ; clean up graphics
                        cmp cl, 1                         ; if player hits the wall
                        je move_down                      ; drop back to the initial position
                        cmp dl, 1                         ; if player hits the box
                        je box_up                         ; try to push box up
                        jmp game_loop                     ; repeat game loop
box_up:                 sub bx, 2                         ; decrease player Y offset row index by 2 bytes
                        pusha                             ; preserve player X offset bit
                        and cx, word [si + bx]            ; detect anoter box
                        cmp ch, 0                         ; if a box hits a box
                        jne move_down                     ; then drop player back to initial position
                        popa                              ; restore player X offset bit
                        shr cx, 8                         ; move player X offset bit from CH to CL
                        and cl, byte [si + bx]            ; detect the wall
                        cmp cl, 0                         ; if box hits a wall
                        jne move_down                     ; then drop player back to initial position
                        call clear_box                    ; otherwise clear box on initial position
                        sub bx, 2                         ; calculate new place for it
                        jmp draw_box                      ; and push it there
move_down:              call clear_player                 ; extra clean up to avoid dehighlighting boxes
                        add byte [player_row], 0x02       ; increase player Y offset row index by 2 bytes
                        call clean_up                     ; clean up graphics
                        cmp cl, 1                         ; if player hits the wall
                        je move_up                        ; drop back to the initial position
                        cmp dl, 1                         ; if player hits the box
                        je box_down                       ; try to push box up
                        jmp game_loop                     ; repeat game loop
box_down:               add bx, 2                         ; increase player Y offset row index by 2 bytes
                        pusha                             ; preserve player X offset bit
                        and cx, word [si + bx]            ; detect anoter box
                        cmp ch, 0                         ; if a box hits a box
                        jne move_up                       ; then drop player back to initial position
                        popa                              ; restore player X offset bit
                        shr cx, 8                         ; move player X offset bit from CH to CL
                        and cl, byte [si + bx]            ; detect the wall
                        cmp cl, 0                         ; if box hits a wall
                        jne move_up                       ; then drop player back to initial position
                        call clear_box                    ; otherwise clear box on initial position
                        add bx, 2                         ; calculate new place for it
                        jmp draw_box                      ; and push it there
move_left:              shl byte [player_col], 1          ; shift player X offset bit one position left
                        call clean_up                     ; clean up graphics
                        cmp cl, 1                         ; if player hits a wall
                        je move_right                     ; then drop back to initial position
                        cmp dl, 1                         ; if player hits a box
                        je box_left                       ; then try to push it
                        jmp game_loop                     ; repeat game loop
box_left:               shl ch, 1                         ; shift player X offset bit one position left
                        pusha                             ; preserve player X offset bit
                        and cx, ax                        ; detect anoter box
                        cmp ch, 0                         ; if a box hits a box
                        jne move_right                    ; then drop player back to initial position
                        popa                              ; restore player X offset bit position
                        shr cx, 8                         ; move player X offset bit from CH to CL
                        and cl, al                        ; detect the wall
                        cmp cl, 0                         ; if box hits a wall
                        jne move_right                    ; then drop player back to initial position
                        call clear_box                    ; otherwise clear box on initial position
                        shl cx, 1                         ; calculate new place for it
                        jmp draw_box                      ; and push it there
move_right:             shr byte [player_col], 1          ; shift player X offset bit one position right
                        call clean_up                     ; clean up graphics
                        cmp cl, 1                         ; if player hits a wall
                        je move_left                      ; then drop back to initial position
                        cmp dl, 1                         ; if player hits a box
                        je box_right                      ; then try to push it
                        jmp game_loop                     ; repeat game loop

box_right:              shr ch, 1                         ; shift player X offset bit one position right
                        pusha                             ; preserve player X offset bit
                        and cx, ax                        ; detect anoter box
                        cmp ch, 0                         ; if a box hits a box
                        jne move_left                     ; then drop player back to initial position
                        popa                              ; restore player X offset bit position
                        shr cx, 8                         ; move player X offset bit from CH to CL
                        and cl, al                        ; detect the wall
                        cmp cl, 0                         ; if box hits a wall
                        jne move_left                     ; then drop player back to initial position
                        call clear_box                    ; otherwise clear box on initial position
                        shr cx, 1                         ; calculate new place for it
                        jmp draw_box                      ; and push it there
;=========================================================================================================
;                                         RENDER DYNAMIC ELEMENTS
;=========================================================================================================
clean_up:               call clear_player                 ; erase player
                        call set_player                   ; draw player
                        call collision                    ; detect collisions
                        ret                               ; return from procedure
clear_player:           mov bl, byte [player_row]         ; init player Y offset row
                        and byte [di + bx], 0x00          ; erase player
                        ret                               ; return from procedure
set_player:             mov bl, byte [player_row]         ; init player Y offset row
                        mov cl, byte [player_col]         ; init player X offset bit
                        or byte [di + bx], cl             ; draw player
                        ret                               ; return from procedure
clear_box:              call set_player                   ; draw player
                        shl cx, 8                         ; move player X offset from CL to CH
                        xor word [si + bx], cx            ; clear box
                        ret                               ; return from procedure
draw_box:               or word [si + bx], cx             ; draw moved box
                        jmp game_loop                     ; repeat game loop
;=========================================================================================================
;                                           COLLISION DETECTION
;=========================================================================================================
collision:              mov ch, byte [player_col]         ; init player X offset to detect a wall
                        and ch, byte [si + bx]            ; detect a wall
                        cmp ch, 0                         ; if player is standing on the wall square
                        jne hit_wall                      ; then we hit a wall
                        mov cl, 0                         ; clean up CX's lower bit for later bitwise AND
                        mov ch, byte [player_col]         ; init player X offset to detect a box
                        and cx, word [si + bx]            ; detect a box
                        cmp ch, 0                         ; if player is standing on the box square
                        jne hit_box                       ; then we hit the box
                        mov dl, 0                         ; reset hit the box flag
                        ret                               ; return from the procedure
hit_wall:               mov cl, 1                         ; CL flags that we hit a wall
                        ret                               ; return from the procedure
hit_box:                mov dl, 1                         ; DL flags that we hit a box
                        ;call clear_box                   ; use the side effect of initializing player row
                        ;xor word [si + bx], cx           ; restore box, reduce main effect of clear_box
                        mov ax, word [si + bx]            ; preserve player row on the board
                        ret                               ; return from procedure
;=========================================================================================================
;                                               PRINT MAP
;=========================================================================================================
print_map:              mov di, 0x04b8                    ; point DI to one row below the board
print_row:              add di, 0x90                      ; point DI to next row
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
                        add di, 2                         ; print nothing but skip empty tile
next_tile:              pop ax                            ; restore current row map/player
                        shr dh, 1                         ; shift detection bit to the next tile
                        inc cl                            ; increment tile counter
                        cmp cl, 8                         ; if no more tiles left in the row
                        je print_row                      ; go to next row
                        jmp print_tile                    ; otherwise print next tile in the row
done_print:             ret                               ; return from procedure
draw_tile:              cmp byte [es:di], 0x09            ; box occupies it's destination tile
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
clear_screen:           xor di, di                        ; point DI to top left on screen
                        mov bx, 0xb800                    ; point BX to video memory
                        mov es, bx                        ; point ES to video memory
clear_next_byte:        mov ah, 0x00                      ; zero word to clear chars and attrs        
                        stosw                             ; erase cell in video memory (clear screen)
                        cmp di, 0x0fa0                    ; visidhe screen has been exhausted?
                        je done_clear                     ; if so then return
                        jmp clear_next_byte               ; otherwise clear next byte
done_clear:             ret                               ; retyrn from procedure
;=========================================================================================================
;                                               GAME DATA
;=========================================================================================================
graphics:               dw 0x06fe                         ; box tile
                        dw 0x71b2                         ; wall tile
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
                        db 0xee                           ; end of map array marker
player:                 dw 0x0000                         ; dest:  00000000   player: 00000000
                        dw 0x0000                         ;        00000000           00000000
                        dw 0x4020                         ;        01000000           00100000
                        dw 0x0400                         ;        00000100           00000000
                        dw 0x4000                         ;        01000000           00000000
                        dw 0x0800                         ;        00001000           00000000
                        dw 0x1200                         ;        00010010           00000000
                        dw 0x0800                         ;        00001000           00000000
                        dw 0x0000                         ;        00000000           00000000
                        db 0xee                           ; end of player array marker
;=========================================================================================================
;                                            BYTES PADDING
;=========================================================================================================
times 510 - ($-$$)      db 0                              ; boot sector padding
                        dw 0xaa55                         ; BIOS boot signature
times 1474560 - ($-$$)  db 0                              ; floppy image padding















