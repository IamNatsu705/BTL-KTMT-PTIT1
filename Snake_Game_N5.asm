.model small
.stack 100h
.data 
    ; Constain
    yellow  equ 0Eh
    white   equ 07h
    gray    equ 08h
    green   equ 02h
    blue    equ 01h
    red     equ 04h  
    lightgreen equ 0Ah
                
    score_text  db 'SCORE : ',3 dup(?), 0
    menuMode db 0 ; 0 = menu, 1 = game , 2 = win , 3 = lose
    
    score_str   db '0','1', 0
        
    ; MENU    
    top_line_str  20h,20h,12 dup(196), ' SNAKE GAME ',13 dup(196), '$' 
    titTle1    db 'WELCOME TO OUR SNAKE GAME!', 0
    titTle2    db 'WE ARE GROUP NUMBER 5', 0
    titTle3    db 'PRESS ENTER TO PLAY GAME!', 0
    titTle4    db 'PRESS ENTER TO PLAY AGAIN!', 0
    
    win_text   db 'YOU ARE WINNER!', 0
    lose_text  db 'YOU HAVE LOST!', 0
    ; GAME
  
    snake_max_length   db 10
    snake_length       db 1
    snake_x            db 10 , snake_max_length dup(0)
    snake_y            db 12 , snake_max_length dup(0)   
    snake_tailx        db 10
    snake_taily        db 12
    food_x             db 0
    food_y             db 0
    food_eaten         db 0     ; Tao thuc an moi 
    eat_tail           db 0  
    snake_dir          db 2     ; 0=up, 1=down, 2=right, 3=left
  
.code
main proc
    mov ax, @data
    mov ds, ax
    mov ax, 0B800h
    mov es, ax

    ; An con tro man hinh
    mov ah, 1
    mov ch, 2Bh
    mov cl, 0Bh
    int 10h 

    call draw_title_screen ; Goi den ham ve man hinh menu

main_loop:

.check_menu_mode:    ; Kiem tra trang thai
    cmp menuMode, 0     ;menumode = 0 -> dang o menu
    je wait_in_menu
    cmp menuMode,2      ;menumode = 2 -> o man hinh nguoi choi thang
    je wait_winner
    cmp menuMode,3      ;menumode = 3 -> o man hinh nguoi choi thua
    je wait_loser      
    
    ; Che do choi game (gamemmode = 1)
    mov ah, 1           ; kiem tra xem co bam phim nao khong
    int 16h
    jz skip_input       ; khong co -> cap nhat game

    mov ah, 0           ; doc ma tu phim
    int 16h
    call GameController ; goi ham GameController de xu ly game

skip_input:  ; Cap nhat game
    call updateGame
    jmp main_loop

wait_winner:
    ; Cho nhan nut ENTER de bat dau game.
    mov ah, 1
    int 16h
    jz wait_winner      

    mov ah, 0
    int 16h
    cmp al, 13 ; so sanh voi nut ENTER
    jne wait_winner                            -

    ; Bat dau game
    mov menuMode, 1
    call draw_games
    jmp main_loop

wait_loser:
    ; Cho nhan nut ENTER de bat dau game.
    mov ah, 1
    int 16h
    jz wait_loser

    mov ah, 0
    int 16h
    cmp al, 13 ; so sanh voi nut ENTER
    jne wait_loser

    ; Bat dau game
    mov menuMode, 1
    call draw_games
    jmp main_loop
    
wait_in_menu:
    ; Cho nhan nut ENTER de bat dau game.
    mov ah, 1
    int 16h
    jz wait_in_menu

    mov ah, 0
    int 16h
    cmp al, 13 ; so sanh voi nut ENTER
    jne wait_in_menu

    ; Bat dau game
    mov menuMode, 1
    call draw_games
    jmp main_loop

main endp

; --------------------------------------------------------

