;*******************************************************************************
; cartridge info header
; see-https://en.wikibooks.org/wiki/Genesis_Programming#ROM_header
;*******************************************************************************
	dc.b	'SEGA GENESIS    '	; console name
	dc.b	'(C)HUJO '			; copyright
 	dc.b	'2019.AUG'			; date
	if	_EMULATOR_DIAGNOSTICS_
	dc.b	'Retail Clerk 89 - Emulator Diagnostics Build    ' ; cart name
	dc.b	'Retail Clerk 89 - Emulator Diagnostics Build    ' ; cart name (alt)
	else 
	if _DEBUG_
	dc.b	'Retail Clerk 89 - Debug Build                   ' ; cart name
	dc.b	'Retail Clerk 89 - Debug Build                   ' ; cart name (alt)
	else
	dc.b	'Retail Clerk 89 - Release Build 20190818-00     ' ; cart name
	dc.b	'Retail Clerk 89 - Release Build 20190818-00     ' ; cart name (alt)
	endif
	endif
	dc.b	'GM 20190818-00'	; program type / serial number / version
	dc.w	$0000				; ROM checksum
	dc.b	'J               '	; I/O device support (unused)
	dc.l	$00000000			; address of ROM start
	dc.l	RomEnd				; address of ROM end
	dc.l	$FFFF0000,$FFFFFFFF	; RAM start/end
;	dc.b	'            '		; backup RAM info
	dc.b	'RA',$F8,$20	; SRAM type
	dc.l	SRAM_START	; SRAM start address
	dc.l	SRAM_END	; SRAM end address
	dc.b	'            '		; modem info
	dc.b	'http://huguesjohnson.com/               ' ; comment
	dc.b	'JUE             '	; regions allowed

