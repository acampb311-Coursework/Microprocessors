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
                                            ;Data for the program
                                            ;
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
DelayTime           EQU     $FFFF
DATA_WRITE_MASK     EQU     %01000010
CMD_WRITE_MASK      EQU     %00000010

;******************************************************************************;
;MAIN - Central Subroutine for program.
;******************************************************************************;
MAIN                ORG     $2200           ;Starting address for the program
                                            ;
                                            ;Initialize the ports
                                            ;
                    LDAA    #J_IOMASK       ;Initialize Port J
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

                    LDAA    #$48            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$75            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$66            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$66            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6C            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$65            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$63            ;two lines
                    PSHA                    ;ser
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$75            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$63            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6B            ;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack




                    SWI
END_MAIN            END



PULSE_E             LDAB    #%00000010
                    STAB    PORTJ
                    LDX     #FIFTY_U_DELAY  ;Delay the program 50 microseconds
                    JSR     DELAY
                    LDAB    #%00000000
                    STAB    PORTJ
END_PULSE_E         RTS

PULSE_E2            LDAB    #%01000010
                    STAB    PORTJ
                    LDX     #FIFTY_U_DELAY  ;Delay the program 50 microseconds
                    JSR     DELAY
                    LDAB    #%01000000
                    STAB    PORTJ
END_PULSE_E2        RTS

;******************************************************************************;
;LCD_DATA - Sends a character to an I/O port. It pauses for 50 microseconds
;before sending in order for the commands to be sent successfully. Improving
;this function requires polling the R/W port.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Port                       - Reference     - 16 bits - Input
;( 4 ) - Command                    - Value         - 8  bits - Input
;******************************************************************************;
LCD_DATA            LDAB    #%01000000      ;Clear the drive ports
                    STAB    PORTJ
                    LDX     #FIFTY_U_DELAY  ;Delay the program 50 microseconds
                    JSR     DELAY
                    LDX     2,SP
                    LDAA    4,SP
                    STAA    0,X
                    LDX     #FIFTY_U_DELAY  ;Delay the program 50 microseconds
                    JSR     DELAY
                    JSR     PULSE_E2
END_LCD_DATA        RTS

;******************************************************************************;
;LCD_COMMAND - Sends a command to an I/O port. It pauses for 50 microseconds
;before sending in order for the commands to be sent successfully. Improving
;this function requires polling the R/W port.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Port                       - Reference     - 16 bits - Input
;( 4 ) - Command                    - Value         - 8  bits - Input
;******************************************************************************;
LCD_COMMAND         LDAB    #%00000000      ;Clear the drive ports
                    STAB    PORTJ
                    LDX     #FIFTY_U_DELAY  ;Delay the program 50 microseconds
                    JSR     DELAY
                    LDX     2,SP
                    LDAA    4,SP
                    STAA    0,X
                    LDX     #FIFTY_U_DELAY  ;Delay the program 50 microseconds
                    JSR     DELAY
                    JSR     PULSE_E
END_LCD_COMMAND     RTS

;******************************************************************************;
;INIT_PORT - Prepares an I/O port for use. It applies the predetermined port
;configuration mask.
;( 0 ) - Return Address             - Value         - 16 bits - Input
;( 2 ) - Data Direction Register    - Reference     - 16 bits - Input
;( 4 ) - Input/Output Mask          - Value         - 8  bits - Input
;******************************************************************************;
INIT_PORT           LDX     2,SP
                    LDAA    4,SP
                    STAA    0,X
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