GameController proc   ; Xu ly huong di cua ran
    cmp ah, 48h  ; mui ten len
    je game_up
    cmp ah, 50h  ; mui ten xuong
    je game_down
    cmp ah, 4Bh  ; mui ten trai
    je game_left
    cmp ah, 4Dh  ; mui ten phai
    je game_right
    cmp al, 1Bh  ; ESC: thoat game
    je back_menu
    ret

game_up:
    cmp snake_dir, 1     ; Dang di xuong thi khong cho di nguoc len
    je skip_game_input
    mov snake_dir, 0     ; gan huong len
    jmp skip_game_input
game_down:               ; Dang di len thi khong cho di xuong
    cmp snake_dir, 0
    je skip_game_input
    mov snake_dir, 1     ; gan huong xuong
    jmp skip_game_input
game_left:
    cmp snake_dir, 2     ; Dang di phai thi khong cho di nguoc sang trai
    je skip_game_input
    mov snake_dir, 3     ; gan huong trai
    jmp skip_game_input
game_right:
    cmp snake_dir, 3     ; Dang di trai thi khong cho di nguoc sang phai
    je skip_game_input
    mov snake_dir, 2     ; gan huong phai
skip_game_input:
    ret                  ; ket thuc thu tuc

back_menu: ; tro ve menu(menumode = 0)
   
    call draw_title_screen 
    mov menuMode, 0
    ret
GameController endp

updateGame proc
    call move_snake       ; goi ham xu ly huong di cua ran
    call check_collision  ; goi ham check va cham 
    call draw_snake       ; goi ham ve con ran
    call update_snake     ; goi ham cap nhat con ran
    ret
updateGame endp

draw_title_screen proc  ; ve menu
    call clear_screen 
    call draw_border1
    
    mov dh, 5
    mov dl, 8
    lea si, titTle1
    mov bl, yellow 
    call print  
    
    mov dh, 7
    mov dl, 10
    lea si, titTle2
    mov bl, yellow
    call print 
    
    mov dh, 18
    mov dl, 9
    lea si, titTle3
    mov bl, yellow
    call print 
    ret
draw_title_screen endp

draw_games proc         ; Ve giao dien luc choi game
    call clear_screen 
    call draw_border1 
    call draw_border2
    call generate_food
    call draw_score
    call draw_snake 
    call print_score  
    
    ret
draw_games endp

draw_snake proc          ; ve ran     
    cmp snake_length, 1
    je .draw_head        ; neu ran chi co dau -> ve dau bo qua phan than
   
    mov dl, snake_x[1]               
    mov dh, snake_y[1]   ; lay hoanh do va tung do cua doan than dau tien
    mov bl, lightgreen           
    mov al, snake_dir    ; lay huong di cua ran
    cmp al, 0             
    je .set_ver          ; di len/xuong -> "|"
    cmp al, 1         
    je .set_ver          ; di ngang -> "-"
    jmp .set_hor

.set_ver:
    mov al, 179      ; |
    jmp .print_body

.set_hor:         
    mov al, 196      ; - 
    
.print_body:
    call print_char  ; ve ky tu
    
.draw_head:            ; ve dau ran
    
    mov dl, snake_x[0]                
    mov dh, snake_y[0]   ; lay x va y cua dau ran               
    mov bl, lightgreen           
    mov al, snake_dir
    add al, 24           ; cong the 24 de hien ra ky tu huong di phu hop tren man hinh
    call print_char      ; in
    
    
    ; xoa phan duoi cu
    mov dl, snake_tailx
    mov dh, snake_taily
    mov bl, lightgreen
    mov al, ' '          ; dung ky tu " " de xoa duoi cu
    call print_char      ; in
    
.done_draw_snake:    
    ret
draw_snake endp

