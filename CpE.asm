Assume cs:code, ds:data, ss:stack

data segment 
; All variables defined within the data segment
exitmessage1 db 'You have arrived at floor $'
exitmessage2 db '. Have a nice day!$'
entrymessage db 'Please enter a floor: $'
addfloor db 'Enter another (y/n)? $'
invalidinput db 'Invalid input.$'
errormessage1 db 'Begin$'
errormessage2 db 'Idle$'
direction db ?
location db ?
upfloorcalls db ?
downfloorcalls db ?
insideelevator db ?
elevatorcalled db ?
portB db ?
portC db ?
data ends

stack segment  
;Stack size and the top of the stack defined in the stack segment
dw 1000 dup(?)
stacktop:
stack ends

code segment
begin:	
mov ax, data
mov ds,ax
mov ax, stack
mov ss,ax
mov sp, offset stacktop
; insert code

;;Possible ERROR?
;push si
;Mov si, offset errormessage1
;Call printmessage
;Call printnewline
;pop si
;;End error check message

;set i/o mode for A
mov Dx,143h
mov Al,02h
out DX,Al

;set all in
mov Dx,140h
mov Al,00h
out DX,Al
;sets Port A to input mode
mov DX, 143h
mov Al,03h
out DX,Al

;set i/o mode for B
mov Dx,143h
mov Al,02h
out DX,Al

;set all out
mov Dx,141h
mov Al,0FFh
out DX,Al
;sets Port B to control mode
mov DX, 143h
mov Al,03h
out DX,Al
mov DX,141h
;clears lights
mov AL,0FFh
out DX,AL

;set i/o mode for C
mov Dx,143h
mov Al,02h
out DX,Al

;set all out
mov Dx,142h
mov Al,0FFh
out DX,Al
;sets Port C to control mode
mov DX, 143h
mov Al,03h
out DX,Al
mov DX,142h
;clears lights
mov AL,0FFh
out DX,AL

;define initial floor at 1 and direction to up
mov direction, 00000001b
mov location, 00000100b
;define initial floor calls to be none
mov upfloorcalls, 11111111b
mov downfloorcalls, 11111111b
mov insideelevator, 00000000b
call updatePortC
call updatePortB
call changefloorlights

;start main program
body:
Jmp idle
endidlemethod:

;;Possible ERROR?
;push si
;Mov si, offset errormessage2
;Call printmessage
;Call printnewline
;pop si
;;End error check message

jmp arrivefloor
endarrivefloormethod:
jmp body
;end main program


;start arrivefloor
arrivefloor:
push ax
push bx
push cx
push dx
mov al, location
mov cl, 02h
ror al, cl
and al, insideelevator
cmp al, 0
jz noone
call exitmessage

noone:
cmp direction, 01b
jnz downcalls
mov al, location
mov cl, 02h
ror al, cl
not al
or al, upfloorcalls
cmp al, 11111111b
je morefloors
call pickuppersonup
jmp morefloors

downcalls:
mov al, location
mov cl, 03h
ror al, cl
not al
or al, downfloorcalls
cmp al, 11111111b
je morefloors
call pickuppersondown

morefloors:
cmp direction, 01b
jnz goingdown
cmp location,1000000b
je top
mov al, location
ror al, 1
mov bl, upfloorcalls
not bl
or bl, insideelevator
and al,bl
cmp al,0
jne moveup
mov al, location
and al,bl
cmp al,0
jne moveup
mov al, location
rol al,1
and al,bl
cmp al,0
jne moveup
mov al, location
mov cl,2h
rol al,cl
and al,bl
cmp al,0
jne moveup

top:
cmp location,100b
je bottom2
mov al, location
mov cl, 03h
ror al, cl
mov bl, upfloorcalls
not bl
or bl, insideelevator
and al,bl
cmp al,0
jne movedown
mov al, location
mov cl, 04h
ror al, cl
and al,bl
cmp al,0
jne movedown
mov al, location
mov cl, 05h
ror al, cl
and al,bl
cmp al,0
jne movedown
mov al, location
mov cl, 06h
ror al, cl
and al,bl
cmp al,0
jne movedown

