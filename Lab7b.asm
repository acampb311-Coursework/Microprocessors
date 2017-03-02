;******************************************************************************;
;Lab7.asm
;
;Description:This program moves a robot in a straight line with a trapezoidal
;velocity profile.
;
;Written By: Adam Campbell
;
;Date Written: 2/22/2017
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
INFO                FCB     'The total running time is %u sec.',$0D,$0A,$00
INFO_1              FCB     'Mah Boi',$0D,$0A,$00
PORTP               EQU     $0258
DDRP                EQU     $025A
P_IOMASK            EQU     %11000000
DATA_1              EQU     $1800
DATA_0              EQU     $1802
DATA_TEMP			FCB		$0000

DATA_TEMP_2         FCB     $0000
PRINTF              EQU     $EE88
TC2					EQU		$0054
TC3					EQU		$0056
TC7					EQU		$005E
TIOS                EQU     $0040
TIOS_M              EQU     %10001100
TSCR1               EQU     $0046           ;Timer System Control Register
TSCR1_M             EQU     %10000000       ;TEN bit (Timer enable)
TCTL2               EQU     $0049           ;Timer Control Register 2 Pg. 290
TCTL2_M             EQU     %10100000       ;OM* 1, OL* 0 == output line -> 0
OC7M                EQU     $0042
OC7M_M              EQU     %00001100
OC7D                EQU     $0043
OC7D_M              EQU     %00001100
TC2H                EQU     $0044
TCTL4               EQU     $004B           ;EDG*3->EDG*0
TCTL4_M             EQU     %00001001
TIE                 EQU     $004C
TIE_M               EQU     %00000011
TFLG1               EQU     $004E
TFLG1_M             EQU     %00000011
T_0_OFFSET			EQU		!55
T_1_OFFSET			EQU		!54
FORWARD_MASK        EQU     %11000000
BACKWORD_MASK       EQU     %00000000
LEFT_MASK           EQU     %10000000
RIGHT_MASK          EQU     %01000000

;******************************************************************************;
;MAIN - Central Routine for program.
;******************************************************************************;
MAIN                ORG     PROGRAM_START   ;Starting address for the program
                    LDS     #INIT_STACK		;Initialize the Stack
                    SEI						;Disable Maskable Interrupts

                    JSR		INIT_INTERRUPT
                    JSR		INIT_OUTPUT


                    MOVW    #$4000,TC2
                    MOVW    #$4000,TC3

                    ; MOVB    #BACKWORD_MASK,PORTP
                    ; LDD     #!620
                    ; PSHD
					; JSR		MOVE
                    ; LEAS    2,SP
                    ;
                    ; MOVB    #FORWARD_MASK,PORTP
                    ; LDD     #!620
                    ; PSHD
					; JSR		MOVE
                    ; LEAS    2,SP

                    MOVB    #LEFT_MASK,PORTP
                    LDD     #!120
                    PSHD
					JSR		MOVE
                    LEAS    2,SP

                    MOVB    #RIGHT_MASK,PORTP
                    LDD     #!120
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP

                    MOVW    #$0000,TSCR1	;Clear T1 Pulse Accumulator
                    MOVW    #$0000,TC2	    ;Clear T1 Pulse Accumulator
                    MOVW    #$0000,TC3	    ;Clear T1 Pulse Accumulator

                    SWI
END_MAIN            END


;******************************************************************************;
;MOVE - Moves the robot forward for a specified number of pulses.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Number of pulses           - Value         - 16 bits - Input
;******************************************************************************;
MOVE
                    MOVW    #$0000,DATA_1	;Clear T1 Pulse Accumulator
                    MOVW    #$0000,DATA_0	;Clear T0 Pulse Accumulator
                    CLI

FOR_PULSES          BRCLR   TFLG1,$04,FOR_PULSES
                    LDX     DATA_1
                    CPX     2,SP
                    BHS     END_FOR_PULSES
                    JMP     FOR_PULSES
END_FOR_PULSES
                    SEI
END_MOVE            RTS




;******************************************************************************;
;MOVE_FORWARD - Moves the robot forward for a specified period of time. It
;automatically calculates the necessary trapezoidal nature of the acceleration,
;constant speed, and deceleration necessary.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
MOVE_FORWARD
					MOVW    #$0000,DATA_1	;Clear T1 Pulse Accumulator
					MOVW    #$0000,DATA_0	;Clear T0 Pulse Accumulator
                    MOVW    #$0000,DATA_TEMP_2
					CLI
FORWARD_LOOP

IF_MAX_INTERVAL
                    LDD		DATA_TEMP_2
					CPD	    #!1400                  ;15 sec ish
					BNE		IF_MAX_INTERVAL_END
					JMP		END_MOVE_FORWARD