move_snake proc    
    cmp snake_length, 1
    je move_head           ; neu ran chi co dau -> di chuyen phan dau
       
    xor cx,cx
    mov cl, snake_length
    dec cl                 ; tru 1 de dung index
    mov si, cx             ; si la chi so cuoi cung trong mang ran
    mov al, snake_x[si]
    mov snake_tailx, al
    mov al,snake_y[si]
    mov snake_taily, al    ; luu lai x va y de xoa sau nay 
    
    ;dich chuyen tung phan than ve vi tri phan truoc no
    move_address:
        mov al, snake_x[si-1]
        mov snake_x[si], al
        mov al, snake_y[si-1]
        mov snake_y[si], al     ; lay x va y chap nhat vao doan hien tai
        dec si                  ; giam si de tiep tuc lap
        jz move_head            ; neu den doan dau thi nhay qua phan di chuyen dau
        jmp move_address        
    
    
    ;dich chuyen dau ran      
    move_head:    
        mov al, snake_x[0]
        mov bl, snake_y[0]   ;lay x va y hien tai cua phan dau
        cmp snake_dir, 0
        je .up               ; huong len = 0
        cmp snake_dir, 1
        je .down             ; huong xuong = 1
        cmp snake_dir, 2
        je .right            ; huong sang phai = 2
        cmp snake_dir, 3
        je .left             ; huong sang trai = 3
    
    .up:
        cmp bl, 2            
        je .set_wall_up      ; neu den vien tuong ben tren -> xuong tuong duoi
        dec bl               ; khong thi giam tung do de di len
        jmp .set_head
    .down:
        cmp bl, 23           
        je .set_wall_down    ; neu xuong vien tuong ben duoi -> di len tren
        inc bl               ; khong thi tang tung do de di xuong
        jmp .set_head                                                                                                           
    .left:
        cmp al, 1
        je .set_wall_left    ; neu den vien ben trai -> sang tuong ben phai
        dec al               ; giam hoanh do -> sang trai
        jmp .set_head
    .right:              
        cmp al, 39
        je .set_wall_right   ; neu den vien ben phai -> sang tuong ben trai
        inc al               ; tang hoanh do -> sang phai
        jmp .set_head
    
    ; cac set wall de neu ran cham vien tuong thi qua phia doi dien    
    .set_wall_up:
        mov bl, 23
        jmp .set_head
    .set_wall_down:
        mov bl, 2      
        jmp .set_head
    .set_wall_left:
        mov al, 39
        jmp .set_head
    .set_wall_right:
        mov al, 1
     
     ;cap nhat vi tri moi cho dau
    .set_head:
        mov snake_x[0], al
        mov snake_y[0], bl       
          
        ret
move_snake endp

check_collision proc    ;ham check va cham
    cmp snake_length, 4     
    jb .check_food           ; neu do dai ran < 4 -> check food
    
    mov dl, snake_x[0]
    mov dh, snake_y[0]       ; lay x va y cua dau ran
    call calc_di             ; tinh offset tren man hinh video tuong ung toa do
    mov cx, di               ; luu ket qua vao cx
    push ds
    mov ax, es
    mov ds, ax 
    mov di, cx               ; lay lai offset vi tri dau ran
    mov al, [di]     ; AL = Ky tu tai vi tri di   
    cmp al, 179      ; |
    je .next_check1
    cmp al, 196      ; -
    je .next_check1  
    jmp .next_check2

    .next_check1:  ; check 1 kiem tra ran dung vao than
        pop ds
        jmp .tail  ; ran dung vao than -> lose
    .next_check2:  ; check 2 kiem tra ran khong va cham than
        pop ds
        jmp .check_food    
    
    ;xu ly trung duoi    
    .tail:
        mov eat_tail, 1  ; an trung than
        jmp .done_check  ; nhay den ket thuc
    
    ;check dau ran co thuc an khong
    .check_food:    
        mov al, snake_x[0]      
        cmp al, food_x     ; so sanh x dau ran voi x thuc an      
        jne .done_check    ; khong bang -> khong an
        
        mov al, snake_y[0]      
        cmp al, food_y          
        jne .done_check    ; check y tuong tu nhu x   
        
        mov food_eaten, 1  ; neu x va y trung -> danh dau da an
        ret
        
    .done_check:
        mov food_eaten, 0  ; luon reset neu khong an 
        ret