bottom2:
mov al, location
mov cl, 02h
ror al, cl
not al
or al, downfloorcalls
cmp al, 11111111b
je nodown
mov direction, 00000010b
call updatePortC
call changefloorlights
;;Possible ERROR?
;push si
;Mov si, offset entrymessage
;Call printmessage
;Call printnewline
;pop si
;;End error check message
jmp noone
;;Infinite LOOP cause?

nodown:
mov al, location
mov cl, 03h
ror al, cl
mov bl, downfloorcalls
not bl
rol bl,01h
or bl, insideelevator
and al,bl
cmp al,0
jne godown
mov al, location
mov cl, 04h
ror al, cl
and al,bl
cmp al,0
jne godown
mov al, location
mov cl, 05h
ror al, cl
and al,bl
cmp al,0
jne godown
mov al, location
mov cl, 06h
ror al, cl
and al,bl
cmp al,0
jne godown
pop dx
pop cx
pop bx
pop ax
jmp endarrivefloormethod

godown:
mov direction, 00000010b
call updatePortC
call changefloorlights

jmp noone

goingdown:
cmp location,100b
je bottom
mov al, location
mov cl, 03h
ror al, cl
mov bl, downfloorcalls
not bl
rol bl,01h
or bl, insideelevator
and al,bl
cmp al,0
jne movedown
mov al, location
mov cl, 04h
ror al, cl
and al,bl
cmp al,0
jne movedown
mov al, location
mov cl, 05h
ror al, cl
and al,bl
cmp al,0
jne movedown
mov al, location
mov cl, 06h
ror al, cl
and al,bl
cmp al,0
jne movedown

bottom:
cmp location,1000000b
je top2
mov al, location
ror al, 1
mov bl, downfloorcalls
not bl
rol bl,01h
or bl, insideelevator
and al,bl
cmp al,0
jne moveup
mov al, location
and al,bl
cmp al,0
jne moveup
mov al, location
rol al,1
and al,bl
cmp al,0
jne moveup
mov al, location
mov cl,2h
rol al,cl
and al,bl
cmp al,0
jne moveup

top2:
mov al, location
mov cl, 02h
ror al, cl
not al
or al, upfloorcalls
cmp al, 11111111b
je noup
mov direction, 00000001b
call updatePortC
call changefloorlights
;;Possible ERROR?
;push si
;Mov si, offset entrymessage
;Call printmessage
;Call printnewline
;pop si
;;End error check message
jmp noone
;;Infinite LOOP cause?

noup:
mov al, location
ror al, 1
mov bl, upfloorcalls
not bl
or bl, insideelevator
and al,bl
cmp al,0
jne goup
mov al, location
and al,bl
cmp al,0
jne goup
mov al, location
rol al,1
and al,bl
cmp al,0
jne goup
mov al, location
mov cl, 02h
rol al, cl
and al,bl
cmp al,0
jne goup
pop dx
pop cx
pop bx
pop ax
jmp endarrivefloormethod

goup:
mov direction, 00000001b
call updatePortC
call changefloorlights
jmp noone

moveup:
mov al, direction
not al
mov portC, al
call changefloorlights
mov al, location
rol al,01h
mov location,al
call delay
call delay
call updatePortC
call changefloorlights
call delay
jmp arrivefloor

movedown:
mov al, direction
not al
mov portC, al
call changefloorlights
mov al, location
ror al,01h
mov location,al
call delay
call delay
call updatePortC
call changefloorlights
call delay
jmp arrivefloor
;end arrivefloor


;start pickuppersonup
pickuppersonup:
push ax
push cx
mov al, location
mov cl, 02h
ror al, cl
or upfloorcalls, al
call updatePortB
call changefloorlights
call additionalfloor
pop cx
pop ax
ret
;end pickuppersonup


;start pickuppersondown
pickuppersondown:
push ax
push cx
mov al, location
mov cl, 03h
ror al, cl
or downfloorcalls, al
call updatePortB
call changefloorlights
call additionalfloor
pop cx
pop ax
ret
;end pickuppersondown


;start additionalfloor
additionalfloor:
push ax
push cx
push dx
push si
Mov ah,2
Mov cx,0h
Mov si, offset entrymessage

bac:
Call printmessage
Call printnewline

infloor:
Mov ah,1
Int 21h
call printnewline
call verifyfloorinput
cmp al, "1"
JNE floor2
or insideelevator, 1b

floor2:
cmp al, "2"
JNE floor3
or insideelevator, 10b

