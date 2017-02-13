;******************************************************************************;
;Lab6.asm
;
;Description:
;
;Written By: Adam Campbell
;
;Date Written: 2/6/2017
;
;Date Modified:
;
;******************************************************************************;
#HCS12
                                            ;Data for the program
                                            ;TODO
INIT_STACK          EQU     $3C00
PROGRAM_START       EQU     $2200
PROGRAM_DATA        EQU     $1900

                    ORG     PROGRAM_DATA
PORTJ               EQU     $0268
DDRJ                EQU     $026A
J_IOMASK            EQU     %11111110
PORTH               EQU     $0260
DDRH                EQU     $0262
H_IOMASK            EQU     %11111111
FIFTY_U_DELAY       EQU     $0136           ;(50E-6/(1/25E6) - 11)/4
SEVEN_M_DELAY       EQU     $AAE3           ;(7E-3/(1/(25E6)) - 11)/4
LCD_FUNC_ON_CMD     EQU     %00111000
LCD_ENTRY_MD_CMD    EQU     %00000110
LCD_DISP_ON_CMD     EQU     %00001110
LCD_DISP_CLR_CMD    EQU     %00000001
LCD_MEM_LOC_1_CMD   EQU     %10000000
LCD_MEM_LOC_2_CMD   EQU     %11000000
DATA_WRITE_MASK     EQU     %01000010
CMD_WRITE_MASK      EQU     %00000010
IRQ_VECTOR          EQU     $3E72
PRINTF              EQU     $EE88
USER_VECTOR         EQU     $EEA4
IRQ_OFFSET          EQU     !57
IRQ_PIN             EQU     $001E
IRQ_ENABLE_MASK     EQU     %11000000
IRQ_EDGE_MASK       EQU     %10000000
AWK_STRING          FCB     'Button Pressed!:',$0D,$0A,$00
INTERRUPT_FLAG      FCB     $00
FIRST_HALF          FCB     $0000
SECOND_HALF         FCB     $0000
Threshold           EQU     $55 	       ;Wall Closeness

;******************************************************************************;
;MAIN - Central Routine for program.
;******************************************************************************;
MAIN                ORG     PROGRAM_START  ;Starting address for the program
                    SEI
                    LDS     #INIT_STACK
                    LDD     #INTERRUPT_SUBR
                    STD     $3E72
                    PSHD
                    LDD     #!57
                    LDX     $EEA4
                    JSR     0,X

                    LDAA    #IRQ_ENABLE_MASK
                    STAA    IRQ_PIN
                    LDAA    $3000   	    ;Load the sensor data into register A
                    STAA    $1800   	    ;Store the sensor data into address $1800
                    LDAA    $3001   	    ;Load the sensor data into register A
                    STAA    $1801   	    ;Store the sensor data into address $1801
                    LDAA    $3002   	    ;Load the sensor data into register A
                    STAA    $1802   	    ;Store the sensor data into address $1802
                    LDAA 	$1800		    ;A = sensor data
                    CMPA    #Threshold	    ;Compare sensor data to threshold value
IF1	                BLS		ELSE1		    ;If (A > Threshold)
                    LDAA	#$00		    ;   A = 0
                    LDAB    #$01            ;   B = 1
WHILE1              CMPA    #$0F            ;   While (A != 15)
                    BEQ     END_WHILE1      ;
                    ABA                     ;       A = B + A
                    INCB                    ;       B++
                    BRA     WHILE1          ;   PC = While1
END_WHILE1          STAA	$1800		    ;$1800 = A
ELSE1               LDAA	$1801		    ;A = sensor data
                    CMPA	#Threshold	    ;Compare sensor data to threshold value
IF2                 BLS		ELSE2		    ;If (A > Threshold)
                    LDAA	#$00		    ;   A = 0
                    STAA	$1801		    ;   $1801 = A
ELSE2               LDAA	$1802		    ;A = sensor data
                    CMPA    #Threshold	    ;Compare sensor data to threshold value
IF3	                BLS		ELSE3		    ;If (A > Threshold)
                    LDAA	$1802		    ;   A = (Contents Of)$1802
                    LDAB	#$10		    ;   B = 10
                    SBA					    ;   A = A - B
                    STAA	$1802 		    ;$1802 = A
ELSE3	            					    ;
                                            ;
                                            ;Initialize the ports
                                            ;
                    LDAA    #J_IOMASK       ;Initialize Port J
                    PSHA                    ;
                    LDD     #DDRJ           ;
                    PSHD                    ;
                    JSR     INIT_PORT       ;
                    LEAS    3,SP            ;Clean up the stack
                                            ;
                    LDAA    #H_IOMASK       ;Initialize Port H
                    PSHA                    ;
                    LDD     #DDRH           ;
                    PSHD                    ;
                    JSR     INIT_PORT       ;
                    LEAS    3,SP            ;Clean up the stack
                                            ;
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

                    LDAA    #LCD_DISP_CLR_CMD;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    ; LDAA    #%11000000      ;Second line
                    ; PSHA                    ;
                    ; LDD     #PORTH          ;
                    ; PSHD                    ;
                    ; JSR     LCD_COMMAND     ;
                    ; LEAS    3,SP            ;Clean up the stack

                    LDAA    #$00
                    STAA    INTERRUPT_FLAG
                    CLI
                    LDY     #!122  ;Delay the program 2 seconds
                    PSHY
                    JSR     DELAY_X
                    SEI
                    LDAA    INTERRUPT_FLAG

IF_INTERRUPT        CMPA    #$01
                    BNE     END_IF_INTERRUPT
                    JSR     PRINT_MEMORY
END_IF_INTERRUPT
                    SWI
END_MAIN            END


PRINT_MEMORY        LDAA    #$4C            ;'L'
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
;MEM_TO_ASCII - Sends a character to an I/O port. It pauses for 50 microseconds
;before sending in order for the commands to be sent successfully. Improving
;this function requires polling the R/W port.
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
                    LDX     #FIFTY_U_DELAY  ;Delay the program 50 microseconds
                    JSR     DELAY
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
LCD_DATA            LDX     2,SP
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
LCD_COMMAND         LDX     2,SP
                    LDAA    4,SP
                    STAA    0,X
                    LDAB    #%00000000
                    STAB    PORTJ
                    JSR     PULSE_E
END_LCD_COMMAND     RTS

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
;DELAY_X - Causes the program to 'delay' for a long period of time. It
;accomplishes this by simply eating clock cycles for a predetermined number of
;this value is: ((DesiredDelayTime/(1/16E6) - 11)/4)/65535.
;( 0 ) - Return Address    - Value     - 16 bits - Input
;( 2 ) - Delay Iterations  - Value     - 16 bits - Input
;******************************************************************************;
DELAY_X             LDX     #$FFFF
                    ; LDY     2,SP
INNER_DELAY_X       DEX
					BNE     INNER_DELAY_X
                    DEY
                    ; STY     2,SP
                    BNE     DELAY_X
                    RTS

INTERRUPT_SUBR      SEI
                    LDY     #!75
                    JSR     DELAY_X
                    LDD     #AWK_STRING
                    LDX     PRINTF
                    JSR     0,X
                    LDAA    #$01
                    STAA    INTERRUPT_FLAG
                    CLI
END_INTERRUPT_SUBR  RTI
