;******************************************************************************;
;Lab3b.asm
;
;Description: This program calculates the trapezoidal velocity profile intended
;to be used with a mechanical robot. It recieves an input from the user in order
;to calculate this profile. It then displays that profile
;
;Written By: Adam Campbell
;
;Date Written: 1/24/2017
;
;Date Modified: 2/2/2017 Added Comments
;
;******************************************************************************;

;********************************* Symbols ************************************;
                    ORG     $1900
PUTCHAR				EQU		$EE86
GETCHAR             EQU     $EE84
PRINTF              EQU     $EE88
Ta                  EQU     $1000
Tc                  EQU     $1002
TTotalRef           EQU     $1004
VDelta              EQU     $1006
VConstant           EQU     $100A
TTotal              EQU     $100C
LOW					EQU		$0064
HIGH				EQU		$2710
MEDIUM				EQU		$03E8
RightVelocity       EQU     $2000
LeftVelocity        EQU     $2100
Title_String         FCB     '           MOTOR CONTROL SOFTWARE         ',$0D,$0A,$00
Velocity_String     FCB     'PLEASE CHOOSE A CONSTANT VELOCITY:',$0D,$0A,$00
Time_String     	FCB     'PLEASE CHOOSE A TOTAL TIME PERIOD:',$0D,$0A,$00
OP_STRING			FCB		'HIGH (1), MEDIUM (2), OR LOW (3)',$0D,$0A,$00
VEL_STRING			FCB		'VELOCITY %u:             %X     ',$0D,$0A,$00
Ta_String           FCB     'TA:         %X',$0D,$0A,$00
TC_String           FCB     'TC:         %X',$0D,$0A,$00
TTotal_String       FCB     'TTOTAL:     %X',$0D,$0A,$00
DELTAV_STRING       FCB     'DELTAV:     %X',$0D,$0A,$00
NEW_LINE			FCB		' ',$0D,$0A,$00
;******************************* End Symbols **********************************;

;********************************** Main **************************************;
MAIN                ORG     $2200   	    ;Starting Address

GET_INPUT_1			LDD     #Title_String
                    LDX     printf
                    JSR     0,X
                    LDD     #Velocity_String
                            LDX     printf
                            JSR     0,X
                    LDD     #OP_STRING
                    LDX     printf
                    JSR     0,X
                    LDX		GETCHAR
                    JSR		0,X
                    LDX		PUTCHAR
                    JSR		0,X
                    PSHB
                    LDD     #NEW_LINE
                    LDX     printf
                    JSR     0,X
                    PULB
                    CMPB	#$31
                    BEQ		FIRST_OPTION_1
                    CMPB	#$32
                    BEQ		SECOND_OPTION_1
                    CMPB	#$33
                    BEQ		THIRD_OPTION_1
                    BRA		END_GET_INPUT_1
FIRST_OPTION_1		LDD		#HIGH
                    STD		VConstant
                    BRA		END_GET_INPUT_1
SECOND_OPTION_1		CMPB	$32
                    LDD		#MEDIUM
                    STD		VConstant
                    BRA		END_GET_INPUT_1
THIRD_OPTION_1		CMPB	$33
                    LDD		#LOW
                    STD		VConstant
                    BRA		END_GET_INPUT_1
END_GET_INPUT_1

GET_INPUT_2			LDD     #Time_String
                    LDX     printf
                    JSR     0,X
                    LDD     #OP_STRING
                    LDX     printf
                    JSR     0,X
                    LDX		GETCHAR
                    JSR		0,X
                    LDX		PUTCHAR
                    JSR		0,X
                    PSHB
                    LDD     #NEW_LINE
                    LDX     printf
                    JSR     0,X
                    PULB
                    CMPB	#$31
                    BEQ		FIRST_OPTION_2
                    CMPB	#$32
                    BEQ		SECOND_OPTION_2
                    CMPB	#$33
                    BEQ		THIRD_OPTION_2
                    BRA		END_GET_INPUT_2
FIRST_OPTION_2		LDD		#HIGH
                    STD		TTotal
                    BRA		END_GET_INPUT_2
SECOND_OPTION_2		CMPB	#$32
                    LDD		#MEDIUM
                    STD		TTotal
                    BRA		END_GET_INPUT_2
THIRD_OPTION_2		CMPB	#$33
                    LDD		#LOW
                    STD		TTotal
                    BRA		END_GET_INPUT_2
END_GET_INPUT_2

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

                    LDD     #LeftVelocity
                    PSHD
                    LDD     #RightVelocity
                    PSHD
                    LDD     VDelta
                    PSHD
                    JSR     PARSE_INTERVAL
                    PULD
                    PULD
                    PULD
                    PULD
					LDD		#RightVelocity
                    PSHD
                    JSR	   	DISP_PROFILE
                    LDD     Ta
                    PSHD
                    LDD     #Ta_String
                    LDX     printf
                    JSR     0,X

                    LDD     Tc
                    PSHD
                    LDD     #TC_String
                    LDX     printf
                    JSR     0,X

                    LDD     TTotalRef
                    PSHD
                    LDD     #TTotal_String
                    LDX     printf
                    JSR     0,X

                    LDD     VDelta
                    PSHD
                    LDD     #DELTAV_STRING
                    LDX     printf
                    JSR     0,X
					SWI
END_MAIN            END
;********************************* End Main ***********************************;

;******************************************************************************;
;DISP_PROFILE - Displays the velocity profile
;( 0 ) - Return Address    - Value     - 16 bits - Input
;( 2 ) - Profile Address   - Value     - 16 bits - Input
;******************************************************************************;
DISP_PROFILE
                    LDY     2,SP
                    LDAA    #$01
WHILE_4             CMPA    #$1F
                    BEQ     END_WHILE_4
                    PSHA                    ;Store our loop index
                    PSHY
                    LDD		0,Y
                    PSHD
                    LDAB	4,SP
                    CLRA
                    PSHD
                    LDD     #VEL_STRING
                    LDX     printf
                    JSR     0,X
                    PULD
                    PULD
                    PULY
                    INY
                    INY
                    PULA
                    INCA
                    BRA     WHILE_4
END_WHILE_4

END_DISP_PROFILE    RTS


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
CALC_INTERVAL
                    LDD     2,SP            ;Load TTotal
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
PARSE_INTERVAL
                    LDX     6,SP            ;Left Velocity
                    LDY     4,SP            ;Right Velocity
                    LDD		#$0000
					STD	    2,X+
                    STD     2,Y+
                    PSHD
                    LDAA    #$00
WHILE_1             CMPA    #$0A            ;While A != 9
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
WHILE_2             CMPA    #$08            ;While A != 10
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
                    LDD     0,SP
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
                    LDD     #$0000
                    STD	    2,X+            ;
                    STD     2,Y+

                    PULD
END_PARSE_INTERVAL  RTS
