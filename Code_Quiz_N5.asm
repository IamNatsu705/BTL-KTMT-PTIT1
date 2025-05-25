.model small
.stack 100h
.data
    row db 25
    column db 80
    char_border db 80 dup('-'),'$'
    color_grey db 07h
    color_green db 02h
    bar db "== QUIZ ASSEMBLY ==",13,10,'$'
    
    infor db '       Mo ta:',13,10
          db '            _Co 10 cau hoi',13,10
          db '            _Moi cau hoi co 4 cau tra loi A,B,C,D va co 1 dap an dung',13,10
          db '            _Moi cau tra loi dung nguoi choi dc nhan 1 diem',13,10
          db 13,10,'       Thanh vien :',13,10
          db '            _Duong Xuan Quynh-B23DCCN705',13,10
          db '            _Hoang Trung Kien-B23DCCN459',13,10
          db '            _Nguyen Anh Duc-B23DCCN176',13,10,13,10,13,10
          db 13,10,'                Bam bat ky phim nao de choi ...$'
    spaces db 80 dup(' '),'$'
    
    q1  DB 15 dup(' '),"1. MOV AX, BX co chuc nang gi?",13,10,13,10
        DB 13,10,20 dup(' '),"A. AX -> BX",13,10
        DB 13,10,20 dup(' '),"B. BX -> AX",13,10
        DB 13,10,20 dup(' '),"C. Swap",13,10
        DB 13,10,20 dup(' '),"D. So sanh",13,10,'$'

    q2  DB 15 dup(' '),"2. Thanh ghi luu ket qua phep nhan?",13,10,13,10
        DB 13,10,20 dup(' '),"A. CX",13,10,13,10,20 dup(' '),"B. DX",13,10
        DB 13,10,20 dup(' '),"C. AX",13,10,13,10,20 dup(' '),"D. BX",13,10,'$'

    q3  DB 15 dup(' '),"3. INC CX co chuc nang gi?",13,10,13,10
        DB 13,10,20 dup(' '),"A. Giam CX",13,10
        DB 13,10,20 dup(' '),"B. Tang CX",13,10
        DB 13,10,20 dup(' '),"C. CX = 0",13,10
        DB 13,10,20 dup(' '),"D. Move vao CX",13,10,'$'

    q4  DB 15 dup(' '),"4. JMP co chuc nang gi?",13,10,13,10
        DB 13,10,20 dup(' '),"A. Nhan phim",13,10
        DB 13,10,20 dup(' '),"B. Nhay den dong lenh",13,10
        DB 13,10,20 dup(' '),"C. In man hinh",13,10
        DB 13,10,20 dup(' '),"D. Dung chuong trinh",13,10,'$'

    q5  DB 15 dup(' '),"5. INT 21h dung de?",13,10,13,10
        DB 13,10,20 dup(' '),"A. Ngat phan cung",13,10
        DB 13,10,20 dup(' '),"B. Goi ham DOS",13,10
        DB 13,10,20 dup(' '),"C. Doc bo dem",13,10
        DB 13,10,20 dup(' '),"D. Xoa RAM",13,10,'$'

    q6  DB 15 dup(' '),"6. Lenh CMP co chuc nang gi?",13,10,13,10
        DB 13,10,20 dup(' '),"A. Cong",13,10
        DB 13,10,20 dup(' '),"B. Tru",13,10
        DB 13,10,20 dup(' '),"C. So sanh",13,10
        DB 13,10,20 dup(' '),"D. Nhan",13,10,'$'

    q7  DB 15 dup(' '),"7. ORG 100h nghia la gi?",13,10,13,10
        DB 13,10,20 dup(' '),"A. Dia chi bat dau",13,10
        DB 13,10,20 dup(' '),"B. Thanh ghi AX",13,10
        DB 13,10,20 dup(' '),"C. Ngat",13,10
        DB 13,10,20 dup(' '),"D. Ket thuc",13,10,'$'

    q8  DB 15 dup(' '),"8. Cac thanh ghi AX, BX, CX, DX thuoc loai gi?",13,10,13,10
        DB 13,10,20 dup(' '),"A. Segment",1    3,10
        DB 13,10,20 dup(' '),"B. General purpose",13,10
        DB 13,10,20 dup(' '),"C. Pointer",13,10
        DB 13,10,20 dup(' '),"D. Control",13,10,'$'

    q9  DB 15 dup(' '),"9. LOOP su dung thanh ghi nao?",13,10,13,10
        DB 13,10,20 dup(' '),"A. AX",13,10
        DB 13,10,20 dup(' '),"B. BX",13,10
        DB 13,10,20 dup(' '),"C. CX",13,10
        DB 13,10,20 dup(' '),"D. DX",13,10,'$'

    q10 DB 15 dup(' '),"10. RET co chuc nang gi?",13,10,13,10
        DB 13,10,20 dup(' '),"A. Chay tiep",13,10
        DB 13,10,20 dup(' '),"B. Quay lai tu ham",13,10
        DB 13,10,20 dup(' '),"C. Khong lam gi",13,10
        DB 13,10,20 dup(' '),"D. Goi lenh moi",13,10,'$'

answers DB 'B','C','B','B','B','C','A','B','C','B'

questions DW OFFSET q1, OFFSET q2, OFFSET q3, OFFSET q4, OFFSET q5
         DW OFFSET q6, OFFSET q7, OFFSET q8, OFFSET q9, OFFSET q10
