QUOTIENT    EQU     $1000       ;Variable to hold our QUOTIENT
REMAINDER   EQU     $1002       ;Variable to hold our REMAINDER

MAIN        ORG     $2000       ;Set the start of the program
            LDD     #!50        ;Load the D register with a value (16 bits)
            PSHD                ;Push D onto the stack (16 bits)
            LDD     #!10        ;Load the D register with a value (16 bits)
            PSHD                ;Push D onto the stack (16 bits)
            LDD     #QUOTIENT   ;Load the D register with an address (16 bits)
            PSHD                ;Push D onto the stack (16 bits)
            LDD     #REMAINDER  ;Load the D register with an address (16 bits)
            PSHD                ;Push D onto the stack (16 bits)
            JSR     DIVIDE      ;Push the PC onto the stack (16 bits).
            PULD                ;Clear 16 bits from stack
            PULD                ;Clear 16 bits from the stack
            PULD                ;Clear 16 bits from the stack
END_MAIN    END


;******************************************************************************;
;DIVIDE - This routine expects the following parameters to be on the stack:
; STACK
;(top) - (16 bits for return address)
;(   ) - (16 bits of address to store the REMAINDER (ANSWER var reference))
;(   ) - (16 bits of address to store the QUOTIENT (ANSWER var reference))
;(   ) - (16 bits for divisor)
;(   ) - (16 bits for dividend)
;******************************************************************************;
DIVIDE      LDD     8,SP       ;Loads the dividend (50)
            LDX     6,SP       ;Loads the divisor (10)
            IDIV			   ;Divide
			LDY		4,SP	   ;Get the address of the Quotient
            STX     0,Y		   ;Store at that address
			LDY		2,SP	   ;Get the address of the remainder
            STD     0,Y		   ;Store at that address
END_DIVIDE  RTS


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
