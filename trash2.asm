QUOTIENT    EQU     $1000       ;Variable to hold our QUOTIENT
REMAINDER   EQU     $1002       ;Variable to hold our REMAINDER

			ORG     $2000
			LDY		#QUOTIENT
			LDAA    #$00
MAIN		CMPA    #$0A
			BEQ     END_MAIN
			LDAB	#$55
			STAB	2,Y+
			INCA
			BRA     WHILE1
END_MAIN    END


;
; BEQ     END_WHILE_1     ;{
; PSHY                    ;   Push Address
; LDY     6,SP            ;   Y = VDelta;
; PSHX                    ;   Push Index
; PULD                    ;   Pull Index: D = X(index)
; EMUL                    ;   Y,D = D * Y
; PULY                    ;   Y has the starting address needs offset
; PSHD                    ;   Push answer
; LDD     0,Y
; ADDD    0,X
;
;
; PARSE_INTERVAL      LDD     #$0000
;                     LDX     4,SP            ;Right Velocity first
; WHILE_1             CPD     #$000A
;                     BEQ     END_WHILE_1
;                     PSHD                    ;Get D on the stack so I can use the register
;                     PSHD
;                     PSHD
;                     LDD     6,SP            ;D = VDelta (6 = two indexes plus original 2. 4 + 2 = 6)
;                     PULY                    ;Y = index
;                     EMUL                    ;Y,D = D * Y. The result is 32 bits, but I will assume that I just want the lower 16 bits of the result
;                     PULY                    ;Y = index
;                     PSHD                    ;The answer is now on the top of the stack
;                     PSHY                    ;Stack += Index
;                     PULD                    ;D = Index, stack is pointing to answer of multplication
;                     ADDD    $0,X            ;D now holds the address in which to store the answer
;                     PSHD
;                     PULY                    ;Y now has the address
;                     PULD                    ;D now has the answer
;                     STD     0,Y             ;Store D in the offset address, Y
;                     PULD                    ;Pull the original index back into D
;                     ADDD    #$0001
; END_WHILE_1         INX
;
; PSHA                    ;Get A on the stack so I can split VDelta
; LDD     2,SP            ;Check to see where the high section is stored, gonna assume 45 would be A[00]B[45]
; PSHB                    ;Get the small chunk outta here adds 8 bits to the stack
; PULA                    ;should have 8 bit VDelta
; PULB                    ;Should have index A
; MUL                     ;D = A * VDelta
