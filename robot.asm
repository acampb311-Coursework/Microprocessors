;******************************************************************************;
;robot.asm
;
;Description:This program guides a robot through a dynamic maze. It relies on
;the core subsystems of: an LCD, I/R sensors, a Power Supply, and a Motor Driver
;
;Written By: Adam Campbell
;
;Date Written: 4/10/2017
;
;
;******************************************************************************;
#HCS12

INIT_STACK          EQU     $3C00
PROGRAM_START       EQU     $2200
PROGRAM_DATA        EQU     $1900

                    ORG     PROGRAM_DATA
PRINTF              EQU     $EE88
INFO                FCB     'LEFT:%X  CENTER:%X  RIGHT:%X.',$0D,$0A,$00
ATD1CTL2            EQU     $0122           ;I/R sensor Data
ATD1CTL2_MASK       EQU     %10000000
ATD1CTL3            EQU     $0123
ATD1CTL3_MASK       EQU     %00100000
ATD1CTL4            EQU     $0124
ATD1CTL4_MASK       EQU     %10000101
ATD1CTL5            EQU     $0125
ATD1CTL5_MASK       EQU     %00010100
ATDSTAT             EQU     $0126
ATD1DR0H            EQU     $0130
ATD1DR1H            EQU     $0132
ATD1DR2H            EQU     $0134
LCD_FUNC_ON_CMD     EQU     %00111000       ;LCD Data
LCD_ENTRY_MD_CMD    EQU     %00000110
LCD_DISP_ON_CMD     EQU     %00001110
LCD_DISP_CLR_CMD    EQU     %00000001
LCD_MEM_LOC_1_CMD   EQU     %10000000
LCD_MEM_LOC_2_CMD   EQU     %11000000
DATA_WRITE_MASK     EQU     %01000010
CMD_WRITE_MASK      EQU     %00000010
PORTJ               EQU     $0268
DDRJ                EQU     $026A
J_IOMASK            EQU     %11111110
PORTH               EQU     $0260
DDRH                EQU     $0262
H_IOMASK            EQU     %11111111
FIRST_HALF          FCB     $0000
SECOND_HALF         FCB     $0000
Threshold           EQU     $55 	        ;Wall Closeness
PORTP               EQU     $0258           ;Motor Control Data
DDRP                EQU     $025A
P_IOMASK            EQU     %11000000
DATA_1              EQU     $1804           ;Counters for each motor rev
DATA_0              EQU     $1806           ;Not sure if above 1800 is reserved
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
RIGHT_MASK          EQU     %10000000
LEFT_MASK           EQU     %01000000
LEFT_SENSOR         EQU     $1800
CENTER_SENSOR       EQU     $1801
RIGHT_SENSOR        EQU     $1802
DEGREE_90_TURN      EQU     !425
DEGREE_180_TURN     EQU     !1000
FLAGGY              EQU     $1810

;******************************************************************************;
;MAIN - Central Routine for program.
;******************************************************************************;
MAIN                ORG     PROGRAM_START   ;Starting address for the program
                    LDS     #INIT_STACK		;Initialize the Stack
                    SEI						;Disable Maskable Interrupts
                    JSR		INIT_INTERRUPT
                    JSR		INIT_OUTPUT
                    JSR     INIT_LCD

                    MOVB    #!0,FLAGGY

                    MOVB    #FORWARD_MASK,PORTP
                    LDD     #!5
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP

                    JSR     SAVE_SENSORS

                    MOVB    #ATD1CTL2_MASK,ATD1CTL2
MOVING
                    JSR     REFRSH_SENSORS

                    JSR     CHK_CENT_BLK
                    JSR     CHK_VEER_RIGHT
                    JSR     CHK_VEER_LEFT
; IF_MOVE             LDAB    FLAGGY
;                     CMPB    #!1
;                     BEQ     END_LOGIC
                    ; JSR     CHK_OPN_RIGHT
END_LOGIC
                    MOVB    #FORWARD_MASK,PORTP
                    LDD     #!5
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP

                    JSR     PRINT_MEMORY

                    JMP     MOVING

                    MOVW    #$0000,TSCR1	;Clear T1 Pulse Accumulator
                    MOVW    #$0000,TC2	    ;Clear T1 Pulse Accumulator
                    MOVW    #$0000,TC3	    ;Clear T1 Pulse Accumulator

                    SWI
END_MAIN            END

REFRSH_SENSORS
                    MOVB    #ATD1CTL3_MASK,ATD1CTL3
                    MOVB    #ATD1CTL4_MASK,ATD1CTL4
                    MOVB    #ATD1CTL5_MASK,ATD1CTL5

