;******************************************************************************;
;Lab7.asm
;
;Description:Monte Cox can suck my cock
;
;Written By: Adam Campbell
;
;Date Written: 2/10/2017
;
;Date Modified: 2/14/2017 - Added comments
;
;******************************************************************************;
#HCS12

INIT_STACK          EQU     $3C00
PROGRAM_START       EQU     $2200
PROGRAM_DATA        EQU     $1900
                                            ;
                                            ;Data for the program
                                            ;
                    ORG     PROGRAM_DATA
PRINTF              EQU     $EE88
info                FCB     'Value:%X',$0D,$0A,$00

TIOS                EQU     $0040           ;PORT T, used for outputting sig
TIOS_M              EQU     %10001100       ;7   6   5   4   3   2   1   0
                                            ;PT7 PT6 PT5 PT4 PT3 PT2 PT1 PT0
                                            ;OC7 OFF OFF OFF OUT OUT IN  IN
TSCR1               EQU     $0046           ;Timer System Control Register
TSCR1_M             EQU     %10000000       ;TEN bit (Timer enable)

TCTL2               EQU     $0049           ;Timer Control Register 2 Pg. 290
                                            ;"Set the logic states on the output
                                            ;pins to be low (0) when successful
                                            ;compares by configuring bits"
                                            ;TCTL2
                                            ;7   6   5   4   3   2   1   0
                                            ;OM3 OL3 OM2 OL2 OM1 OL1 OM0 OL0
TCTL2_M             EQU     %10100000       ;OM* 1, OL* 0 == output line -> 0

                                            ;Configure the OC7 system to set high
                                            ;(turn on) the logic levels on pins
                                            ;PT2 and PT3 when successful matches
                                            ;are detected between the contents of
                                            ;the TC7 register and the free-running
                                            ;counter.
                                            ;7   6   5   4   3   2   1   0
                                            ;T7  T6  T5  T4  T3  T2  T1  T0
OC7M                EQU     $0042
OC7M_M              EQU     %00001100
OC7D                EQU     $0043
OC7D_M              EQU     %00001100
TC2H                EQU     $0044
                                            ;Used for setting the operating
                                            ;Frequency for the microprocessor
                                            ;The equation for setting this up is
                                            ;2*OSCLK*(SYNR + 1)/(REFDV + 1)
                                            ;No idea if this actually works
SYNR                EQU     $0034
SYNR_M              EQU     !24
REFDV               EQU     $0035
REFDV_M             EQU     !31
PLLSEL              EQU     $0039
PLLSEL_M            EQU     %10000000



;******************************************************************************;
;MAIN - Central Routine for program.
;******************************************************************************;
MAIN                ORG     PROGRAM_START   ;Starting address for the program
                    LDS     #INIT_STACK
                    JSR     INIT_CLK_25

                    MOVB    #TIOS_M,TIOS
                    MOVB    #TSCR1_M,TSCR1  ;Turn on the Timer System
                    MOVB    #TCTL2_M,TCTL2  ;Turn the signal off
                    MOVB    #OC7M_M,OC7M    ;Configure OC7 system
                    MOVB    #OC7D_M,OC7D    ;Configure OC7 system
                    LDD     #$8000
                    STD     $0054

                    LDD     #$4000
                    STD     $0056

                    LDD     #$FFFF
                    STD     $005E
BOB
                    LDD     TC2H
                    PSHD
                    LDD     #info
                    LDX     printf
                    JSR     0,X

                    BRA     BOB

END_MAIN            END


INIT_CLK_25         MOVB    #SYNR_M,SYNR
                    MOVB    #REFDV_M,REFDV
                    MOVB    #PLLSEL_M,PLLSEL
END_INIT_CLK_25     RTS
