;********************************* Symbols ************************************;
					ORG     $1900
PUTCHAR				EQU		$EE86
GETCHAR             EQU     $EE84
PRINTF              EQU     $EE88
VConstant           EQU     $100A
TTotal              EQU     $100C
HIGH				EQU		$2710
MEDIUM				EQU		$02E8
LOW					EQU		$0064
Velocity_String     FCB     'PLEASE CHOOSE A CONSTANT VELOCITY:',$0D,$0A,$00
Time_String     	FCB     'PLEASE CHOOSE A TOTAL TIME PERIOD:',$0D,$0A,$00
OP_STRING			FCB		'HIGH (1), MEDIUM (2), OR LOW (3)',$0D,$0A,$00
NEW_LINE			FCB		' ',$0D,$0A,$00
;******************************* End Symbols **********************************;

;********************************** Main **************************************;
MAIN                ORG     $2200   	    ;Starting Address

GET_INPUT_1			LDD     #Velocity_String
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
					CMPB	$31
					BEQ		FIRST_OPTION_1
					CMPB	$32
					BEQ		SECOND_OPTION_1
					CMPB	$33
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
					CMPB	$32
					BEQ		FIRST_OPTION_2
					CMPB	$32
					BEQ		SECOND_OPTION_2
					CMPB	$33
					BEQ		THIRD_OPTION_2
					BRA		END_GET_INPUT_2
FIRST_OPTION_2		LDD		#HIGH
					STD		TTotal
					BRA		END_GET_INPUT_2
SECOND_OPTION_2		CMPB	$32
					LDD		#MEDIUM
					STD		TTotal
					BRA		END_GET_INPUT_2
THIRD_OPTION_2		CMPB	$33
					LDD		#LOW
					STD		TTotal
					BRA		END_GET_INPUT_2
END_GET_INPUT_2
                    SWI
END_MAIN            END
