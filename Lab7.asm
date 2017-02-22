;******************************************************************************;
;Lab7.asm
;
;Description:gg
;
;Written By: Adam Campbell
;
;Date Written: 2/10/2017
;
;Date Modified: 2/14/2017 - Added comments
How does being a student in Signals and Systems relate to your faith in Christ?
How does your faith in Christ relate to being a student in Signals and Systems?
As I thought about this assignment, I struggled to be able to articulate very many tangible examples where being a student in Signals and Systems related to my faith in Christ. The first relationship I noticed was with regard to the character trait of perseverance. The very conceptual nature of the class ensures that it absolutely must be given its due attention. Without spending the time in the

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
info                FCB     'Value:%u',$0D,$0A,$00
one                 FCB     'One Interrupt',$0D,$0A,$00
zero                FCB     'Zero Interrupt',$0D,$0A,$00
; DATA_1              FCB     $0000
; DATA_0              FCB     $0000
DATA_1              EQU     $1800
DATA_0              EQU     $1802

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

TCTL4               EQU     $004B           ;EDG*3->EDG*0
TCTL4_M             EQU     %00001010
TIE                 EQU     $004C
TIE_M               EQU     %00000011
TFLG1               EQU     $004E
TFLG1_M             EQU     %00000011

;******************************************************************************;
;MAIN - Central Routine for program.
;******************************************************************************;
MAIN                ORG     PROGRAM_START   ;Starting address for the program
                    LDS     #INIT_STACK
                    SEI

                    ; JSR     INIT_CLK_25

                    MOVB    #TIOS_M,TIOS
                    MOVB    #TSCR1_M,TSCR1  ;Turn on the Timer System
                    MOVB    #TCTL2_M,TCTL2  ;Configure reg to turn signals off
                    MOVB    #OC7M_M,OC7M    ;Configure OC7 system
                    MOVB    #OC7D_M,OC7D    ;Configure OC7 system
                    MOVB    #TCTL4_M,TCTL4
                    MOVB    #TIE_M,TIE
                    MOVW    #$0000,DATA_1
                    MOVW    #$0000,DATA_0
                    LDD     #$8000
                    STD     $0054

                    LDD     #$4000
                    STD     $0056

                    LDD     #$FFFF
                    STD     $005E             ;turns on (tc7)


                    LDD     #T_0_INTERRUPT
                    STD     $3E72
                    PSHD
                    LDD     #!55
                    LDX     $EEA4
                    JSR     0,X
                    LEAS    2,SP

                    LDD     #T_1_INTERRUPT
                    STD     $3E72
                    PSHD
                    LDD     #!54
                    LDX     $EEA4
                    JSR     0,X
                    LEAS    2,SP

                    SWI
                    CLI
BOB

                    BRA     BOB
END_MAIN            END


T_0_INTERRUPT       LDD     DATA_0
                    ADDD    #$0001
                    STD     DATA_0
                    LDAB    TFLG1
                    ORAB    %00000001
                    STAB    TFLG1
                    LDD     DATA_0
                    CPD     #!381
                    BNE     BOBBY
                    LDD     #info
                    LDX     printf
                    JSR     0,X
                    LDD     #$0000
                    STD     DATA_0
                    PSHD
BOBBY

                    RTI

T_1_INTERRUPT       LDD     DATA_1
                    ADDD    #$0001
                    STD     DATA_1
                    LDAB    TFLG1
                    ORAB    %00000010
                    STAB    TFLG1
                    ; LDD     #one
                    ; LDX     printf
                    ; JSR     0,X
                    RTI
