;******************************************************************************;
;Lab9.asm
;
;Description:This program displays the sensor values used to determine distance
;to the wall.
;Written By: Adam Campbell
;
;Date Written:(3/21/17)
;
;Date Modified:
;
;******************************************************************************;
#HCS12

INIT_STACK          EQU     $3C00
PROGRAM_START       EQU     $2200
PROGRAM_DATA        EQU     $1900

                    ORG     PROGRAM_DATA
PRINTF              EQU     $EE88
INFO                FCB     'LEFT:%X  CENTER:%X  RIGHT:%X.',$0D,$0A,$00
ATD1CTL2            EQU     $0122
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

;******************************************************************************;
;MAIN - Central Routine for program.
;******************************************************************************;
MAIN                ORG     PROGRAM_START   ;Starting address for the program
                    LDS     #INIT_STACK		;Initialize the Stack
                    SEI						;Disable Maskable Interrupts

                    MOVB    #ATD1CTL2_MASK,ATD1CTL2

                    LDX     #$0FFF
                    JSR     DELAY

THINGY
                    MOVB    #ATD1CTL3_MASK,ATD1CTL3
                    MOVB    #ATD1CTL4_MASK,ATD1CTL4
                    MOVB    #ATD1CTL5_MASK,ATD1CTL5


MAIN_POLL           BRCLR   ATDSTAT,$80,MAIN_POLL

                    ; MOVB    #ATD1CTL3_MASK,ATD1CTL3
                    ; MOVB    #ATD1CTL4_MASK,ATD1CTL4
                    ; MOVB    #ATD1CTL5_MASK,ATD1CTL5
                    JSR     PRINT_SENSORS
                    LDY     #$004F
                    JSR     DELAY_X
                    JMP     THINGY

END_MAIN            SWI



;******************************************************************************;
;PRINT_SENSORS - Prints the values at the registers used for the ATD conversion.
;( 0 ) - Return Address    - Value     - 16 bits - Input
;******************************************************************************;
PRINT_SENSORS       LDAB    ATD1DR0H
                    CLRA
                    PSHD
                    LDAB    ATD1DR1H
                    CLRA
                    PSHD
                    LDAB    ATD1DR2H
                    CLRA
                    PSHD
                    LDD     #INFO
                    LDX     PRINTF
                    JSR     0,X
                    LEAS    6,SP
END_PRINT_SENSORS   RTS

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
;this value is: ((DesiredDelayTime/(1/24E6) - 11)/4)/65535.
;( 0 ) - Return Address    - Value     - 16 bits - Input
;TODO - Remove dependency on global constants by making them parameters.
;******************************************************************************;
DELAY_X             LDX     #$FFFF
INNER_DELAY_X       DEX
					BNE     INNER_DELAY_X
                    DEY
                    BNE     DELAY_X
END_INNER_DELAY_X   RTS