MAIN_POLL           BRCLR   ATDSTAT,$80,MAIN_POLL
                    JSR     SAVE_SENSORS
                    JSR     PRINT_MEMORY

END_REFRSH_SENSORS  RTS

;******************************************************************************;
;CHK_OPN_RIGHT - Decides if the robot should turn right.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
CHK_OPN_RIGHT       LDAA    #$20
                    CMPA    RIGHT_SENSOR
                    BLS     END_CHK_OPN_RIGHT
                    MOVB    #!1,FLAGGY
                    JSR     PRINT_SPOT

                    MOVB    #FORWARD_MASK,PORTP
                    LDD     #!425
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP

                    JSR     REFRSH_SENSORS

                    ; LDAA    #$20
                    ; CMPA    CENTER_SENSOR
                    ; BHI     END_CHK_OPN_RIGHT
                    JSR     CLEAR_SPOT

                    LDAA    #$20
                    CMPA    RIGHT_SENSOR
                    BLS     END_CHK_OPN_RIGHT

                    MOVB    #LEFT_MASK,PORTP
                    LDD     #DEGREE_90_TURN
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP

                    ; JSR     REFRSH_SENSORS

                    ; MOVB    #FORWARD_MASK,PORTP
                    ; LDD     #!100
                    ; PSHD
                    ; JSR		MOVE
                    ; LEAS    2,SP

END_CHK_OPN_RIGHT   RTS


;******************************************************************************;
;CHK_CENT_BLK - Decides what happens when the robot has approached a wall.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
CHK_CENT_BLK        LDAA    #$55
                    CMPA    CENTER_SENSOR
                    BHI     END_CHK_CENT_BLK
                    MOVB    #!0,FLAGGY

                    LDAA    #$35
                    CMPA    RIGHT_SENSOR
                    BLS     TURN_RIGHT

                    MOVB    #LEFT_MASK,PORTP
                    LDD     #DEGREE_90_TURN
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP
                    JMP     END_CHK_CENT_BLK
TURN_RIGHT
                    MOVB    #RIGHT_MASK,PORTP
                    LDD     #DEGREE_90_TURN
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP

END_CHK_CENT_BLK
                    RTS

;******************************************************************************;
;CHK_VEER_RIGHT - Keeps the robot in the middle of the path.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
CHK_VEER_RIGHT      LDAA    #$55
                    CMPA    RIGHT_SENSOR
                    BHI     END_CHK_VEER_RIGHT
                    MOVB    #!0,FLAGGY

                    MOVB    #RIGHT_MASK,PORTP
                    LDD     #!5
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP
END_CHK_VEER_RIGHT  RTS

;******************************************************************************;
;CHK_VEER_LEFT - Keeps the robot in the middle of the path.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
CHK_VEER_LEFT       LDAA    #$55
                    CMPA    LEFT_SENSOR
                    BHI     END_CHK_VEER_LEFT
                    MOVB    #!0,FLAGGY

                    MOVB    #LEFT_MASK,PORTP
                    LDD     #!10
                    PSHD
                    JSR		MOVE
                    LEAS    2,SP
END_CHK_VEER_LEFT   RTS

;******************************************************************************;
;INIT_LCD - Starts up the LCD
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
INIT_LCD            LDAA    #J_IOMASK       ;Initialize Port J
                    PSHA                    ;
                    LDD     #DDRJ           ;
                    PSHD                    ;
                    JSR     INIT_PORT       ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #H_IOMASK       ;Initialize Port H
                    PSHA                    ;
                    LDD     #DDRH           ;
                    PSHD                    ;
                    JSR     INIT_PORT       ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #%00001111      ;Blinkies!!!!
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #LCD_FUNC_ON_CMD;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack
END_INIT_LCD        RTS


PRINT_SPOT          LDAA    #LCD_MEM_LOC_2_CMD;clear the display
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$4C            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack
END_PRINT_SPOT      RTS


CLEAR_SPOT          LDAA    #LCD_MEM_LOC_2_CMD;clear the display
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$20            ;' '
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack
END_CLEAR_SPOT      RTS
;******************************************************************************;
;MOVE - Moves the robot forward for a specified number of pulses.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Number of pulses           - Value         - 16 bits - Input
;******************************************************************************;
MOVE                MOVW    #$0000,DATA_1	;Clear T1 Pulse Accumulator
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
;SAVE_SENSORS - Saves the values at the registers used for the ATD conversion.
;( 0 ) - Return Address    - Value     - 16 bits - Input
;******************************************************************************;
SAVE_SENSORS        LDAB    ATD1DR0H
                    STAB    $1800
                    LDAB    ATD1DR1H
                    STAB    $1801
                    LDAB    ATD1DR2H
                    STAB    $1802
