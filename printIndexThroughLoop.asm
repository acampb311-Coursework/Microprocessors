;********************************* Symbols ************************************;
					ORG     $1900
PRINTF              EQU     $EE88
SString     		FCB     'I am number <%u>',$0D,$0A,$00
;******************************* End Symbols **********************************;

;********************************** Main **************************************;
MAIN                ORG     $2200   	    ;Starting Address
                    LDY     #$1000

                    LDAA    #$00
WHILE_1             CMPA    #$0A
                    BEQ     END_WHILE_1
                    PSHA
                    CLRA
                    LDAB    0,SP
                    PSHD
                    LDD     #SString
                    LDX     printf
                    JSR     0,X
                    PULD
                    PULA
                    INCA
                    BRA     WHILE_1
END_WHILE_1

                    SWI
END_MAIN            END
