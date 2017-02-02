;************************************************************************************************************
;Lab3a.asm
;
;Description:	This program will perform two main functions:
;					First:	calculating the acceleration times necessary to approximate the velocity curve
;							for the robot's wheels and the change in velocity for each individual values
;							in the curve (used in the second function)
;
;					Second:	Using the given values and the calculated times to generate a list of velocities
;							at different points for later use when moving the robot's wheels.  A separate
;							list is generated for each wheel.
;
;Written by:	Zachary Downum
;
;Date written:	1/26/17
;
;Modified date:	N/A
;*************************************************************************************************************

	;Variables Section
						ORG		$100A				;Program data (including pointer variables) begins at $2200
Vconstant				EQU		$03E8				;These two variables hold the actual value of Vconstant and Ttotal
Ttotal					EQU		$0014
Ta						EQU		$1000				;Each of these variables are actually pointers to locations in memory
Tc						EQU		$1002				;the values they hold are memory locations where the data is stored
TtotalReference			EQU		$1004
deltaV					EQU		$1006

counter					EQU		$0000				;This will act as a generic counter variable in all subroutines
													;It is important to reset the value of the counter to 0 after using it

rightMotorVelocityList	EQU		$2000
leftMotorVelocityList	EQU		$2100

	;Main section
main
						ORG		$2200
						LDD		Vconstant							;loads the value of Vconstant and pushes it on the stack (by value)
						PSHD

						LDD		Ttotal								;loads the value of Ttotal and pushes it on the stack (by value)
						PSHD

						LDX		#Ta									;loads the address of Ta and pushes it on the stack (by reference)
																	;LDX is used because we are now accessing memory addresses instead of numerical values
						PSHX

						LDX		#Tc									;loads the address of Tc and pushes it on the stack (by reference)
						PSHX

						LDX		#deltaV								;loads the address of deltaV and pushes it on the stack (by reference)
						PSHX

						LDX		#TtotalReference					;loads the address of TtotalReference and pushes it on the stack (by reference)
						PSHX

						JSR		generateAccelerationIntervals		;calls the generateAccelerationIntervals subroutine passing the parameters Vconstant and Ttotal by value
																	;and Ta, Tc, deltaV, and TtotalReference by reference
																	;Stack at the point of this call:
																	;Return address:	$00,SP
																	;Vconstant value:	$0C,SP
																	;Ttotal value:		$0A,SP
																	;Ta reference:		$08,SP
																	;Tc reference:		$06,SP
																	;deltaV reference:	$04,SP
																	;TtotalReference:	$02,SP





;************************************************************************************************************
;generateAccelerationIntervals subroutine
;
;Description:	This subroutine will calculate the acceleration intervals used to generate the
;				velocity curve for the robot's wheels.  It also computs the change in velocity that will begins
;				used later when generating the list of velocities to use during robot movement over the
;				time intervals
;
;Written by:	Zachary Downum
;
;Date written:	2/1/17
;
;Modified date:	N/A
;
;Stack at the point of this call:
;Return address:	$00,SP
;Vconstant value:	$0C,SP
;Ttotal value:		$0A,SP
;Ta reference:		$08,SP
;Tc reference:		$06,SP
;deltaV reference:	$04,SP
;TtotalReference:	$02,SP
;*************************************************************************************************************
generateAccelerationIntervals
						LDD		$0A,SP								;Loads Ttotal (passed by value) into register D
						LDX		$02,SP								;Loads the contents of the reference to TtotalReference into register X (acting as a pointer to the TtotalReference variable)
						STD		$00,X								;Stores the contents of register D into the memory referenced by register X (TtotalReference)

						LDX		#$0005								;Loads $0005 into register X, register D still contains the value of Ttotal
						IDIV										;register D / register X -> X (remainder -> D), so Register X now holds the correct value of Ta
						LDY		$08,SP								;Loads the memory address referenced by $08,SP (Ta) into register Y
						STX		$00,Y								;Stores the contents of register X into the memory address referenced by register Y (Ta)

						LDD		$0A,SP								;Loads the value of Ttotal into register D
						SUBD	$00,Y								;Subtracts the value of the memory address referenced by register Y (Ta) from register D (Ttotal) and stores it back in register D
																	;Register D now holds the correct value of Tc

						LDX		$06,SP								;Loads the memory address referenced by $06,SP (Tc) into register X
						STD		$00,X								;Stores the contents of register D (Tc value) into the memory address referenced by register X (Tc)

						;Still need to compute and store deltaV and return

						LDD		$0C,SP								;Loads the value of Vconstant into register Date
						LDX		#$000A								;Loads the decimal value 10 into register X
						IDIV										;Divides Vconstant by 10, so register X now holds the correct value of deltaV
						LDY		$04,SP								;Loads a pointer to deltaV in register Y
						STX		$00,Y								;Stores the value in register X into the memory address pointed to by register Y (deltaV)

						RTS											;Now that all values are stored properly in the correct locations, the subroutine's work is finished and it can return


;************************************************************************************************************
;generateVelocityList subroutine
;
;Description:	This subroutine will use the previously stored values (constant velocity, total time, the two
;				acceleration intervals, and the change in velocity per step) to calculate the wheel velocity
;				during each individual step for each wheel.
;
;Written by:	Zachary Downum
;
;Date written:	1/26/17
;
;Modified date:	N/A
;
;Stack at the point of this call:
;Return address:			$00,SP
;Vconstant value:			$08,SP
;deltaV address:			$06,SP
;rightMotorVelocityList:	$04,SP
;leftMotorVelocityList:		$02,SP
;*************************************************************************************************************
generateVelocityList
while1
