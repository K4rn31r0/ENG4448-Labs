; Descrição:
; 
; - o programa irá começar imprimindo o vetor no LCD
;   [ 133, 122, 255, 33, 77, 99, 103, 200, 5, 25 ]
; - após rodar "init_print_vector", iremos para "start"
;   o código irá colocar os valores no vetor em ordem
;   crescente:
;   [ 5, 25, 33, 77, 99, 103, 122, 133, 200, 255 ]
; - após rodar essa etapa, iremos carregar Ra = 0,
;   Rb = 2, e somar Ra = Ra + Rb...
; - Ra irá incrementar de 2 em 2 até estourar o contador
; - a cada vez que Ra é incrementado, seu valor irá
;   aparecer no LCD..
; - assim que houver carry_out (overflow) faremos um
;   jmp para "init_print_vector" que irá imprimir o 
;   vetor em ordem crescente
;   [ 5, 25, 33, 77, 99, 103, 122, 133, 200, 255 ]
; - ao terminar, iremos para "end" (halt)
; 
; Compilar:
;   $ python nasm.py -i trabalho_final.asm -r -o ram.vhd --overwrite
; 

.global @preinit                        ; jump to @preinit

; compiler's runtime variables
.equ LCD, 0xFF                          ; LCD debug output
.equ VECTOR_LEN, 0x0A                   ; must be @preinit - 2 since .global is a 'jmp' (2 address lost)

VECTOR_POINTER: ; start 0x02
.byte 133
.byte 122
.byte 255
.byte 33
.byte 77
.byte 99
.byte 103
.byte 200
.byte 5
.byte 25
VECTOR_END:

ACTUAL_IDX:     .byte 0x00
ACTUAL_ADDR:    .byte 0x00
ACTUAL_VALUE:   .byte 0x00
LAST_ADDR:      .byte 0x00
LAST_VALUE:     .byte 0x00
FIRST_PRINT:    .byte 0x01


.org 0x20
preinit:        ld Rd, @VECTOR_POINTER  ; load pointer to VECTOR
                ld Rc, @ACTUAL_IDX      ;
                str Rd, [Rc]

                jmp @init_print_vector

start:          ld Rd, @ACTUAL_IDX      ; Rd --> points to LAST_VALUE pointer
                ldr Rd, [Rd]            ; Rd --> ACTUAL_IDX
                ldr Ra, [Rd]            ; Ra = MEM[Rd]

                ld Rc, @ACTUAL_ADDR     ; 
                str Rd, [Rc]            ; store Rd (address) -- MEM[@ACTUAL_ADDR] = Rd
                ld Rc, @ACTUAL_VALUE    ; 
                str Ra, [Rc]            ; store Ra (value)   -- MEM[@ACTUAL_VALUE] = Ra

                ld Rc, @incIdx          ; upload something to stack
                push Rc                 ; since @printLCD uses the stack

storeMinAV:     ld Rc, @LAST_ADDR       ; 
                str Rd, [Rc]            ; store Rd (address) -- MEM[@LAST_ADDR] = Rd
                ld Rc, @LAST_VALUE      ; 
                str Ra, [Rc]            ; store Ra (value)   -- MEM[@LAST_VALUE] = Ra

; printLCD "function"
;   -> execute and then return to the where it was called 
;      using stack pointer

printLCD:       ld Rc, @LCD             ; print minimum value
                str Ra, [Rc]            ; to the LCD (debug)

                pop Rc                  ; return to the program execution
                jmpr Rc                 ; jmp to the last *pointer

incIdx:         inc Rd                  ; increment pointer
                ld Rc, @VECTOR_END
                xor Rc, Rd              ; if they are equal then the result will be zero!
                ld Rc, @end_vector
                beq Rc                  ; loop i in 1:vector_end, if i = vector_end -> then go to @end_vector

; iterate through the vector
                ldr Rb, [Rd]            ; load next value
                xor Rb, Ra              ; if they are equal then the result will be zero!
                ld Rc, @saveMin
                blt Rc                  ; if Rb < Ra -> saveMin and printLCD
                jmp @incIdx             ; else       -> seek for next value

saveMin:        ldr Ra, [Rd]            ; load new minimum value

                ld Rc, @incIdx          ; put it to stack
                push Rc                 ; 

                jmp @storeMinAV         ; store value and addr

end_vector:     ld Rd, @ACTUAL_IDX      ; Rd --> points to LAST_VALUE pointer
                ldr Rd, [Rd]            ; Rd --> ACTUAL_IDX
                inc Rd                  ; ACTUAL_IDX = ACTUAL_IDX + 1
                
                ld Rc, @ACTUAL_IDX      ;
                str Rd, [Rc]            ; MEM[@ACTUAL_IDX] = ACTUAL_IDX + 1
                
                ld Rc, @VECTOR_END      ; ACTUAL_IDX = VECTOR_END
                xor Rc, Rd              ; if they are equal then the result will be zero!
                ld Rc, @count_carry
                beq Rc                  ; if tested all values, then go to @init_print_vector
                jmp @swap               ; else

; vector[LAST_ADDR] = ACTUAL_VALUE
; vector[ACTUAL_ADDR] = LAST_VALUE
swap:           ld Ra, @ACTUAL_VALUE    ; Ra --> points to ACTUAL_VALUE pointer
                ldr Ra, [Ra]            ; Ra = ACTUAL_VALUE
                ld Rb, @LAST_ADDR       ; Rb --> points to LAST_ADDR pointer
                ldr Rb, [Rb]            ; Rb = LAST_ADDR
                str Ra, [Rb]            ; vector[LAST_ADDR] = ACTUAL_VALUE

                ld Ra, @LAST_VALUE      ; Ra --> points to LAST_VALUE pointer
                ldr Ra, [Ra]            ; Ra = LAST_VALUE
                ld Rb, @ACTUAL_ADDR     ; Rb --> points to ACTUAL_ADDR pointer
                ldr Rb, [Rb]            ; Rb = ACTUAL_ADDR
                str Ra, [Rb]            ; vector[ACTUAL_ADDR] = LAST_VALUE
                
                jmp @start              ; continue the loop


init_print_vector:
                ld Rd, @VECTOR_POINTER
                ld Rc, @VECTOR_END

print_vector:   ldr Ra, [Rd]
                inc Rd                  ; ACTUAL_IDX = ACTUAL_IDX + 1

                ld Rb, @print_vector_f  ; stack pointer
                push Rb                 ; 
                jmp @printLCD           ; printLCD will return to @print_vector_f

print_vector_f:
                ld Rc, @VECTOR_END      ; ACTUAL_IDX = VECTOR_END
                xor Rc, Rd              ; if they are equal then the result will be zero!
                ld Rc, @notFirstPrint   ;
                beq Rc                  ; if tested all values, then go to @notFirstPrint
                jmp @print_vector       ; else

notFirstPrint:
                push Ra
                push Rb
                ld Ra, @FIRST_PRINT     ; Ra --> *FIRST_PRINT
                ldr Rb, [Ra]            ; Rb = 1
                dec Rb
                str Rb, [Ra]
                pop Rb
                pop Ra
                ld Rd, @start           ; if (firstRun == 1)       = if (firstRun-1 == 0)
                bz Rd                   ;      jmp @start
                jmp @end                ; else jmp @end

count_carry:
                ld Ra, 0x00
                ld Rb, 0x02

count_carry_loop:
                add Ra, Rb
                ld Rc, @LCD             ; print minimum value
                str Ra, [Rc]            ; to the LCD (debug)

                ld Rd, @init_print_vector
                bcs Rd
                jmp @count_carry_loop

end:            halt