score db 0
scanf_ans db 13,10,13,10,25 dup(' '),"Nhap dap an cua ban : $"
ac db ' _AC_$'
wa db ' _WA_ & isAC : $'
result_label db 13,10,13,10,13,10,'                        >>> BAN DA DAT DUOC DIEM: $'
end_result db '/100$'
.code
main proc
    ;Khoi tao ds de truy cap data
    mov ax,@data
    mov ds,ax
    ;Goi cac thu tuc
    call print_UI
    call GetKey
    call Let_Play
    ;Ngat DOS
    mov ah, 4Ch
    int 21h
    main endp

print_UI proc
    ;Goi ra cac thu tuc in
    call print_border
    call print_title
    call print_infor
    ret
    print_UI endp

print_title proc
    ;di chuyn con tro text
    mov ah, 02h      
    mov bh, 0         
    mov dh, 3     ; row
    mov dl, 29      ; column
    int 10h
    ;in ra bar
    lea dx,bar
    mov ah,09h
    int 21h
    ret
    print_title endp

print_border proc
    ;di chuyen con tro text
    mov ah, 02h      
    mov bh, 0         
    mov dh, 1     ; row
    mov dl, 0      ; column
    int 10h
    ;in ra char_border
    mov ah, 09h
    lea dx,char_border
    int 21h
    ;tuong tu ben tren
    mov ah, 02h      
    mov bh, 0         
    mov dh, 24     ; row
    mov dl, 0      ; column
    int 10h
    
    mov ah, 09h
    lea dx,char_border
    int 21h
    
    ret
    print_border endp

print_infor proc
    ;di chuyen con tro text
    mov ah, 02h      
    mov bh, 0         
    mov dh, 5     ; row
    mov dl, 0      ; column
    int 10h
    ;in ra infor
    lea dx,infor
    mov ah,09h
    int 21h
    ret
    print_infor endp

GetKey proc
    ;dung man hinh de nhan phim
    mov ah, 00h
    int 16h
    ret
    GetKey endp

Clear_Screen proc
    ;di chuyen con tro text
    mov ah, 02h      
    mov bh, 0         
    mov dh, 5     ; row
    mov dl, 0      ; column
    int 10h
    ;in ra spaces tu dung 5 den 20
    mov cx,15
    lea dx,spaces
    mov ah,09h
    
    clear:
        int 21h
        loop clear
    ;tra con tro text ve vi tri in cau hoi
    mov ah, 02h      
    mov bh, 0         
    mov dh, 7     ; row
    mov dl, 0      ; column
    int 10h
        
    ret            
    Clear_Screen endp

To_upper proc
    ;chuyn ky tu thuong thanh ky tu hoa
    cmp bl,'a'
    jl complete
    sub bl,'a'
    add bl,'A'
complete:
    ret
To_upper endp

Let_Play proc
    ;khoi tao si la cau hoi hien tai va diem hien tai
    mov si, 0          
    mov score,0
;vong lap cac cau hoi
play:
    
    cmp si, 10 ;kiem tra xem het cau hoi chua        
    jge done
    ;xoa man hinh va in ra cau hoi tiep theo
    call Clear_Screen
    mov bx, si
    shl bx, 1                  
    mov dx, [questions + bx];lay dia chi cua cau hoi   
    mov ah, 09h
    int 21h
    ;Nhan cau hoi tu ban phim
    lea dx, scanf_ans
    mov ah, 09h
    int 21h
    
    mov ah, 01h
    int 21h
    ;Bien cau tra loi nhan duoc thanh chu in hoa
    mov bl, al                 
    call To_upper
    ;so sanh cau tra loi voi dap an
    mov al, answers[si]        
    cmp al, bl
    je true ;nhay den neu tra loi dung
    jmp false ;nhay den neu tra loi sai                              
true:
    ;in ra "AC"
    lea dx,ac
    mov ah,09h
    int 21h
    ;tang diem va dung man hinh sau do nhay den cau hoi tiep theo
    inc score
    CALL GetKey
    inc si
    jmp play
false:
    ;in ra "WA"
    lea dx,wa
    mov ah,09h
    int 21h
    ;in ra cau tra loi dung
    mov ah,02h
    mov dl,answers[si]
    int 21h
    ;dung de cho nhay den cau hoi tiep
    call GetKey
    inc si
    jmp play
;ket thuc 10 cau hoi va in ra dap an
done:
    ;xoa man hinh va di chuyen con tro text
    call Clear_Screen
    mov ah, 02h
    mov bh, 0
    mov dh, 10   
    mov dl, 20   
    int 10h
    ;in ra result_label
    lea dx, result_label
    mov ah, 09h
    int 21h
    ;so sanh diem vs 10
    cmp score, 10
    jne not_100
    ;neu diem bang 10 in ra 100
    mov dl, '1'
    mov ah, 02h
    int 21h
    mov dl, '0'
    int 21h
    mov dl, '0'
    int 21h
    jmp print_end

not_100:;neu diem nho hon 10
    mov dl,score
    add dl,'0'
    mov ah,02h
    int 21h
    mov dl,'0'
    int 21h
;in ra phan ket 
print_end:
    lea dx, end_result
    mov ah, 09h
    int 21h

    
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    int 21h

    call GetKey
    ret
Let_Play endp
