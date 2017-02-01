;******************************************************************************;
;${/basename}
;
;Description:
;
;Written By: Adam Campbell
;
;Date Written: 1/24/2017
;
;Date Modified: 1/31/2017
;
;******************************************************************************;
                    ORG     $1900
PRINTF              EQU     $EE88
PORTJ               EQU     $0268
DDRJ                EQU     $026A
J_IOMASK            EQU     $00
DelayTime           EQU     $12
AWK_STRING          FCB     'Button Pressed!:',$0D,$0A,$00,$0D,$0A,$00

MAIN                ORG     $2200
                    LDAA    #J_IOMASK
                    STAA    DDRJ

					CLRA
WHILE_1             LDAA    PORTJ
					CMPA    #$C3
                    BNE     WHILE_1
                    LDD     #AWK_STRING
                    LDX     printf
                    JSR     0,X
                    LDX     #DelayTime
                    JSR     DELAY
                    BRA     WHILE_1
END_WHILE_1

******************************************************************************;
DELAY               DEX
					BNE     DELAY
                    RTS
