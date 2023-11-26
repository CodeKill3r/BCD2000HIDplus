;
;  8-bit by 8-bit signed multiply--byte signed multiply
;
;    This routine takes the signed byte in multiplicand and
;    multiplies it by the signed byte in multiplier and places
;    the signed 16-bit product in product_high and product_low.
;
;    This routine assumes 2s complement representation of signed
;    numbers.  The maximum numbers possible is then -128 and +127.
;    Multiplying the possible maximum numbers together easily fits
;    in a 16-bit product, so no overflow test is done on the answer.
;
;    Registers altered by routine: A, B, PSW.
;
;
;  Primary controls
$MOD51
$TITLE(BYTE SIGNED MULTIPLY)
$PAGEWIDTH(132)
$DEBUG
$OBJECT
$NOPAGING
;
;
;  Variable declarations
;
sign_flag	BIT	0F0H		;sign of product
multiplier	DATA	030H		;8-bit multiplier
multiplicand	DATA	031H		;8-bit multiplicand
product_high	DATA	032H		;high byte of 16-bit answer
product_low	DATA	033H		;low byte of answer
;
;
;
	ORG	100H			;arbitrary start
;
byte_signed_multiply:
		CLR	sign_flag	;reset sign
		MOV	A,multiplier	;put multiplier in accumulator
		JNB	ACC.7,positive	;test sign bit of multiplier
		CPL	A		;negative--complement and
		INC	A		;add 1 to convert to positive
		SETB	sign_flag	;and set sign flag
;
positive:	MOV	B,multiplicand	;put multiplicand in B register
		JNB	B.7,multiply	;test sign bit of multiplicand
		XRL	B,#0FFh		;negative--complement and
		INC	B		;add 1 to convert to positive
		CPL	sign_flag	;complement sign flag
;
multiply:	MUL	AB		;do unsigned multiplication
;
sign_test:	JNB	sign_flag,byte_signed_exit	;if positive,done
		XRL	B,#0FFh		;else have to complement both
		CPL	A		;bytes of the product and inc
		ADD	A,#1		;need add here because inc doesn't set
		JNC	byte_signed_exit	;the carry flag
		INC	B		;if add overflowed A, inc the high byte
;
byte_signed_exit:
		MOV	product_high,B	;save the answer
		MOV	product_low,A	
;
		RET			;and return
	END
