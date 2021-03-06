SceneVB:

	;---------------------------------------------------------------------------
	; scene ID
	;---------------------------------------------------------------------------
	dc.w	SCENE_ID_VB

	;---------------------------------------------------------------------------
	; tiles
	;---------------------------------------------------------------------------
	dc.w	$0004	; tileset count - 1

	; tileset 0
	dc.l	TransparentTileStart
	dc.l	TransparentTileEnd

	; tileset 1
	dc.l	CarpetFloorTilesStart
	dc.l	CarpetFloorTilesEnd

	; tileset 2
	dc.l	StoreFrameTilesStart
	dc.l	StoreFrameTilesEnd

	; tileset 3
	dc.l	StoreFrontWindowTilesStart
	dc.l	StoreFrontWindowTilesEnd

	; tileset 4
	dc.l	StoreVBTilesStart	; start of scenery tiles
	dc.l	StoreVBTilesEnd	; end of scenery tiles

	;---------------------------------------------------------------------------
	; palettes
	;---------------------------------------------------------------------------
	dc.w	$0004	; four palettes
	dc.l	Store00Palettes	; start of first palette to load

	;---------------------------------------------------------------------------
	; scenery
	;---------------------------------------------------------------------------
	dc.w	$0013	; scenery count - 1

	; floor
	dc.l	PatternFloor	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0000000000000001	; base pattern
	dc.w	$001F	; repeat 32 times
	dc.l	VDP_VRAM_WRITE_B	; initial drawing location

	; top shelf
	dc.l	PatternShelvesH	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0000000000100010	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_B+$00800000	; initial drawing location

	; middle shelf
	dc.l	PatternShelvesM	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0010000000100010	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_B+$01000000	; initial drawing location

	; low shelf
	dc.l	PatternShelvesL	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0100000000100010	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_B+$01800000	; initial drawing location

	; frame top
	dc.l	PatternFrameTop	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1000000000000000	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A	; initial drawing location

	; frame side
	dc.l	PatternFrameSide	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1000000000000000	; base pattern
	dc.w	$0016	; repeat 23 times
	dc.l	VDP_VRAM_WRITE_A+$00800000	; initial drawing location

	; store front frame
	dc.l	PatternStoreFrontFrame	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1000000000000100	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$0C000000	; initial drawing location

	; store front
	dc.l	PatternStoreFrontVB	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1000000000000000	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$0C800000	; initial drawing location

	; counter - low front
	dc.l	PatternCounterLow	; location of first pattern to load
	dc.w	%0010000000100101	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$05800000+$001C0000	; initial drawing location

	; counter - low side
	dc.l	PatternCounterLowSide	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0010000000110101	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_B+$01800000+$00300000	; initial drawing location

	; counter - top
	dc.l	PatternCounterHigh	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1010000000110101	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$04000000+$001C0000	; initial drawing location

	; register
	dc.l	PatternRegister	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1110000000111111	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$03800000+$00300000	; initial drawing location

	; hardware rack - low
	dc.l	PatternHWRackLow	; location of first pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0000000001000101	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$05000000+$00020000	; initial drawing location

	; hardware rack - high
	dc.l	PatternHWRackHigh	; location of first pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1000000001000101	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$02800000+$00020000	; initial drawing location

	; pc software rack - low
	dc.l	PatternPCRackLow	; location of first pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0100000001110111	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$0A000000+$00020000	; initial drawing location

	; pc software - high
	dc.l	PatternPCRackHigh	; location of first pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1100000001110111	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$07800000+$00020000	; initial drawing location

	; 16-bit rack - low
	dc.l	Pattern16BitRackLow	; location of first pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0100000001010001	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$0A000000+$00400000	; initial drawing location

	; 16-bit rack - high
	dc.l	Pattern16BitRackHigh	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1100000001010001	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$07800000+$00400000	; initial drawing location

	; handheld rack - low
	dc.l	PatternHandheldRackLow	; location of first pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%0100000001101000	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$05000000+$00400000	; initial drawing location

	; handheld rack - high
	dc.l	PatternHandheldRackHigh	; location of pattern to load
	; 		%pccvhnnnnnnnnnnn
	dc.w	%1100000001101000	; base pattern
	dc.w	$0000	; no repeat
	dc.l	VDP_VRAM_WRITE_A+$02800000+$00400000	; initial drawing location

	;---------------------------------------------------------------------------
	; text
	;---------------------------------------------------------------------------
	dc.w	$FFFF	; text count

	;---------------------------------------------------------------------------
	; objects
	;---------------------------------------------------------------------------
	dc.w	OBJ_LIST_LENGTH-1	; object count

	;---------------------------------------------------------------------------
	; word0=Object ID (0-65535)
	; word1[0-8]=x0 (0-511)
	; word1[9-15]=width (0-127)
	; word2[0-8]=y0 (0-512)
	; word2[9-15]=height (0-127)
	;---------------------------------------------------------------------------
	dc.w	OBJ_SCENE_VB_8BIT
	; x0=136 width=106 = 1101010 010001000 = D488
	dc.w	$D488
	; height=16 [0010000] y0=136 [010001000] 
	dc.w	%0010000010001000

	dc.w	OBJ_SCENE_VB_8BIT
	; x0=242 width=79 = 1001111 011110010  = 9EF2
	dc.w	$9EF2
	; height=16 [0010000] y0=136 [010001000] 
	dc.w	%0010000010001000

	dc.w	OBJ_SCENE_VB_8BIT
	; x0=351 width=90 = 1011010 101011111 = B55F
	dc.w	$B55F
	; height=16 [0010000] y0=136 [010001000] 
	dc.w	%0010000010001000

	dc.w	OBJ_SCENE_VB_MAGS
	; x0=240 width=114 = 1110010 011110000 = E4F0
	dc.w	$E4F0
	; height=8 [0001000] y0=224 [011100000]
	dc.w	%0001000011100000

	dc.w	OBJ_SCENE_COUNTER
	; x0=240 width=80 = 1010000 011110000 = A0F0
	dc.w	$A0F0
	; y0=200 height=16 = 0010000 011001000  = 20C8
	dc.w	$20C8

	dc.w	OBJ_SCENE_REGISTER
	; x0=320 width=16 = 0010000 101000000 = 2140
	dc.w	$2140
	; y0=178 height=32 = 0100000 010110010 = 40A2
	dc.w	$40B2

	dc.w	OBJ_SCENE_VB_HARDWARE
	; width=40 [0101000] x0=136 [010001000]
	dc.w	%0101000010001000
	; height=32 [0100000] y0=192 [011000000]
	dc.w	%0100000011000000

	dc.w	OBJ_SCENE_VB_16BIT
	; width=40 [0101000] x0=390 [110000110]
	dc.w	%0101000110000110
	; height=32 [0100000] y0=272 [100010000]
	dc.w	%0100000100010000

	dc.w	OBJ_SCENE_VB_HANDHELD
	; width=40 [0101000] x0=390 [110000110]
	dc.w	%0101000110000110
	; height=32 [0100000] y0=192 [011000000]
	dc.w	%0100000011000000

	dc.w	OBJ_SCENE_VB_PC
	; width=40 [0101000] x0=136 [010001000]
	dc.w	%0101000010001000
	; height=32 [0100000] y0=272 [100010000]
	dc.w	%0100000100010000

	;---------------------------------------------------------------------------
	; collision data
	;---------------------------------------------------------------------------
	dc.w	DEFAULT_COLLISION_DATA_SIZE	; collision data size
	
	dc.l	MapStore00Collision	; location of collision data

	;---------------------------------------------------------------------------
	; exits
	;---------------------------------------------------------------------------
	dc.w	SCENE_ID_WWHALL	; south exit
	dc.w	$FFFF	; north exit
	dc.w	$FFFF	; west exit
	dc.w	$FFFF	; east exit

	;---------------------------------------------------------------------------
	; NPC locations
	;---------------------------------------------------------------------------
	dc.w	$0002	; three npc slots

	; npc0
	dc.w	$0130	; starting x location of npc0
	dc.w	$00B6	; starting y location of npc0
	dc.w	DIRECTION_DOWN	; starting direction of npc0
	dc.w	$FFFF	; movement frequency of npc0
	dc.l	NPCMovementDownStart	; location of movement pattern for npc0
	dc.w	(NPCMovementDownEnd-NPCMovementDownStart-1)	; pattern length

	; npc1
	dc.w	$0150	; starting x location of npc1
	dc.w	$00F0	; starting y location of npc1
	dc.w	DIRECTION_DOWN	; starting direction of npc1
	dc.w	$0049	; movement frequency of npc1
	dc.l	RandomNPCMovement0Start	; location of movement pattern for npc1
	dc.w	(RandomNPCMovement0End-RandomNPCMovement0Start-1)	; pattern length

	; npc2
	dc.w	$00B0	; starting x location of npc2
	dc.w	$0120	; starting y location of npc2
	dc.w	DIRECTION_DOWN	; starting direction of npc2
	dc.w	$002F	; movement frequency of npc2
	dc.l	RandomNPCMovement1Start	; location of movement pattern for npc2
	dc.w	(RandomNPCMovement1End-RandomNPCMovement1Start-1)	; pattern length

	;---------------------------------------------------------------------------
	; bgm
	;---------------------------------------------------------------------------
	dc.l	BGM_Store0	; location of background music

