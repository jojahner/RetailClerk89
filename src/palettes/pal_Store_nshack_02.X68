	;---------------------------------------------------------------------------
	; entry 0 - transparency
	;---------------------------------------------------------------------------
	;		 0000BBBSGGGSRRRS
	dc.w	%0000111000001110
	;---------------------------------------------------------------------------
	; entries 1-C - scenery
	;---------------------------------------------------------------------------
	;		 0000BBBSGGGSRRRS
	dc.w	%0000000000000000
	dc.w	%0000101010101010
	dc.w	%0000010001000100
	dc.w	%0000010010101100
	dc.w	%0000100010101100
	dc.w	%0000001010001010
	dc.w	%0000001001001000
	dc.w	%0000001001000100
	dc.w	%0000001010001010
	dc.w	%0000000000100100
	dc.w	%0000001001001000
	dc.w	%0000001000100010
	;---------------------------------------------------------------------------
	; entries D-F - unused
	;---------------------------------------------------------------------------
	;		 0000BBBSGGGSRRRS
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