check_collision endp

update_snake proc
    cmp food_eaten, 1
    je .draw_new_food    ; an thuc an -> ve thuc an moi
    cmp eat_tail, 1
    je .lose             ; neu dung trung duoi -> thua
    mov al, snake_length
    cmp al, snake_max_length  ; check do dai cua ran neu bang max -> thang
    je .win
    jmp .done_update_snake    ; ket thuc neu khong trong cac truong hop tren
    
    .draw_new_food:
        call generate_food    ; ham tao thuc an
        inc snake_length      ; tang do dai cua ran       
        mov al, snake_length 
        cmp al, 9             
        jb add_score_digit    ; neu < 9 -> chi can tang chu so hang don vi 
        je make_score_10      ; neu = 10 -> xu ly dac biet thanh "10" 
        jmp add_next_digit    ; tang diem
    
    add_score_digit:         
        inc score_str[1]      ; tang so hang don vi
        jmp .nextcheck        
        
    make_score_10:
        mov score_str[0], '1'
        mov score_str[1], '0' 
        jmp .nextcheck    
        
    add_next_digit:
        inc score_str[1]    
        
    .nextcheck:
        call print_score      ; in diem
        jmp .done_update_snake 
        
    .lose:
        mov menuMode, 3     
        call reset_game         ; reset game
        call draw_lose_screen   ; ve giao dien luc thua
        ret
    .win:
        
        mov menuMode, 2 
        call reset_game
        call draw_win_screen    ; ve giao dien luc thang
          
    .done_update_snake:
        
        xor cx,cx
        mov cl, snake_length
        dec cl   
        mov si,cx 
        mov al, snake_x[si]
        mov snake_tailx, al 
        mov al,snake_y[si] 
        mov snake_taily, al
                 
     ret 
update_snake endp

generate_food proc  ; tao thuc an moi
    ; Gen X-Y
    .gen_food:
        call random_number  ; goi ham nay de tao thuc an ngau nhien
        xor cx,cx
        mov cl, snake_length 
        dec cl                  ;tru 1 de dung index
        mov si, cx              ;si de duyet qua tung khuc than
        
        ; lap de kiem tra tung khuc than ran
        .loop_snake_tail:
            mov al, snake_x[si]
            cmp al, food_x         ; lay x ran so sanh x thuc an
            jne .loop_sn1          ; khac -> kiem tra tiep
            mov al, snake_y[si]    ; neu x trung, kiem tra y tuong tu nhu x
            cmp al, food_y
            jne .loop_sn1
            jmp .gen_food          ; tao random thuc an moi
            .loop_sn1: 
            dec si                 ; giam si de xet khuc than tiep
            jns .loop_snake_tail   ; si >= 0 -> lap tiep
   call draw_food       ; ve thuc an
    ret
generate_food endp 

draw_food proc       ; ve thuc an
    mov dl, food_x
    mov dh, food_y
    mov bl, yellow           
    mov al, 207
    call print_char  
    ret
draw_food endp
                   
reset_game proc      ; reset game
    mov eat_tail, 0
    mov snake_length, 1
    mov snake_dir,2
    mov snake_x[0], 10
    mov snake_y[0], 12  
    mov snake_tailx, 10
    mov snake_taily, 12  
    mov score_str[0], '0'
    mov score_str[1], '1'
    ret
reset_game endp      

draw_win_screen proc   ; ve giao dien luc thang
    call clear_screen
    call draw_border1
    
    mov dl, 13
    mov dh, 10
    lea si, win_text
    mov bl , yellow
    call print
    mov dh, 18
    mov dl, 9
    lea si, titTle4
    mov bl, yellow
    call print 
    ret
draw_win_screen endp

draw_lose_screen proc
    call clear_screen   ; ve giao dien luc thua
    call draw_border1
     
    mov dl, 13
    mov dh, 10
    lea si, lose_text
    mov bl , yellow
    call print
    mov dh, 18
    mov dl, 9
    lea si, titTle4
    mov bl, yellow
    call print 
    ret
