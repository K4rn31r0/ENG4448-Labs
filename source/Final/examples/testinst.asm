            .global @start  ; jmp to memory start address
            .byte 0xFE      ; stack pointer

            .equ valA, 0x0c ; variable ---> valA = 12
            .equ valB, 127  ; variable ---> valB = 127

            .org 0x10
start:      ld Ra, 0x14     ; Ra = 20
            ld Rb, 0x0A     ; Rb = 10
            ld Rc, @valA    ; Rc = 12
            ld RD, @valB    ; Rd = 127

            add Rb, Rc      ; Rb = 22
            add Rb, Rd      ; Rb = 149
            sub Rb, Ra      ; Rb = 129
            sub RB, RD      ; Rb = 2

            not Ra          ; Ra = 235   (~20 = ~0b00010100 = 0b11101011)

            ldr Ra, [RB]    ; Ra = 0xFE
            str Ra, [RC]    ; MEM[12] = 0xFE
            jmp @start


            .org 0x30
testinstr:  add Ra, Rb
            sub Rc, Rd
            inc Ra
            inc Rb
            inc Rc
            inc Rd
            dec Ra
            dec Rb
            dec Rc
            dec Rd
            and Ra, Rb
            or  Rc, Rd
            not Ra
            xor Ra, Rd
            rol Rc
            ror Rb
            lsl Rd
            lsr Rc
            push Ra
            pop Rb
            st  Rc, 0xF0
            ld  Rb, 0xF0
            ldr Ra, [Rb]
            str Rb, [Rc]
            mov Rc, Rd
            jmp 42
            jmp 0x30
            jmp @testinstr
            jmpr Ra
            jmpr Rb
            jmpr Rc
            jmpr Rd
            bz  Ra
            bnz Rb
            bcs Rc
            bcc Rd
            beq Ra
            bneq Rb
            bgt Rc
            blt Rd
            halt