END_SAVE_SENSORS    RTS

;******************************************************************************;
;PRINT_SENSORS - Prints the values at the registers used for the ATD conversion.
;( 0 ) - Return Address    - Value     - 16 bits - Input
;******************************************************************************;
PRINT_SENSORS       LDAB    ATD1DR0H
                    CLRA
                    STAB    $1800
                    PSHD
                    LDAB    ATD1DR1H
                    CLRA
                    STAB    $1801
                    PSHD
                    LDAB    ATD1DR2H
                    CLRA
                    STAB    $1802
                    PSHD
                    LDD     #INFO
                    LDX     PRINTF
                    JSR     0,X
                    LEAS    6,SP
END_PRINT_SENSORS   RTS

;******************************************************************************;
;BUSY_WAIT - This routine is used in order to display characters to the LCD as
;fast as possible. Rather than waiting a known amount of time in between sending
;information, this routine is used to query the microcontroller inside the LCD
;in order to determine whether data is able to be accepted.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;******************************************************************************;
BUSY_WAIT           LDAA    #%00000000      ;Port H (LCD) clear all to Read
                    STAA    DDRH            ;.
                    LDAA    PORTJ           ;Clear Port J6 (RS of LCD)
                    ANDA    #%10111111      ;.
                    STAA    PORTJ           ;.
                    LDAA    PORTJ           ;Set Port J7 (R/W of LCD)
                    ORAA    #%10000000      ;.
                    STAA    PORTJ           ;.
                    NOP                     ;Wait for Address Setup Time (tAS)
BUSY_READ           LDAA    PORTJ           ;Set Port J1 (Enable of LCD)
                    ORAA    #%00000010      ;.
                    STAA    PORTJ           ;.
                    NOP                     ;Wait for Data Access Time (tDA)
                    LDAB    PORTH           ;Get the contents of PORTH
                    LDAA    PORTJ           ;Clear Port J1 (Enable of LCD)
                    ANDA    #%11111101      ;.
                    STAA    PORTJ           ;.
                    NOP                     ;
                    NOP                     ;
                    ANDB    #%10000000      ;
                    CMPB    #%10000000      ;
                    BEQ     BUSY_READ
                    LDAA    #%11111111      ;Port H (LCD) set all to Write
                    STAA    DDRH            ;.
END_BUSY_WAIT       RTS

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

					LDD     #$4000          ;duty
					STD     TC2
					LDD     #$4000
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
;PRINT_MEMORY - Routine for displaying the contents of a memory location to
;an attached LCD
;******************************************************************************;
PRINT_MEMORY
                    LDAA    #LCD_MEM_LOC_1_CMD;clear the display
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$4C            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$3A            ;':'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDD     #FIRST_HALF
                    PSHD
                    LDD     #SECOND_HALF
                    PSHD
                    LDAB    $1800
                    CLRA
                    PSHD
                    JSR     MEM_TO_ASCII
                    LEAS    6,SP            ;Clean up the stack

                    LDD     FIRST_HALF      ;
                    PSHB                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDD     SECOND_HALF     ;
                    PSHB
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$20            ;' '
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$43            ;'C'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$3A            ;':'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDD     #FIRST_HALF
                    PSHD
                    LDD     #SECOND_HALF
                    PSHD
                    LDAB    $1801
                    CLRA
                    PSHD
                    JSR     MEM_TO_ASCII
                    LEAS    6,SP            ;Clean up the stack

                    LDD     FIRST_HALF      ;
                    PSHB                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDD     SECOND_HALF     ;
                    PSHB
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$20            ;' '
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$52            ;'R'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$3A            ;':'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDD     #FIRST_HALF
                    PSHD
                    LDD     #SECOND_HALF
                    PSHD
                    LDAB    $1802
                    CLRA
                    PSHD
                    JSR     MEM_TO_ASCII
                    LEAS    6,SP            ;Clean up the stack

                    LDD     FIRST_HALF      ;
                    PSHB                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDD     SECOND_HALF     ;
                    PSHB
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

END_PRINT_MEMORY    RTS

;******************************************************************************;
;MEM_TO_ASCII - Sends a character to an I/O port.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Memory Address             - Value         - 16 bits - Input
;( 4 ) - Second Half Address        - Reference     - 16 bits - Input
;( 6 ) - First Half Address         - Reference     - 16 bits - Input
;******************************************************************************;
MEM_TO_ASCII        LDD     2,SP
                    LDX     #$10
                    IDIV
