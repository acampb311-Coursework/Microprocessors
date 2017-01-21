;******************************************************************************;
;Lab2b.asm
;
;Description: This is a program intended to be used as a subroutine for reading
; a set of IR sensor values to make appropriate robot navigational decisions.
;
;Written By: Adam Campbell
;
;Date Written: 1/19/2017
;
;******************************************************************************;

;Symbols
Threshold   EQU $55 	       ;Wall Closeness
;End Symbols

;Program - Lab2b
            ORG     $3100   	    ;Starting Address
            LDAA    $3000   	    ;Load the contents of $3000 into register A
            STAA    $1800   	    ;Store the contents of register A into address $1800
            LDAA    $3001   	    ;Load the contents of $3001 into register A
            STAA    $1801   	    ;Store the contents of register A into address $1801
            LDAA    $3002   	    ;Load the contents of $3002 into register A
            STAA    $1802   	    ;Store the contents of register A into address $1802
	        LDAA 	$1800		    ;Loading sensor data
            CMPA    #Threshold	    ;Comparing sensor data to the threshold value
IF1	        BLS		ELSE1		    ;Utilizing fall through logic evaluate if sensor data is higher than the threshold
            LDAA	#$00		    ;
            LDAB    #$01            ;
WHILE1      CMPA    #$0F            ;
            BEQ     END_WHILE1      ;
            ABA
            INCB
            BRA     WHILE1
            STAA    $1800
END_WHILE1  STAA	$1800		    ;Saving the equivalant of the summation of 1 through 5
ELSE1       LDAA	$1801		    ;
	        CMPA	#Threshold	    ;
IF2         BLS		ELSE2		    ;Utilizing fall through logic evaluate if sensor data is higher than the threshold
	        LDAA	#$00		    ;
	        STAA	$1801		    ;Storing $00 to the sensor location
ELSE2       LDAA	$1802		    ;
	        CMPA    #Threshold	    ;
IF3	        BLS		ELSE3		    ;Utilizing fall through logic evaluate if sensor data is higher than the threshold
	        LDAA	$1802		    ;
	        LDAB	#$10		    ;
	        SBA					    ;Subtracting the contents of register B from register A and storing back in A
	        STAA	$1802 		    ;Storing 10 less than the original signal to the sensor location
ELSE3	    SWI					    ;
            END					    ;
;End Program - Lab 2b
