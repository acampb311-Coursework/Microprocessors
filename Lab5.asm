;******************************************************************************;
;Lab5.asm
;
;Description: This program interfaces with a physical button in order for a
;physical control of a hardware system.
;
;Written By: Adam Campbell
;
;Date Written: 1/31/2017
;
;Date Modified: 2/6/2017 (Added comments)
;
;******************************************************************************;
                    ORG     $1900
PRINTF              EQU     $EE88
PORTJ               EQU     $0268
DDRJ                EQU     $026A
J_IOMASK            EQU     $00
DelayTime           EQU     $FFFF
AWK_STRING          FCB     'Button Pressed!:',$0D,$0A,$00

MAIN                ORG     $2200
                    LDAA    #J_IOMASK
                    STAA    DDRJ
                    SWI
WHILE_1             LDAA    PORTJ
					CMPA    #$C3             ;PortJ0 -> 1100001[1] so C3 is high
                    BNE     WHILE_1
                    LDD     #AWK_STRING
                    LDX     printf
                    JSR     0,X
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    LDX     #DelayTime
                    JSR     DELAY
                    BRA     WHILE_1
END_WHILE_1

******************************************************************************;
DELAY               DEX
					BNE     DELAY
                    RTS
