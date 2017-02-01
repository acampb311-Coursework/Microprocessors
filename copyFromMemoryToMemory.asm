;******************************************************************************;
;copyFromMemoryToMemory
;
;Description: This program copies the contents of one memory block to another.
;It copies indiscriminately until the value $FF is reached in the origin's memory
;
;Written By: Adam Campbell
;
;Date Written: 1/31/2017
;
;Date Modified:
;
;******************************************************************************;
Origin              EQU     $5000
Description         EQU     $6000

MAIN                ORG     $2200
                    LDD     #Description
                    PSHD
                    LDD     #Origin
                    PSHD
                    JSR     CPY_MEM
                    PULD
                    PULD
                    SWI
END_MAIN

;******************************************************************************;
;CPY_MEM
;( 0 ) - Return Address    - Value     - 16 bits - Input
;( 2 ) - Origin memory     - Value     - 16 bits - Input
;( 4 ) - Dest. memory      - Value     - 16 bits - Input
;******************************************************************************;
CPY_MEM
                    LDX     2,SP
                    LDY     4,SP
WHILE_1             LDAA    0,X
                    CMPA    #$FF
                    BEQ     END_WHILE_1
                    STAA    1,Y+
                    INX
                    BRA     WHILE_1
END_WHILE_1

END_CPY_MEM         RTS
