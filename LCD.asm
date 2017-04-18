;******************************************************************************;
;Lab6.asm
;
;Description:This program dynamically displays content to an attached LCD.
;This content is displayed if an attached button is pressed within 2 seconds of
;the start of the program.
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
                                            ;Data for the program
                                            ;
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

                    LDS     #INIT_STACK

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


                    LDAA    #LCD_FUNC_ON_CMD;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #LCD_MEM_LOC_1_CMD;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #%00001111      ;Blinkies!!!!
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack
MONTE
                    LDAA    #$4D            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6F            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6E            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$74            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$65            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$20            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$43            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6F            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$78            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$20            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$63            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$61            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6E            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack


                    LDAA    #LCD_MEM_LOC_2_CMD      ;Blinkies!!!!
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$73            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$75            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$63            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6B            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$20            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6D            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$79            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$20            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$63            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6F            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$63            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$6B            ;'L'
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

END_MONTE
                    SWI


                    ; LDAA    #LCD_FUNC_ON_CMD;two lines
                    ; PSHA                    ;
                    ; LDD     #PORTH          ;
                    ; PSHD                    ;
                    ; JSR     LCD_COMMAND     ;
                    ; LEAS    3,SP            ;Clean up the stack

                    LDAA    #LCD_DISP_CLR_CMD;clear the display
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack


                    SWI
END_MAIN            END


BUSY_WAIT           LDAA    #%00000000      ;Port H (LCD) clear all to Read
                    STAA    DDRH            ;.
                    LDAA    PORTJ           ;Clear Port J6 (RS of LCD)
                    ANDA    #%10111111      ;.
                    STAA    PORTJ           ;.
                    LDAA    PORTJ           ;Set Port J7 (R/W of LCD)
                    ORAA    #%10000000      ;.
                    STAA    PORTJ           ;.
                    NOP                     ;Wait for Address Setup Time (tAS)
                    NOP
                    NOP
BUSY_READ           LDAA    PORTJ           ;Set Port J1 (Enable of LCD)
                    ORAA    #%00000010      ;.
                    STAA    PORTJ           ;.
                    NOP                     ;Wait for Data Access Time (tDA)
                    NOP
                    NOP
                    NOP
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
                    RTS



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
INNER_DELAY_X       DEX
					BNE     INNER_DELAY_X
                    DEY
                    BNE     DELAY_X
                    RTS
