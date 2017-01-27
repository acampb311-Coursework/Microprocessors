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
					ORG     $1900
PRINTF              EQU     $EE88
TitleString         FCB     'MOTOR CONTROL SOFTWARE',$0D,$0A,$00
SString     		FCB     'PLEASE CHOOSE A CONSTANT',$0D,$0A,$00
;******************************* End Symbols **********************************;

;********************************** Main **************************************;
MAIN                ORG     $2200   	    ;Starting Address
                    LDD     #TitleString
                    LDX     printf
                    JSR     0,X
END_MAIN            END