draw_lose_screen endp
 
draw_score proc         ; ve giao dien diem so
    mov bl, yellow
    mov dl, 44     
    mov dh, 6
    lea si, score_text
    call print
    ret
draw_score endp  

print_score proc        ; in diem so
    mov bl, yellow
    mov dl, 52
    mov dh, 6
    lea si, score_str
    call print
    ret
print_score endp

calc_di proc         ; tinh vi tri tren man hinh
    ; dl,dh - > di
    push ax
    push cx
    xor ax,ax
    mov al, dl
    shl ax, 1
    mov cx, ax

    mov ax, 160
    mul dh
    add ax, cx
    mov di, ax
    pop cx
    pop ax 
    ret
calc_di endp

print_char proc  ; in ky tu
    ; input:
    ; al = char
    ; dl = col
    ; dh = row
    ; bl = color   
    call calc_di
    mov ah, bl   ; in ra man hinh ky tu + mau
    stosw        ; ax gom al va ah vao es:di, di += 2
    ret
print_char endp

print proc   ;in chuoi ky tu
    ; input:
    ; si address of text
    ; dl col
    ; dh row
    ; bl color   
    call calc_di 
    mov ah, bl    ; ah = mau
.nextt:
    lodsb    ; [ds:si] -> al
    or al, al    ; al = 0 -> ket thuc chuoi
    jz .done     
    stosw    ; ax -> [es:di]
    jmp .nextt   ;tiep tuc voi ky tu tiep
.done:
    ret
print endp

draw_border proc 
    ; Ve vien tu (ch,cl) -> (dh,dl)
    ; bh Color
    
    mov ah, 0
    mov al, 3
    int 10h

    mov ah, 6
    mov al, 0 
    mov bh, 0FFh

    mov ch, 0
    mov cl, 0
    mov dh, 0
    mov dl, 80
    int 10h

    mov ch, 2
    mov cl, 0
    mov dh, 24
    mov dl, 0
    int 10h

    mov ch, 24
    mov cl, 0
    mov dh, 24
    mov dl, 79
    int 10h

    mov ch, 1
    mov cl, 79
    mov dh, 24
    mov dl, 79
    int 10h

    ret
draw_border endp

draw_border1 proc   ; khung vien cua ran
    ; Ve vien tu (ch,cl) -> (dh,dl)
    ; bh Color
    
    lea dx, top_line_str 
    mov ah, 9
    int 21h
    
    mov ah, 0
    mov al, 3
    int 10h

    mov ah, 6
    mov al, 0 
    mov bh, 0FFh

    mov ch, 1
    mov cl, 0
    mov dh, 24
    mov dl, 40
    int 10h

    mov bh, 0

    mov ch, 2
    mov cl, 1
    mov dh, 23
    mov dl, 39
    int 10h

    ret
draw_border1 endp 

draw_border2 proc    ; khung vien diem so
    ; Ve vien tu (ch,cl) -> (dh,dl)
    ; bh Color

    mov ah, 0
    mov al, 3
    int 10h

    mov ah, 6
    mov al, 0 
    mov bh, 0FFh

    mov ch, 2
    mov cl, 42
    mov dh, 10
    mov dl, 78
    int 10h

    mov bh, 0

    mov ch, 3
    mov cl, 43
    mov dh, 9 
    mov dl, 77
    int 10h

    ret
draw_border2 endp

clear_screen proc   ; xoa man hinh
    mov ax, 0600h
    mov bh, 07h
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret
clear_screen endp

random_number proc  ; ham random thuc an
    mov ah, 00h
    int 1Ah        ; Read time
    mov al, dl    
    mov ah, dh     
    and al, 36      ; 2 -> 38
    add al, 2
    and ah, 19       ; 2 -> 21    
    add ah, 2
    mov food_x, al
    mov food_y, ah
    ret
random_number endp

exit_game proc
    mov ah, 4Ch
    int 21h
exit_game endp

end main