floor3:
cmp al, "3"
JNE floor4
or insideelevator, 100b

floor4:
cmp al, "4"
JNE floor5
or insideelevator, 1000b

floor5:
cmp al, "5"
JNE floor6
or insideelevator, 10000b

floor6:
inc cx
cmp cx, 3h
je endaddfloor

askfloor:
Mov si, offset addfloor
mov ah, 2
Call printmessage
Call printnewline

ask:
Mov ah,1
Int 21h
call printnewline

cmp al, "n"
je endaddfloor
cmp al, "y"
mov si, offset entrymessage
mov ah, 2
je bac
Mov si, offset invalidinput
Call printmessage
Call printnewline

break:
jmp askfloor

endaddfloor:
pop si
pop dx
pop cx
pop ax
ret
;end additionalfloor


;start verifyfloorinput
verifyfloorinput:
push ax
push dx
cmp al, "1"
je verified
cmp al, "2"
je verified
cmp al, "3"
je verified
cmp al, "4"
je verified
cmp al, "5"
je verified
Mov si, offset invalidinput
Mov ah, 2
Call printmessage
Call printnewline

notverified:
dec cx

verified:
pop dx
pop ax
ret
;end verifyfloorinput


;start exitmessage
exitmessage:
push ax
push dx
push cx
push si
Mov ah,2
Mov si, offset exitmessage1
Call printmessage

next1:
cmp location, 100b
mov dl,"1"
JE prnt
cmp location, 1000b
mov dl,"2"
JE prnt
cmp location, 10000b
mov dl,"3"
JE prnt
cmp location, 100000b
mov dl,"4"
JE prnt
mov dl,"5"

prnt:
int 21h
Mov si, offset exitmessage2
Call printmessage
Call printnewline

done:
mov al, location
mov cl, 02h
ror al, cl
sub insideelevator, al
pop si
pop cx
pop dx
pop ax
ret
;end exitmessage


;start idle
idle:
push cx
mov cl, 00000000b
mov elevatorcalled, cl
Call delay
mov cl, elevatorcalled
cmp cl, 00000001b
jne idle
pop cx
jmp endidlemethod
;end idle


;start delay
delay:
push BX
push CX
mov ch, 00h
mov cx,32h
mov BX, 0B5Dh
outer:
inner:
Call Poll
pushf
popf
dec BX
cmp BX, 00h
JNE inner
mov BX, 0B5Dh
dec cx
cmp cl, ch
JNE outer
pop CX
pop BX
ret
;end delay


;start Poll
Poll:
push DX
push AX
push BX
push CX
mov DX, 140h
in AL, DX
cmp AL, 11111111b
je continue
mov cl, 00000001b
mov elevatorcalled, cl
mov AH, AL
or AL,11110000b
mov BL, upfloorcalls
and BL, AL
mov upfloorcalls, BL
mov cl, 04h
ror ah, cl
or AH,11110000b
mov BL, downfloorcalls
and BL, AH
mov downfloorcalls, BL
continue:
call updatePortB
call changefloorlights
pop CX
pop BX
pop AX
pop DX
ret
;end Poll


;start changefloorlights
changefloorlights:
push DX
push AX
mov DX, 142h
mov AL, portC
out DX, AL
mov DX, 141h
mov AL, portB
out DX, AL
pop AX
pop DX
ret
;end changefloorlights


;start updatePortC
updatePortC:
push ax
mov al, direction
mov ah, location
add al, ah
not al
mov portC, al
pop ax
ret
;end updatePortC


;start updatePortB
updatePortB:
push ax
push cx
mov ax, 0FFFFh
mov al, downfloorcalls
mov cl, 04h
rol ax, cl
and al, upfloorcalls
mov portB, al
pop cx
pop ax
ret
;end updatePortB

printmessage: 
push AX
push DX
mov ah,2h
abc:
Mov dl,[si]
Cmp dl,"$"
je return
INT 21h
Inc si
Jmp abc

return:
pop DX
pop AX
;the above abc loop simply copies the contents of memory
;byte by byte, at the address that si points to.
;It prints these bytes until it reaches the dollar sign and exits
ret

printnewline:
push AX
push DX
mov AH,2h
mov dl,0Dh
int 21h
mov DL,0Ah
int 21h
pop DX
pop AX
ret

; end inserted code
code ends
end begin