;----------------------------------------------------------------------------
; CalculateBMI:PROC ** REV. B ** marikaz
;----------------------------------------------------------------------------
; GENERAL MATH. FORMULA: BMI = WEIGHT[kg] / HEIGHT[m]^2
;
; IN PROC. ! WEIGHT * 10 IN GP.ASM !:
; BMI = WEIGHT [kg] * 1000 / HEIGHT [cm] ^2
;
; RETURN: AH = DIGIT AFTER DECIMAL POINT
;         AL = BMI
;----------------------------------------------------------------------------

        .MODEL TINY
        .CODE

PUBLIC CalculateBMI
EXTRN height:WORD,weight:WORD

CalculateBMI    PROC
                LOCALS
                push bx cx dx
                xor dx,dx
                mov ax,weight   ;weight already multiplied by 10 in GP.ASM
                mov bx,1000     ;so here times 1000
                mul bx
                push ax
                push dx
                mov ax,height
                mov bx,ax
                mul bx          ;height^2 [cm]!
                mov bx,ax
                pop dx
                pop ax
                div bx          ;AX = BMI
                ;--- 2 digits after the decimal point ---
                push ax
                mov ax,dx
                xor dx,dx
                mov cx,100d
                mul cx
                div bx
                aam
                mov bx,ax    ;.xx in BH:BL
                pop ax
                cmp bl,5
                jb @@1       ;round
                add bh,1
                cmp bh,10
                jne @@1
                xor bh,bh
                add ax,1
           @@1:
                mov ah,bh
                pop dx cx bx
                ret
CalculateBMI    ENDP
                END