IF_IS_NUM           CPD     #$0009
                    BHI     ELSE_IS_NUM
                    ADDD    #$0030
                    LDY     4,SP
                    STD     0,Y
                    JMP     END_IS_NUM
ELSE_IS_NUM         ADDD    #$0037
                    LDY     4,SP
                    STD     0,Y
END_IS_NUM
                    PSHX
                    PULD
IF_IS_NUM_2         CPD     #$0009
                    BHI     ELSE_IS_NUM_2
                    ADDD    #$0030
                    LDY     6,SP
                    STD     0,Y
                    JMP     END_IS_NUM_2
ELSE_IS_NUM_2       ADDD    #$0037
                    LDY     6,SP
                    STD     0,Y
END_IS_NUM_2

END_MEM_TO_ASCII    RTS

;******************************************************************************;
;PULSE_E - Pulses the 1st pin of the J port.
;******************************************************************************;
PULSE_E             LDAB    PORTJ
                    ADDB    #%00000010
                    STAB    PORTJ
                    LDAB    PORTJ
                    SUBB    #%00000010
                    STAB    PORTJ
END_PULSE_E         RTS

;******************************************************************************;
;LCD_DATA - Sends a character to an I/O port. It pauses for 50 microseconds
;before sending in order for the commands to be sent successfully. Improving
;this function requires polling the R/W port.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Port                       - Reference     - 16 bits - Input
;( 4 ) - Command                    - Value         - 8  bits - Input
;******************************************************************************;
LCD_DATA            JSR     BUSY_WAIT
                    LDX     2,SP
                    LDAA    4,SP
                    STAA    0,X
                    LDAB    #%01000000
                    STAB    PORTJ
                    JSR     PULSE_E
END_LCD_DATA        RTS

;******************************************************************************;
;LCD_COMMAND - Sends a command to an I/O port. It pauses for 50 microseconds
;before sending in order for the commands to be sent successfully. Improving
;this function requires polling the R/W port.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Port                       - Reference     - 16 bits - Input
;( 4 ) - Command                    - Value         - 8  bits - Input
;******************************************************************************;
LCD_COMMAND         JSR     BUSY_WAIT
                    LDX     2,SP
                    LDAA    4,SP
                    STAA    0,X
                    LDAB    #%00000000
                    STAB    PORTJ
                    JSR     PULSE_E
END_LCD_COMMAND     RTS

;******************************************************************************;
;DELAY_X - Causes the program to 'delay' for a long period of time. It
;accomplishes this by simply eating clock cycles for a predetermined number of
;this value is: ((DesiredDelayTime/(1/16E6) - 11)/4)/65535.
;( 0 ) - Return Address    - Value     - 16 bits - Input
;( 2 ) - Delay Iterations  - Value     - 16 bits - Input
;******************************************************************************;
DELAY_X             LDX     #$FFFF
INNER_DELAY_X       DEX
					BNE     INNER_DELAY_X
                    DEY
                    BNE     DELAY_X
                    RTS

;******************************************************************************;
;INIT_PORT - Prepares an I/O port for use. It applies the predetermined port
;configuration mask.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Data Direction Register    - Reference     - 16 bits - Input
;( 4 ) - Input/Output Mask          - Value         - 8  bits - Input
;******************************************************************************;
INIT_PORT           LDX     2,SP            ;X = DDR*
                    LDAA    4,SP            ;A = MASK
                    STAA    0,X             ;Apply the selected mask to the DDR
END_INIT_PORT       RTS

;******************************************************************************;
;T_0_INTERRUPT - Interrupt Service Routine that increments a pulse counter.
;******************************************************************************;
T_0_INTERRUPT
                    LDD     DATA_0			;DATA_0++
                    ADDD    #$0001			;.
                    STD     DATA_0			;.
                    LDAB    TFLG1			;Clear the Flag for interrupt T0
                    ORAB    %00000001		;.
                    STAB    TFLG1			;.
END_T_0_INTERRUPT   RTI						;Return From Interrupt

;******************************************************************************;
;T_1_INTERRUPT - Interrupt Service Routine that increments a pulse counter.
;******************************************************************************;
T_1_INTERRUPT
                    LDD     DATA_1			;DATA_1++
                    ADDD    #$0001			;.
                    STD     DATA_1			;.
                    LDAB    TFLG1			;Clear the Flag for interrupt T1
                    ORAB    %00000010		;.
                    STAB    TFLG1			;.
END_T_1_INTERRUPT   RTI						;Return From Interrupt
