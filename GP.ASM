;GetParam:PROC * REV. B * marikaz
;TASM /m /dCOMMDOT GP.ASM     => separator przecinek i kropka dziesietna

        .MODEL TINY
        .CODE

HMIN = 135
HMAX = 235
WMIN = 350    ;min. waga * 10
WMAX = 1800   ;max. waga * 10

IFDEF COMDOT
 SEP  EQU ','
 DECP EQU '.'
ELSE
 SEP  EQU ':'   ;separator
 DECP EQU ','   ;"kropka" dziesietma
ENDIF

PUBLIC GetParam
EXTRN height:WORD,weight:WORD

SKIPBC MACRO
       LOCAL nx,sk,ex
   nx: cmp BYTE PTR [si],9
       je sk
       cmp BYTE PTR [si],20h
       jne ex
   sk: inc si
       jmp nx
   ex:
       ENDM


GetParam        PROC
                mov si,80h
                cmp BYTE PTR [si],6
                jb @@err
                inc si
                SKIPBC
                call @GetNum
                jc @@err
                mov height,ax
                cmp BYTE PTR [si],SEP
                jne @@err
                inc si
                call @GetNum
                jc @@err
                mov weight,ax
                xor ax,ax ;na wypadek braku przecinka
                cmp BYTE PTR [si],DECP
                jne @@nDP
                inc si
                call @GetNum
                jc @@err
         @@nDP:
                push ax        ;po przecinku
                mov ax,weight  ;
                mov bx,10
                mul bx
                pop bx
                add bx,ax
                mov weight,bx
                SKIPBC
                cmp BYTE PTR [si],0dh
                jne @@err
                cmp height,HMIN
                jb @@err
                cmp weight,WMIN
                jb @@err
                cmp height,HMAX
                ja @@err
                cmp weight,WMAX
                ja @@err
                clc
                ret
         @@err:
                stc
                ret
GetParam        ENDP

@GetNum         PROC
                LOCALS
                push bp
                xor ax,ax
                xor dx,dx
                xor bp,bp
                mov bx,100
                mov cx,3
                jmp @@gd
          @@lp:
                cmp byte ptr [si],'0'
                jb @@ep
                mov ax,bx
                mov bx,10
                div bx
                mov bx,ax
          @@gd:
                lodsb
                cmp al,'0'
                jb @@ep
                cmp al,'9'
                ja @@er
                sub al,'0'
                mul bx
                add bp,ax
                loop @@lp
          @@ep:
                mov ax,bp
                div bx
                pop bp
                clc
                ret
          @@er:
                pop bp
                stc
                ret
@GetNum         ENDP
                END