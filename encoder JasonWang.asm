; Name: Jason Wang
;
; Date: Feb 9, 2015
;
; Desc: This program will encrypt or decrypt a string the user enters
;       based on the key value they put in 
org 100h 
 
; CODE Section Starts
start: 
    lea bx, message ; load the address of message into register BX
myloop:
    mov dl, [bx]    ; copy the value in Bx memory address into register DL
    inc bx          ; moves bx into next memory address 
    cmp dl, 0       ; compares dl to zero if yes then jump
    je option       ; jumps to option 
    mov ah, 06      ; service 6 from 21h
    int 21h         ; prints message onto screen
    jmp myloop      ; repeat loop
    
option:             ;gets the choice from the user 
    mov ah, 00h     ;service 00h (get keystroke) 
    int 16h         ;call interrupt 16h (AH=00h) 
    mov dl,al       ;set dl to value of al which is the users choice
    mov ah, 02h     ;service 02h from int 21h (write char to standard output)
    int 21h         ;call interrupt 21h to output ascii char in dl
    mov choice, dl  ;sets choice to dl which is value of the option
    cmp dl,51       ;sees if dl is equal to ascii value for 3 
    je quit         ;if dl is equal to 3 then jump to quit
    cmp dl,49       ;sees if dl is equal to ascii 1 
    je encrypt_decrypt_message ;jumps to encrypt_decrypt_message if it is equal to ascii 1
    cmp dl,50                  ;sees if dl is equal to ascii 2
    je encrypt_decrypt_message ;jumps to encrypt_decrypt_message if it is equal to ascii 2
    
getkey:         ;gets the user input value for key
    mov ah, 00h ;service 00h (get keystroke)
    int 16h     ;call interrupt 16h (AH=00h) 
    mov dl,al   ;sets dl to value of al which is ascii value of key
    mov ah, 02h ;service 02h from int 21h (write char to standard output)
    int 21h     ;call interrupt 21h to output ascii char in dl
    mov ah,dl   ;sets ah to value of dl
    sub ah,48   ;subtract value in ah to get decimal value that ascii code represents
    mov keyvalue, ah       ;sets keyvalue to ah
    cmp choice,50          ;seesif choice is equal to ascii value 2
    je  decrypttextmessage ;jumps to decrypttextmessage if it is 
    jmp textmessage        ;jmp to textmessage


    
encrypt_decrypt_message:           ; setting the memory address of keymessage to bx
    lea bx, keymessage             ; load the address of keymessage into register BX
    jmp encrypt_decrypt_keymessage ;jumps to encrypt_decrypt_keymessage

textmessage:              ; setting the memory address of inputmessage to bx
    lea bx, inputmessage  ; load the address of inputmessage into register BX
    jmp text              ; jumps to text

decrypttextmessage:       ;setting the memory address of inputmessage 2 to bx
    lea bx, inputmessage2 ; load the address of inputmessage2 into register BX
    jmp text              ;jumps to text
    
settext:          ;setting the memory address of input to bx
    lea bx, input ; load the address of input into register BX
    
gettext:            ;gets the string from the user
    mov ah, 00h     ; service 00h (get keystroke)
    int 16h         ; call interrupt 16h (AH=00h)       
                    ; character read will now be in AL
    cmp al, 0Dh     ; Is AL = 0Dh? (ASCII 13 = Return)
    je  endecrypttext ; If yes, then jump to endecrypttext
    mov [bx], al    ; If no, then store the character where BX points
    mov dl, al      ; sets dl to al in order to display
    mov ah, 02h     ; service 02h from int 21h (write char to standard output)
    int 21h         ; call interrupt 21h to output ascii char in dl
    inc bx          ; point BX to next char of input variable
    jmp gettext     ; Repeat for the next character

text:               ; prints out the message from either textmessage or decrypttext
    mov dl, [bx]    ; copy the character point by Bx into register DL
    inc bx          ; moves bx into next memory regester 
    cmp dl, 0       ; if dl is equal to zero (reaches end of string)
    je settext      ; skips to settext if dl is equal to zero 
    mov ah, 06      ; sets ah to 6
    int 21h         ; prints message onto screen
    jmp text        ; reoeat for the next character
    
encrypt_decrypt_keymessage:;prints out the message telling user to enter key value
    mov dl, [bx]    ; copy the character point by Bx into register DL
    inc bx          ; moves bx into next memory regester 
    cmp dl, 0       ; checks to see if dl ie equal to zero (reaches end of string)
    je getkey       ; skips to getkey 
    mov ah, 06      ; service 6 from 21h
    int 21h         ; prints message onto screen
    jmp encrypt_decrypt_keymessage ;jumps to encrypt_decrypt_keymessage  

