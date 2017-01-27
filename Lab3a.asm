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

;********************************* Symbols ************************************;
Ta                  EQU     $1000
Tc                  EQU     $1002
TTotalRef           EQU     $1004
VDelta              EQU     $1006
VConstant           EQU     $100A
TTotal              EQU     $100C
RightVelocity       EQU     $2000
LeftVelocity        EQU     $2100
;******************************* End Symbols **********************************;

;********************************** Main **************************************;
MAIN                ORG     $2200   	    ;Starting Address
                    ;LDS		#$3C00          ;Set the SP
                    LDD     #VDelta         ;Pass the VDelta var by reference
                    PSHD
                    LDD     #TTotalRef      ;Pass the TTotalRef var by reference
                    PSHD                    ;
                    LDD     #Tc             ;Pass the Tc var by reference
                    PSHD                    ;
                    LDD     #Ta             ;Pass the Ta var by reference
                    PSHD                    ;
                    LDD		VConstant       ;Pass the VConstant var by value
                    PSHD                    ;
                    LDD	    TTotal          ;Pass the TTotal var by value
                    PSHD                    ;
                    JSR     CALC_INTERVAL   ;
					PULD
					PULD
					PULD
					PULD
					PULD
					PULD
					LDD     #$1000
                    PSHD
                    LDD     #LeftVelocity
                    PSHD
                    LDD     #RightVelocity
                    PSHD
                    LDD     VDelta
                    PSHD
                    JSR     PARSE_INTERVAL
END_MAIN            END
;********************************* End Main ***********************************;

;******************************************************************************;
;CALC_INTERVAL - This routine computes the acceleration time interval, Ta, the
;constant velocity interval, Tc. and the deceleration period, Td.
;The routine expects the following parameters (on the stack):
;( 0 ) - Return Address - Value     - 16 bits - Input
;( 2 ) - TTotal         - Value     - 16 bits - Input
;( 4 ) - VConstant      - Value     - 16 bits - Input
;( 6 ) - Ta             - Reference - 16 bits - Output
;( 8 ) - Tc             - Reference - 16 bits - Output
;( 10) - TTotalRef      - Reference - 16 bits - Output
;( 12) - VDelta         - Reference - 16 bits - Output
;******************************************************************************;
CALC_INTERVAL       LDD     2,SP            ;Load TTotal
                    LDX     #!5             ;
                    IDIV                    ;X = D / X;
                    LDY     6,SP            ;*Ta = X
                    STX     0,Y             ;
                    LDD     2,SP            ;D = TTotal
					LDX		6,SP
                    SUBD    $0,X            ;(D = D - Ta) ~ Tc
                    LDY     8,SP            ;Tc = D
                    STD     0,Y             ;
                    LDD     2,SP            ;TTotalRef = TTotal
                    LDY     $0A,SP           ;
                    STD     0,Y             ;
                    LDD     4,SP            ;D = VConstant
                    LDX     #!10            ;X = 10
                    IDIV                    ;X = VConstant / 10
                    LDY     $0C,SP           ;VDelta  = X
                    STX     0,Y
END_CALC_INTERVAL   RTS

;******************************************************************************;
;PARSE_INTERVAL - This routine computes the velocity necessary at a given index.
;This routine assumes that the fact that vdelta is stored in 16 bits of memory
;is a very inefficient use of memory and splits the 16 bits into two 8 bit chunks
;and only reads the .......
;( 0 ) - Return Address - Value     - 16 bits - Input
;( 2 ) - VDelta         - Reference - 16 bits - Input
;( 4 ) - RightVelocity  - Reference - 16 bits - Output
;( 6 ) - LeftVelocity   - Reference - 16 bits - Output
;******************************************************************************;
PARSE_INTERVAL      LDX     6,SP            ;Left Velocity
                    LDY     4,SP            ;Right Velocity
                    LDD		#$0000
					STD	    2,X+
                    STD     2,Y+
                    PSHD
                    LDAA    #$00
WHILE_1             CMPA    #$09            ;While A != 9
                    BEQ     END_WHILE_1     ;{
                    PSHA                    ;    Throw A into stack (8 bits)
                    LDD		1,SP            ;    D is the current velocity that it is being incremented
                    ADDD	5,SP            ;    D = D + VDelta
                    STD	    2,X+            ;    Store for Left Velocity
                    STD     2,Y+            ;    Store for Right Velocity
                    STD		1,SP            ;    Store the current value of D
                    LDAA	0,SP		    ;    Load the value of the index for the loop
					PULB
                    LDAB	#$00            ;    Clear the B register
                    INCA                    ;    A++
					BRA     WHILE_1         ;}
END_WHILE_1
		   			LDD		0,SP            ;    D is the current velocity that it is being incremented
                    ADDD	4,SP            ;    D = D + VDelta
                    LDAA    #$00
WHILE_2             CMPA    #$0A            ;While A != 10
                    BEQ     END_WHILE_2     ;{
                    PSHA                    ;    Throw A into stack (8 bits)
                    LDD		1,SP            ;    D is the current velocity that it is being incremented
                    STD	    2,X+            ;    Store for Left Velocity
                    STD     2,Y+            ;    Store for Right Velocity
                    LDAA	0,SP		    ;    Load the value of the index for the loop
					PULB
                    LDAB	#$00            ;    Clear the B register
                    INCA                    ;    A++
					BRA     WHILE_2         ;}
					PULA
END_WHILE_2
		   			STD	    2,X+            ;
                    STD     2,Y+
                    LDAA    #$00
WHILE_3             CMPA    #$09            ;While A != 10
                    BEQ     END_WHILE_3     ;{
                    PSHA                    ;    Throw A into stack (8 bits)
                    LDD		1,SP            ;    D is the current velocity that it is being incremented
                    SUBD	5,SP            ;    D = D + VDelta
                    STD	    2,X+            ;    Store for Left Velocity
                    STD     2,Y+            ;    Store for Right Velocity
                    STD		1,SP            ;    Store the current value of D
                    LDAA	0,SP		    ;    Load the value of the index for the loop
                    PULB
                    LDAB	#$00            ;    Clear the B register
                    INCA                    ;    A++
                    BRA     WHILE_3         ;}
END_WHILE_3
                    PULD
END_PARSE_INTERVAL  RTS
