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

;Symbols
VConstant           EQU     $100A
TTotal              EQU     $100C
Ta                  EQU     $1000
Tc                  EQU     $1002
dV                  EQU     $1006
;End Symbols

MAIN                ORG     $2500   	    ;Starting Address
                    LDD		VConstant
                    PSHD
                    LDD     #Ta             ;Setting up the pass by reference (grabs address)
                    PSHD
                    LDD	    TTotal
                    PSHD
                    JSR     COMPUTE_INTERVAL
END_MAIN            END

;End Program - Lab 2b
COMPUTE_INTERVAL    PULY                    ;Y now has the return address to the calling function
                    PULD                    ;D = TTotal
                    LDX     #!05            ;X = 5
                    IDIV                    ;X = TTotal / 5 = ta
                    PULD
                    STD     $2000

                    STX                     ;$1000 = ta
                    STD     $1004           ;$1004 = TTotal
                    SUBD    0,X             ;D = D - X (tc = ttotal - ta)
                    STD     $1002           ;$1000 = tc
                    PULD                    ;D = VConstant
                    LDX     $1000           ;X = ta
                    IDIV                    ;D = D / X (dV = VConstant / ta)
                    STD     $1006           ;$1006 = D
                    PSHY
END_COMPUTE_INTERVAL RTS
