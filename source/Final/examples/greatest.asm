.global @start
.equ IO, 0xFF

VECTOR_START:   ; definindo o vetor
.byte 15
.byte 56
.byte 9
.byte 252
.byte 99
VECTOR_END:

start:
    ld Ra, @VECTOR_START    ; Ra aponta para o inicio do vetor
    ld Rb, @VECTOR_END      ; Rb aponta para o final do vetor
    ld Rc, 0x00             ; Rc = maior valor (inicialmente 0)
    
loop:
    push Ra
    sub Ra, Rb
    ld Rd, @end
    beq Rd                  ; se Ra = Rb, o vetor ja terminou, entao vai para @end
    pop Ra

    ldr Rd, [Ra]            ; Rd = MEM[Ra] (valor na posicao atual do vetor)
    push Rd                 ; salvar Rd na pilha
    sub Rd, Rc              ; Rd = Rd - Rc (comparando com o maior valor atual)
    ld Rd, @new_greatest
    bgt Rd                  ; se Rd > Rc, entao Rd eh o novo maior valor, vai para @new_greatest
    pop Rd                  ; senao, limpa a pilha

next_iter:
    inc Ra                  ; ir para a proxima posicao do vetor
    jmp @loop    

new_greatest:
    pop Rc                  ; recuperar o maior valor, que tinha ido do Rd pra pilha 
    jmp @next_iter

end:
    pop Rd                  ; limpar pilha
    ld Rd, @IO              ; Rd = endereco de IO
    str Rc, [Rd]            ; mostra maior valor no LCD
    halt
