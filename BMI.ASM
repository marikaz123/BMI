;----------------------------------------------------------------------------
; ** BMI v1.1 ** (c)1997 'marikaz'                                   MOD2410
;----------------------------------------------------------------------------
; Zrodlo: Wikipedia
;

        .MODEL TINY
        .CODE

PUBLIC height,weight
EXTRN GetParam:PROC
EXTRN CalculateBMI:PROC
EXTRN SEP:ABS,DECP:ABS

AST  EQU 3Bh
AMT  EQU 39h
AUW  EQU 30h
ANOR EQU 20h
AOVW EQU 60h
AOB  EQU 40h
AOB2 EQU 4Eh
AOB3 EQU 4Ch

JUMPS

ORG 100h
Main            PROC
                call GetParam
                jc errParam
                call CalculateBMI
                mov cx,ax
                xor ah,ah
                mov bx,10
                div bl
                or ax,3030h
                mov WORD PTR _bmi,ax  ;ok, little endian
                mov al,ch
                or al,30h
                mov _adp,al
                ;---------------------
                xor ax,ax
                xor dx,dx
                mov al,cl
                mov bx,10
                mul bx
                add al,ch
                adc ah,0
                ;---------------------
                cmp ax,160
                ja c_mt
                mov si,OFFSET ust
                mov pMsg,OFFSET msg1
                mov t_fl,1
                jmp eoc
         c_mt:
                cmp ax,169
                ja c_uw
                mov si,OFFSET umt
                mov pMsg,OFFSET msg1
                mov t_fl,2
                jmp eoc
         c_uw:
                cmp ax,184
                ja c_nor
                mov si,OFFSET uw
                mov pMsg,OFFSET msg1
                mov t_fl,3
                jmp eoc
         c_nor:
                cmp ax,249
                ja c_ovw
                mov si,OFFSET nor
                mov pMsg,OFFSET msg2
                mov t_fl,4
                jmp eoc
         c_ovw:
                cmp ax,299
                ja c_ob
                mov si,OFFSET ovw
                mov pMsg,OFFSET msg3
                mov t_fl,5
                jmp eoc
          c_ob:
                cmp ax,349
                ja c_ob2
                mov si,OFFSET ob
                mov pMsg,OFFSET msg4
                mov t_fl,6
                jmp eoc
         c_ob2:
                cmp ax,399
                ja c_ob3
                mov si,OFFSET ob2
                mov pMsg,OFFSET msg5
                mov t_fl,7
                jmp eoc
         c_ob3:
                mov si,OFFSET ob3
                mov pMsg,OFFSET msg6
                mov t_fl,8
eoc:            ;----------------------
                mov di,OFFSET info
                call CopyStr
                mov [di],0a0dh
                mov BYTE PTR [di+2],'$'
                mov dx,OFFSET message
                mov ah,9
                int 21h
                call AColor
                mov dx,OFFSET msg0
                mov ah,9
                int 21h
                mov dx,pMsg
                mov ah,9
                int 21h
exit:
                mov al,t_fl
                mov ah,4ch
                int 21h
errParam:
                mov dx,OFFSET info
                mov ah,9
                int 21h
                jmp exit
Main            ENDP

CopyStr         PROC
                LOCALS
                cmp BYTE PTR [si],0
                je @@eop
                movsb
                jmp CopyStr
         @@eop:
                ret
CopyStr         ENDP

AColor          PROC
                LOCALS
                mov ah,3
                mov bh,0
                int 10h
                sub dh,1
                add dl,30
                xor ax,ax
                mov al,dh
                shl ax,5
                mov bx,ax
                shl ax,2
                add ax,bx
                xor dh,dh
                shl dx,1
                add ax,dx
                mov di,ax
                dec di ;atrybyt
                push es
                mov ax,0b800h
                mov es,ax

                mov al,t_fl
                cmp al,1
                jnz @@2
                mov dl,AST
                jmp @@pc
           @@2:
                cmp al,2
                jnz @@3
                mov dl,AMT
                jmp @@pc
           @@3:
                cmp al,3
                jnz @@4
                mov dl,AUW
                jmp @@pc
           @@4:
                cmp al,4
                jnz @@5
                mov dl,ANOR
                jmp @@pc
           @@5:
                cmp al,5
                jnz @@6
                mov dl,AOVW
                jmp @@pc
           @@6:
                cmp al,6
                jnz @@7
                mov dl,AOB
                jmp @@pc
           @@7:
                cmp al,7
                jnz @@8
                mov dl,AOB2
                jmp @@pc
           @@8:
                mov dl,AOB3
@@pc:
                mov es:[di],dl
                cmp BYTE PTR es:[di-1],'!' ;marker
                je @@exi
                add di,2
                jmp @@pc
         @@exi:
                add di,2
                mov es:[di],dl
                pop es
                ret
AColor          ENDP

pMsg    DW ?
height  DW ?
weight  DW ?
t_fl    DB ?

ust     DB 'WYGLODZENIE!',0
umt     DB 'WYCHUDZENIE!',0
uw      DB 'NIEDOWAGA!',0
nor     DB 'W NORMIE!',0
ovw     DB 'NADWAGA!',0
ob      DB 'OTYLOSC I STOPNIA!',0
ob2     DB 'OTYLOSC II STOPNIA!',0
ob3     DB 'OTYLOSC III STOPNIA!',0

msg0    DB 13,10,'RYZYKO CHOROB TOWARZYSZACYCH OTYLOSCI: $'
msg1    DB 'Minimalny, ale zwiekszony poziom ryzyka' ,13,10
        DB 'wystapienia innych problemow zdrowotnych.',13,10,'$'
msg2    DB 'Minimalne ryzyko.',13,10,'$'
msg3    DB 'Srednie ryzyko.',13,10,'$'
msg4    DB 'Wysokie ryzyko.',13,10,'$'
msg5    DB 'Bardzo wysoki poziom ryzyka!',13,10,'$'
msg6    DB 'Ekstremalnie wysoki poziom ryzyka!',13,10,'$'

message DB 13,10,9,'Twoj BMI to: '
   _bmi DB '##,'
   _adp DB '# ->  '
info    LABEL ;oba teksty nigdy nie sa wyswietlane na raz.
        DB "*** BMI v1.1 * (c)1997 'marikaz' ***",13,10
        DB 'https://en.wikipedia.org/wiki/Body_mass_index',13,10,13,10
        DB '    BMI.COM <WZROST',SEP,'WAGA>',13,10,13,10
        DB 'WZROST  [cm], zakres: 135..235',13,10
        DB '  WAGA  [kg], max. 1 znak po kropce, zakres: '
        DB '35',DECP,'0..180',DECP,'0',13,10
        DB '$'

        END Main