IF_MAX_INTERVAL_END

IF_ONE_SEC			LDD		DATA_1
					LDX		#!381
					IDIV
					CPD		#$0000
					BNE		IF_ONE_SEC_END
					PSHX
					LDD     #INFO
					LDX     PRINTF
					JSR     0,X
                    LEAS    2,SP
IF_ONE_SEC_END

IF_ACCEL            LDD     DATA_1
                    CPD     #!1908
					BHI		IF_ACCEL_END
					LDD		TC2
					ADDD	#!40
					STD		TC2
					LDD		TC3
					ADDD	#!40
					STD		TC3
					JMP		END_FORWARD_LOOP
IF_ACCEL_END

IF_CONST			LDD     DATA_1
                    CPD		#!3815
					BHI		IF_CONST_END
					JMP		END_FORWARD_LOOP
IF_CONST_END
					LDD		TC2
					SUBD	#!40
					STD		TC2
					LDD		TC3
					SUBD	#!40
					STD		TC3

END_FORWARD_LOOP	LDX		#$FFFF
					JSR		DELAY
                    LDD     DATA_TEMP_2
                    ADDD    #$0001
                    STD     DATA_TEMP_2
					JMP		FORWARD_LOOP
END_MOVE_FORWARD	RTS



;******************************************************************************;
;DELAY - Causes the program to 'delay'. It accomplishes this by simply eating
;clock cycles for a predetermined number of times. The formula for calculating
;this value is: (DesiredDelayTime/(1/25E6) - 11)/4. The 25E6 constant is bound
;to the clock speed of the Motorola S12 microcontroller which runs at 25MHz.
;( 0 ) - Return Address    - Value     - 16 bits - Input
;( 2 ) - Delay Iterations  - Value     - 16 bits - Input
;******************************************************************************;
DELAY               DEX
					BNE     DELAY
                    RTS

;******************************************************************************;
;INIT_OUTPUT - Initialize the output signals for the program. This specifically
;initializes T2 and T3 to be output signals that are set high by the OC7 and are
;individually cleared when the respective registers for T3 and T2 (TC3 and TC2)
;match the appropriate FRC value.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
INIT_OUTPUT			MOVB    #TIOS_M,TIOS
					MOVB    #TSCR1_M,TSCR1  ;Turn on the Timer System
					MOVB    #TCTL2_M,TCTL2  ;Configure reg to turn signals off
					MOVB    #OC7M_M,OC7M    ;Configure OC7 system
					MOVB    #OC7D_M,OC7D    ;Configure OC7 system
                    MOVB    #P_IOMASK,DDRP

					LDD     #$3333          ;5%duty
					STD     TC2
					LDD     #$3333
					STD     TC3
					LDD     #$0000
					STD     TC7             ;turns on (tc7)
END_INIT_OUTPUT		RTS

;******************************************************************************;
;INIT_INTERRUPT - Initialize two of the interrupts available on the TIOS. It
;specifically initializes the T0 and T1 interrupts.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
INIT_INTERRUPT		LDD     #T_0_INTERRUPT
                    STD     $3E72
                    PSHD
                    LDD     #T_0_OFFSET
                    LDX     $EEA4
                    JSR     0,X
                    LEAS    2,SP

                    LDD     #T_1_INTERRUPT
                    STD     $3E72
                    PSHD
                    LDD     #T_1_OFFSET
                    LDX     $EEA4
                    JSR     0,X
  					LEAS    2,SP

					MOVB    #TCTL4_M,TCTL4	;Set Event cause interrupt Rise/Fall
					MOVB    #TIE_M,TIE		;Enable Timing System Interrupts
END_INIT_INTERRUPT	RTS

;******************************************************************************;
;T_0_INTERRUPT - Interrupt Service Routine that increments a pulse counter.
;******************************************************************************;
T_0_INTERRUPT       LDD     DATA_0			;DATA_0++
                    ADDD    #$0001			;.
                    STD     DATA_0			;.
                    LDAB    TFLG1			;Clear the Flag for interrupt T0
                    ORAB    %00000001		;.
                    STAB    TFLG1			;.
END_T_0_INTERRUPT   RTI						;Return From Interrupt

;******************************************************************************;
;T_1_INTERRUPT - Interrupt Service Routine that increments a pulse counter.
;******************************************************************************;
T_1_INTERRUPT       LDD     DATA_1			;DATA_1++
                    ADDD    #$0001			;.
                    STD     DATA_1			;.
                    LDAB    TFLG1			;Clear the Flag for interrupt T1
                    ORAB    %00000010		;.
                    STAB    TFLG1			;.
END_T_1_INTERRUPT   RTI						;Return From Interrupt
