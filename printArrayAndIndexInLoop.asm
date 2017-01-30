                    ORG     $1900
VEL_STRING			FCB		'VELOCITY %u:             %X     ',$0D,$0A,$00
PRINTF              EQU     $EE88
PUTCHAR				EQU		$EE86

                    ORG 	2200
DISP_PROFILE        LDY     #$1000
                    LDAA    #$00
WHILE_4             CMPA    #$0A
                    BEQ     END_WHILE_4
                    PSHA                    ;Store our loop index
                    PSHY
                    LDD		0,Y
                    PSHD
                    LDAB	4,SP
                    CLRA
                    PSHD
                    LDD     #VEL_STRING
                    LDX     printf
                    JSR     0,X
                    PULD
                    PULD
                    PULY					;Took 2 hours to realize that the y register is being used in the print register... fml
                    INY
                    INY
                    PULA
                    INCA
                    BRA     WHILE_4
END_WHILE_4

END_DISP_PROFILE	END