endecrypttext:      ; setting the memory address of input to bx 
    lea bx, input   ; load the address of input into register BX
    cmp choice,50   ; seesif choice is equal to ascii value 2
    je decryptvalue ; if choice is equal to ascii 2 then jump to decryptvalue

convertvalue:           ;encrypts the string user entered
    mov al, [bx]        ;sets the ascii value stored in bx to al
    cmp al, 0           ;checks to see if al is equal to zero meaning the string has ended     
    je setciphermessage ;jump to setciphermessage if it is equal to zero 
    add al, keyvalue    ;adds the keyvalue to al
    mov [bx],al         ;sets bx to al
    inc bx              ;point BX to next char of input variable
    jmp convertvalue    ;restarts the loop

decryptvalue:           ;decrypts the string the user has entered
    mov al, [bx]        ;sets the ascii value stored in bx to al
    cmp al, 0           ;checks to see if al is equal to zero meaning the string has ended  
    je setplainmessage  ;jump to setplainmessage if it is equal to zero 
    sub al, keyvalue    ;sub the value of al by keyvalue
    mov [bx],al         ;sets bx to al
    inc bx              ;point BX to next char of input variable
    jmp decryptvalue    ;restarts the loop

setciphermessage:       ; setting the memory address of ciphertextmessage to bx 
    lea bx, ciphertextmessage  ; load the address of ciphertextmessage into register BX
    jmp show_cipher_plain_message ;jumps to show_cipher_plain_message 
    
setplainmessage:        ; setting the memory address of paintextmessage to bx 
    lea bx,paintextmessage ; load the address of paintextmessage into register BX
     
show_cipher_plain_message: ;prints the message of either ciphertextmessage or paintextmessage
    mov dl, [bx]    ; copy the character point by Bx into register DL
    inc bx          ; moves bx into next memory regester 
    cmp dl, 0       ; checks to see if dl equal to zero (reached end of string)
    je set_cipher_plain ; skips to setcipherplain 
    mov ah, 06      ; sets ah to 6
    int 21h         ; prints message onto screen
    jmp show_cipher_plain_message ;restarts loop

set_cipher_plain:    ; setting the memory address of input to bx
    lea bx, input    ; load the address of input into register BX

print_cipher_plain: ; prints out the cipher or plain text message depending on option
    mov dl, [bx]    ; copy the character point by Bx into register DL
    inc bx          ; moves bx into next memory regester 
    cmp dl, 0       ; sees if dl is equal to zero ie reached end of string
    je resetinginput; if dl is zero jump to resetinginput       
    mov ah, 06      ; sets ah to 6
    int 21h         ; prints message onto screen
    jmp print_cipher_plain ;restarts loop

resetinginput:   ; setting the memory address of input to bx
    lea bx,input ; load the address of input into register BX
    mov cx,40    ; sets cx to 40 ie the counter for loop

wipeinput:       ; wipes the old input entered by user 
    mov [bx],0   ; sets the memory address value of bx back to zero   
    inc bx       ;point BX to next char of input variable
    loop wipeinput ;restarts loop for 40 times

restart:      ;restarts program
    jmp start ;jump to start
    
quit:       ;exits the program
    int 20h ; Call the BIOS to terminate the program
 
; DATA Section Starts
    ; the message for the options
    message db 10,13,79,112,116,105,111,110,115,58,32,40,49,41,32,69,110,99,114,121,112,116,32,40,50,41,32,68,101,99,114,121,112,116,32,40,51,41,32,81,117,105,116,32,0  
    ; the message asking user for key value
    keymessage db 10,13,69,110,116,101,114,32,107,101,121,32,118,97,108,117,101,32,40,49,45,57,41,58,32,0
    ; the message asking user for plaintext
    inputmessage db 10,13,69,110,116,101,114,32,112,108,97,105,110,116,101,120,116,44,32,60,114,101,116,117,114,110,62,32,116,111,32,102,105,110,105,115,104,58,32,0
    ; the message asking user for ciphertext
    inputmessage2 db 10,13,69,110,116,101,114,32,99,105,112,104,101,114,116,101,120,116,44,32,60,114,101,116,117,114,110,62,32,116,111,32,102,105,110,105,115,104,58,32,0 
    ; the message displaying ciphertext
    ciphertextmessage db 10,13,67,105,112,104,101,114,116,101,120,116,32,105,115,32,58,32,0
    ; the message displaying plaintext
    paintextmessage db 10,13,80,108,97,105,110,116,101,120,116,32,105,115,58,32,0
    ; the varible for storing the decimal keyvalue
    keyvalue db 0   
    ; varible for storing the choice
    choice db 0
    ; the varible for storing the user input for string
    input  db  40 dup(0)  ; reserves 40 bytes (each byte = 0)