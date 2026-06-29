.global @start
.equ valA,	0x18	; A = 24
.equ valB,	0x12	; B = 18
.equ IO,	0xFF	; IO = 255

start:
	ld Ra, @valA	; Ra = 24
	ld Rb, @valB	; Rb = 18

mdc_loop:
	push Ra			; salvar Ra na pilha
	sub Ra, Rb		; Ra = Ra - Rb
	ld Rd, @mdc_done; Rd = endereco de mdc_done
	beq Rd			; if Ra == Rb, jump to mdc_done

	ld Rd, @ra_smaller	; Rd = endereco de ra_smaller
	blt Rd			; if Ra < Rb, jump to ra_smaller

ra_greater:			; se chegou ate aqui, eh porque Ra > Rb, e o resultado de A - B esta em Ra
	pop Rd			; "descarta" o Ra antigo que estava na pilha
	jmp @mdc_loop	; repetir o loop

ra_smaller:			; se chegou ate aqui, eh porque Ra < Rb
	pop Ra			; recuperar Ra da pilha
	sub Rb, Ra		; Rb = Rb - Ra
	jmp @mdc_loop	; repetir o loop
	
mdc_done:			; o loop parou, porque A = B, entao o resultado do MDC esta em Ra
	pop Ra			; recuperar Ra da pilha
	ld Rd, @IO		; Rd = endereco de IO
	str Ra, [Rd]	; MEM[IO] = Ra (display LCD)
	halt