;********************************* Symbols ************************************;
					ORG     $1900
PRINTF              EQU     $EE88
SString     		FCB     'I am number <%X>',$0D,$0A,$00
;******************************* End Symbols **********************************;

;********************************** Main **************************************;
MAIN                ORG     $2200   	    ;Starting Address
                    LDY     #$1000
                    LDAA    #$00
WHILE_1             CMPA    #$0A
                    BEQ     END_WHILE_1
                    PSHA                    ;Store our loop index
					PSHY
					LDD		0,Y
					PSHD
                    LDD     #SString
                    LDX     printf
                    JSR     0,X
					PULD
					PULY					;Took 2 hours to realize that the y register is being used in the print register... fml
					INY
					INY
                    PULA
                    INCA
                    BRA     WHILE_1
END_WHILE_1

                    SWI
END_MAIN            END
