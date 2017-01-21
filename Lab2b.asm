;******************************************************************************;
;Lab2b.asm
;
;Description: This is a program intended to be used as a subroutine for reading
; a set of IR sensor values to make appropriate robot navigational decisions.
; Please note that this file uses tabs, and those tabs are 4 spaces.
;
;Written By: Adam Campbell
;
;Date Written: 1/19/2017
;
;Date Modified: (1/21/17) - (Adam Campbell) - (Added Documentation)
;
;******************************************************************************;

;Symbols
Threshold   EQU $55 	       ;Wall Closeness
;End Symbols

;Program - Lab2b
            ORG     $3100   	    ;Starting Address
            LDAA    $3000   	    ;Load the sensor data into register A
            STAA    $1800   	    ;Store the sensor data into address $1800
            LDAA    $3001   	    ;Load the sensor data into register A
            STAA    $1801   	    ;Store the sensor data into address $1801
            LDAA    $3002   	    ;Load the sensor data into register A
            STAA    $1802   	    ;Store the sensor data into address $1802
	        LDAA 	$1800		    ;A = sensor data
            CMPA    #Threshold	    ;Compare sensor data to threshold value
IF1	        BLS		ELSE1		    ;If (A > Threshold)
            LDAA	#$00		    ;   A = 0
            LDAB    #$01            ;   B = 1
WHILE1      CMPA    #$0F            ;   While (A != 15)
            BEQ     END_WHILE1      ;
            ABA                     ;       A = B + A
            INCB                    ;       B++
            BRA     WHILE1          ;   PC = While1
END_WHILE1  STAA	$1800		    ;$1800 = A
ELSE1       LDAA	$1801		    ;A = sensor data
	        CMPA	#Threshold	    ;Compare sensor data to threshold value
IF2         BLS		ELSE2		    ;If (A > Threshold)
	        LDAA	#$00		    ;   A = 0
	        STAA	$1801		    ;   $1801 = A
ELSE2       LDAA	$1802		    ;A = sensor data
	        CMPA    #Threshold	    ;Compare sensor data to threshold value
IF3	        BLS		ELSE3		    ;If (A > Threshold)
	        LDAA	$1802		    ;   A = (Contents Of)$1802
	        LDAB	#$10		    ;   B = 10
	        SBA					    ;   A = A - B
	        STAA	$1802 		    ;$1802 = A
ELSE3	    SWI					    ;
            END					    ;
;End Program - Lab 2b
