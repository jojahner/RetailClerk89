	;---------------------------------------------------------------------------
	; entry 0 - transparency/background
	;---------------------------------------------------------------------------
	;		 0000BBBSGGGSRRRS
	dc.w	%0000000000000000
	;---------------------------------------------------------------------------
	; entry 1-4 - dialog & text
	;---------------------------------------------------------------------------
	;		 0000BBBSGGGSRRRS
	dc.w	%0000000000000000
	dc.w	%0000111000001110
	dc.w	%0000111011101110
	dc.w	%0000111000001110
	;---------------------------------------------------------------------------
	; entry 1-F - unused
	;---------------------------------------------------------------------------
	;		 0000BBBSGGGSRRRS
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
