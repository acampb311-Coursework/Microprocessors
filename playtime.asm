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



;******************************************************************************;
;MAIN - Central Routine for program.
;******************************************************************************;
MAIN                ORG     PROGRAM_START  ;Starting address for the program
                    SEI
                    LDS     #INIT_STACK

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



                    ; LDAA    #%00001111      ;Blinkies!!!!
                    ; PSHA                    ;
                    ; LDD     #PORTH          ;
                    ; PSHD                    ;
                    ; JSR     LCD_COMMAND     ;
                    ; LEAS    3,SP            ;Clean up the stack

                    LDAA    #LCD_FUNC_ON_CMD;two lines
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #%00001111      ;clear the display
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #LCD_DISP_CLR_CMD;clear the display
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #%01000000      ;Send the CGRAM Init command
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$0E            ;
                    STAA    $1500
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$11            ;
                    STAA    $1501
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$0E            ;
                    STAA    $1502
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$04            ;
                    STAA    $1503
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$1F            ;
                    STAA    $1504
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$04            ;
                    STAA    $1505
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$0A            ;
                    STAA    $1506
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$11            ;
                    STAA    $1507
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #LCD_DISP_CLR_CMD;clear the display
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #%11000000      ;
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #%00010100      ;
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_COMMAND     ;
                    LEAS    3,SP            ;Clean up the stack

                    LDAA    #$00            ;
                    PSHA                    ;
                    LDD     #PORTH          ;
                    PSHD                    ;
                    JSR     LCD_DATA        ;
                    LEAS    3,SP            ;Clean up the stack


;
;Check off by one because of zero based 1500
;

; FOR_IDX             LDAA    #$01            ;For idx = 1:32 (each box)
;                     PSHA                    ;IDX, 2,SP
;                     CMPA    #$20
;                     BEQ     END_FOR_IDX
; FOR_JDX             LDAA    #$01            ;For jdx = 1:8(times idx,plus $1500)
;                     PSHA                    ;JDX, 0,SP
;                     LDAB    2,SP
;                     MUL
;                     ABA     #$1500          ;A now has the address where we want to work
;
; END_FOR_JDX
;                     PULA
;                     JMP     FOR_IDX
;
; END_FOR_IDX



; CLC
; LDAA    ROW_1
; ASRA
; ANDA    #%01111111

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
                    RTS

;******************************************************************************;
;PULSE_E - Pulses the 1st pin of the J port.
;******************************************************************************;
PULSE_E             LDAB    PORTJ
                    ORAB    #%00000010
                    STAB    PORTJ
                    ; LDAB    PORTJ
                    ANDB    #%11111101
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
                    ; LDAB    #%00000000
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
