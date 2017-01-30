QUOTIENT    EQU     $1000       ;Variable to hold our QUOTIENT
REMAINDER   EQU     $1002       ;Variable to hold our REMAINDER

			ORG     $2000
			LDY		#QUOTIENT
			LDAA    #$00
MAIN		CMPA    #$0A
			BEQ     END_MAIN
			LDAB	#$55
			STAB	2,Y+
			INCA
			BRA     WHILE1
END_MAIN    END


;******************************************************************************;
;Lab3b.asm
;
;Description:
;
;Written By: Adam Campbell
;
;Date Written: 1/24/2017
;
;Date Modified:
;
;******************************************************************************;

;********************************* Symbols ************************************;
					ORG     $1900
PRINTF              EQU     $EE88
TitleString         FCB     'MOTOR CONTROL SOFTWARE',$0D,$0A,$00
SString     		FCB     'I am number <%u>',$0D,$0A,$00
;******************************* End Symbols **********************************;


;This does a simple loop to print out the numbers 0 - 9
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
