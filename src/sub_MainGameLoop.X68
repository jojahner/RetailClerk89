;*******************************************************************************
; main game loop
;*******************************************************************************
MainGameLoop:
	bsr.w	WaitVBlank ; wait for vblank to complete
	addq	#$1,(MEM_MAINLOOP_COUNTER) ; increment counter
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	btst.l	#STATE_FLAG_EXPLORING,d7 ; test game state
	beq.w	TestTitleScreen	; not exploring, branch
;-------------------------------------------------------------------------------
; pause/unpause
;-------------------------------------------------------------------------------
TestPauseToggle:
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	move.b	(MEM_CONTROL_PRESSED),d6	; copy pressed buttons to d6
	andi.b	#BUTTON_START_PRESSED,d6	; test if the start button was pressed
	beq.s	TestPause	; start button is not pressed test if still paused
	; clear MEM_CONTROL_PRESSED to prevent pause state from flipping in loop
	move.w	#$0000,(MEM_CONTROL_PRESSED)
	btst.l	#STATE_FLAG_PAUSED,d7	; is the paused bit set?
	bne.s	Unpause	; if so branch to unpause 
Pause:
	bset.l	#STATE_FLAG_PAUSED,d7	; set the paused bit
	; flip to paused palette
	bsr	Echo_StopBGM	; pause the background music
SetPausedPalette:
	bsr.w	WaitVBlank	; wait to load palettes until VBlank
	lea	(MEM_SCENE_PALETTE),a0	; point a0 to the scene palette
	move.l	#VDP_CRAM_WRITE,(VDP_CONTROL) ; set up VDP write to CRAM
	moveq	#$003F,d0	; 64 words of palette data
SetPausedPaletteLoop:
	move.w	(a0)+,d1	; get the next palette entry
	lsr	#1,d1	; shift color intensity
	;	      0000BBBSGGGSRRRS
	and.w	#%0000011001100110,d1	; prevent color overflow
	move.w	d1,(VDP_DATA)	; write the palette entry
	dbf	d0,SetPausedPaletteLoop	; decrement d0 and loop
	bra.s	UpdatePause	; save the paused state
Unpause:
	bclr.l	#STATE_FLAG_PAUSED,d7	; clear the paused bit
	bsr	Echo_ResumeBGM	; unpause the background music
	bsr.w	WaitVBlank	; wait to load palettes until VBlank
	lea	(MEM_SCENE_PALETTE),a0	; point to scene palette
	moveq	#$0004,d0	; number of palettes to load
	move.l	#VDP_CRAM_WRITE,d1	; initial write address
	bsr.w	LoadPalettes	; branch to LoadPalettes subroutine
UpdatePause:
	move.l	d7,(MEM_GAME_STATE)	; save the new paused state
TestPause:
	btst.l	#STATE_FLAG_PAUSED,d7	; test if paused
	beq.s	TestAction	; not paused, move to next test
	bra.w	MainGameLoop	; paused, return to start of game loop
;-------------------------------------------------------------------------------
; determine if there is an action queued
;-------------------------------------------------------------------------------
TestAction:
	btst.l	#STATE_FLAG_ACTION,d7 ; test game state
	beq.w	TestScriptedEvent	; no action queued, move to next test
	bsr.w	ProcessAction	; process the pending action
	bra.w	MainGameLoop	; paused, return to start of game loop
;-------------------------------------------------------------------------------
; determine if there is a scripted event to process
;-------------------------------------------------------------------------------
TestScriptedEvent:
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	btst.l	#STATE_FLAG_SCRIPTED_EVENT,d7 ; test game state
	beq.w	TestDialog	; not in a scripted event, move to next test
	btst.l	#STATE_FLAG_DIALOG,d7 ; test if we need to wait for a dialog
	bne.w	TestDialogUpdateFrequency	; wait for dialog interaction to finish
	;---------------------------------------------------------------------------
	; dialog is not displaying, test if it is time to start a new action
	;---------------------------------------------------------------------------
	cmpi.w	#$0000,(MEM_SCRIPTED_EVENT_STEPS)	; test if 0
	beq.s	NextScriptedEventAction	; if 0 then start next action
	;---------------------------------------------------------------------------
	; continue moving the sprite
	;---------------------------------------------------------------------------
	cmpi.w	#SPRITE_MOVE_FREQUENCY,(MEM_FRAME_COUNTER); is it time to move?
	blt.w	MainGameLoopEnd	; exit if it's not time to move
	move.w	#$0000,(MEM_FRAME_COUNTER)	; reset counter to 0
ScriptedEventMoveSprite:
	subq	#$1,(MEM_SCRIPTED_EVENT_STEPS)	; decrement step counter
	move.l	(MEM_SCRIPTED_SPRITE_ADDR),a6	; point a6 to sprite to move
	bsr.w	MoveSprite	; branch to MoveSprite
	bra.w	MainGameLoop	; return to start of game loop
NextScriptedEventAction:
	move.l	(MEM_SCRIPTED_SPRITE_ADDR),a6	; point a6 to sprite
	bsr.w	StopSprite	; stop moving the sprite
	move.l	(MEM_SCRIPTED_EVENT_ADDR),a6	; point a6 to next step
	move.w	(MEM_SCRIPTED_EVENT_ACTION),d7	; copy action to d7
	cmpi.w	#SCRIPTED_EVENT_END,d7	; are we at the end?
	beq.s	ScriptedEventEnd	; if so branch
	cmpi.w	#SCRIPTED_EVENT_DIALOG,d7	; display a dialog?
	beq.s	ScriptedEventDialog	; if so branch
	cmpi.w	#SCRIPTED_EVENT_CHANGE_SPRITE,d7	; changing the sprite?
	beq.s	ScriptedEventChangeSprite	; if so branch
	;---------------------------------------------------------------------------
	; start moving the sprite
	;---------------------------------------------------------------------------
	move.l	(MEM_SCRIPTED_SPRITE_ADDR),a5	; point a5 to sprite to update
	; copy direction to sprite direction 
	adda.w	#STRUCT_SPRITE_DIRECTION,a5	; move to direction
	move.w	(MEM_SCRIPTED_EVENT_ACTION),(a5)	; copy action to direction
	move.w	(a6)+,(MEM_SCRIPTED_EVENT_STEPS)	; copy steps in action
	; save state of scripted event and loop back to main
	move.w	(a6)+,(MEM_SCRIPTED_EVENT_ACTION)	; save next action
	move.l	a6,(MEM_SCRIPTED_EVENT_ADDR)	; save address of next step
	bra.w	MainGameLoop	; return to start of game loop
ScriptedEventEnd:
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	bclr.l	#STATE_FLAG_SCRIPTED_EVENT,d7	; clear the scripted event flag
	move.l	d7,(MEM_GAME_STATE)	; save it back
	bra.w	MainGameLoop	; return to start of game loop
ScriptedEventDialog:
	move.l	(a6)+,(MEM_DIALOG_TEXT)	; copy value at a6 to MEM_DIALOG_TEXT
	move.w	(a6)+,(MEM_SCRIPTED_EVENT_ACTION)	; save next action
	move.l	a6,(MEM_SCRIPTED_EVENT_ADDR)	; save address of next step
	move.w	#$0000,(MEM_SCRIPTED_EVENT_STEPS)	; reset step counter
	; set dialog flags to display the dialog
	move.l	(MEM_DIALOG_FLAGS),d7	; copy current dialog state to d7
	bset.l	#DIALOG_FLAG_TEXT_OPENING,d7	; change state to opening
	bset.l	#DIALOG_FLAG_STYLE_SIMPLE_TEXT,d7	; set style to overworld menu
	move.l	d7,(MEM_DIALOG_FLAGS)	; save changes made to the game state
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	bset.l	#STATE_FLAG_DIALOG,d7	; set the dialog bit
	move.l	d7,(MEM_GAME_STATE) ; copy game state back to d7
	bra.w	MainGameLoop	; return to start of game loop
ScriptedEventChangeSprite:
	move.l	(MEM_SCRIPTED_EVENT_ADDR),a6	; point a6 to next step
	bsr.w	QueueScriptedEvent	; this will reset all variables
	bra.w	MainGameLoop	; return to start of game loop
;-------------------------------------------------------------------------------
; determine if the player is opening or interacting with a dialog
;-------------------------------------------------------------------------------
TestDialog:
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	btst.l	#STATE_FLAG_DIALOG,d7 ; test game state
	beq.w	TestStatusScreen	; dialog not displaying, move to next test
TestDialogUpdateFrequency:
	cmpi.w	#DIALOG_UPDATE_FREQUENCY,(MEM_FRAME_COUNTER); is it time to update?
	blt.s	TestDialogOpen	; branch if it's not time to move
	blt.w	MainGameLoop	; branch i6f it's not time to move
	move.w	#$0000,(MEM_FRAME_COUNTER)	; reset counter to 0	
	bsr.w	ProcessDialog	; dialog is set, jump to process dialog sub-routine
	bra.w	MainGameLoop	; return to start of game loop
TestDialogOpen:
	; if the dialog is open then update frequency is ignored
	move.l	(MEM_DIALOG_FLAGS),d7	; copy current game state to d7
	btst.l	#DIALOG_FLAG_TEXT_OPEN,d7 ; test if the dialog is open
	beq.w	MainGameLoop	; dialog is not open, move to next test
	; else branch to process dialog
	bsr.w	ProcessDialog	; dialog is set, jump to process dialog sub-routine
	bra.w	MainGameLoop	; return to start of game loop
;-------------------------------------------------------------------------------
; determine if the player is on the status screen
;-------------------------------------------------------------------------------
TestStatusScreen:
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	btst.l	#STATE_FLAG_STATUS_SCREEN,d7 ; test game state
	beq.w	TestExploring	; not in status screen, move to next test
	;---------------------------------------------------------------------------
	; player is on the status screen
	;---------------------------------------------------------------------------
	bsr.w	ProcessStatusScreen	; branch to process the status screen
	bra.w	MainGameLoop	; return to start of game loop
;-------------------------------------------------------------------------------
; determine if the player is in free exploration mode
;-------------------------------------------------------------------------------
TestExploring:
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	btst.l	#STATE_FLAG_EXPLORING,d7	; test game state
	beq.w	TestTitleScreen	; not exploring, branch to next test
TestCButtonPressed:	; test if the player pressed the C button
	move.b	(MEM_CONTROL_PRESSED),d6	; copy pressed buttons to d6
	andi.b	#BUTTON_C_PRESSED,d6	; test if the C button was pressed
	beq.w	TestAButtonPressed	; C button is not pressed
	lea	SceneStatus,a6	; address of the scene for the title screen
	bsr.w	DrawScene	; branch to subroutine to draw the scene
	bsr.w	BuildStatusScreen	; build the status screen
	bsr.w	FadeIn	; fade in the status screen
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	bset.l	#STATE_FLAG_STATUS_SCREEN,d7	; update game state
	move.l	d7,(MEM_GAME_STATE)	; save updated game state
	bra.w	MainGameLoop	; go back the start of the game loop
TestAButtonPressed: ; test if the player pressed the A button
	move.b	(MEM_CONTROL_PRESSED),d6	; copy pressed buttons to d6
	andi.b	#BUTTON_A_PRESSED,d6	; test if the A button was pressed
	beq.w	MainGameLoopUpdateSprites	; A button is not pressed
	;---------------------------------------------------------------------------
	; build event table address and branch to code
	;---------------------------------------------------------------------------
	; clear MEM_CONTROL_PRESSED to prevent state from flipping in loop
	move.w	#$0000,(MEM_CONTROL_PRESSED)
	lea	MEM_PLAYER_SPRITE_ID,a6	; point a6 to player sprite
	bsr.w	StopSprite ; stop the player sprite
	bsr.w	BuildNPCObjectList	; update the location of NPCs
	bsr.w	FindActionTarget	; find the target of the player's action
	cmpi.w	#OBJ_NOTHING,(MEM_ACTION_TARGET_OBJID)	; is the target nothing?
	beq.s	NoActionTarget	; branch if no target
	bsr.w	ShowSelectionDialog	; otherwise show a selection dialog
	bra.w	MainGameLoop	; return to start of game loop
NoActionTarget: 	; if target is 0 then display the default message
	bsr.w	ShowDefaultText	; show the default text
	bsr.w	SetDialogOpening	; set dialog state to opening
	bra.w	MainGameLoop	; return to start of game loop
;-------------------------------------------------------------------------------
; determine if sprites need to be moved and move them
;-------------------------------------------------------------------------------
MainGameLoopUpdateSprites:
	; test if it's time to move sprites
	cmpi.w	#SPRITE_MOVE_FREQUENCY,(MEM_FRAME_COUNTER); is it time to move?
	blt.w	MainGameLoopEnd	; exit if it's not time to move
	; move the player sprite
	move.w	#$0000,(MEM_FRAME_COUNTER)	; reset counter to 0
	bsr.w	MovePlayer	; move the player sprite
	; move NPCs
	tst.w	(MEM_ACTIVE_NPC_COUNT)	; are there any NPCs to move?
	beq.w	MainGameLoop	; return to start of game loop if no NPCs
	move.w	(MEM_ACTIVE_NPC_COUNT),(MEM_NPC_LOOP_COUNTER)	; setup loop control
	lea	MEM_NPC0_SPRITE_ID,a5	; point to first NPC
MainGameLoopUpdateNPCSpritesLoop:
	; if STRUCT_SPRITE_MOVE_FREQUENCY = $FFFF then don't move the sprite
	cmpi.w	#$FFFF,(STRUCT_SPRITE_MOVE_FREQUENCY,a5)	; test
	beq.s	MainGameLoopUpdateNPCSpritesLoopEnd	; branch if equal
	cmpi.w	#$0000,(STRUCT_SPRITE_MOVEMENT_COUNTER,a5)	; is the NPC moving?
	bne	.2	; if MOVEMENT_COUNTER > 0 then the sprite is moving
	; test if it's time for them to move again
	move.w	(MEM_VBLANK_COUNTER),d6	; copy vblank counter
	and.w	(STRUCT_SPRITE_MOVE_FREQUENCY,a5),d6	; and against it
	cmp.w	(STRUCT_SPRITE_MOVE_FREQUENCY,a5),d6	; test 
	bne.s	MainGameLoopUpdateNPCSpritesLoopEnd ; not time to move
	move.w	#NPC_SPRITE_MOVE_STEPS,(STRUCT_SPRITE_MOVEMENT_COUNTER,a5)	; reset
	; set the direction
	addq	#$2,(STRUCT_SPRITE_MOVE_INDEX,a5)	; increment index of movement
	move.w	(STRUCT_SPRITE_MOVE_PATTERN_LENGTH,a5),d6
	cmp.w	(STRUCT_SPRITE_MOVE_INDEX,a5),d6	; end of the array?
	bge.s	.1	; not at the end of the array
	move.w	#$0000,(STRUCT_SPRITE_MOVE_INDEX,a5)	; reset to zero
.1
	move.l	(STRUCT_SPRITE_MOVE_PATTERN,a5),a6
	adda	(STRUCT_SPRITE_MOVE_INDEX,a5),a6
	move.w	(a6),(STRUCT_SPRITE_DIRECTION,a5)
.2	; decrement NPC movement counter and test if they should stop moving
	subq	#$0001,(STRUCT_SPRITE_MOVEMENT_COUNTER,a5)	; decrement counter
	bne	.3	; if MOVEMENT_COUNTER=0 now then we need to stop the sprite
	move.l a5,a6	; setup call to StopSprite
	bsr.w	StopSprite ; stop the sprite
	bra.s	MainGameLoopUpdateNPCSpritesLoopEnd ; done updating this sprite
.3	; move the NPC sprite
	move.l a5,a6	; setup call to MoveSprite
	bsr.w	MoveSprite	; branch to move MoveSprite
	; did the sprite move successfully?
	tst.w	(MEM_COLLISION_RESULT)	; test result of last collision
	beq.s	MainGameLoopUpdateNPCSpritesLoopEnd ; done updating this sprite	
	addq	#$0001,(STRUCT_SPRITE_MOVEMENT_COUNTER,a5)	; rollback counter
MainGameLoopUpdateNPCSpritesLoopEnd:
	; move to next NPC sprite
	adda.l	#NPC_RECORD_SIZE,a5	; increment a5	
	; apparently dbra doesn't work against a memory address
	subq	#$1,(MEM_NPC_LOOP_COUNTER)	; decrement loop counter
	bgt.w	MainGameLoopUpdateNPCSpritesLoop	; branch
	; done looping through NPC sprites
	bra.w	MainGameLoop	; return to start of game loop
;-------------------------------------------------------------------------------
; title screen
;-------------------------------------------------------------------------------
TestTitleScreen:
	move.l	(MEM_GAME_STATE),d7	; copy current game state to d7
	btst.l	#STATE_FLAG_TITLE_SCREEN,d7 ; test game state
	beq.w	TestEndScreen	; not on the title screen, move to next test
TestTitleScreenTestStartPressed:
	move.b	(MEM_CONTROL_PRESSED),d6	; copy pressed buttons to d6
	andi.b	#BUTTON_START_PRESSED,d6	; test if the start button was pressed
	bne.s	TestTitleLoadIntroScreen	; start button pressed, load intro
	subq	#$1,(MEM_INTRO_SCENE_COUNTER)	; decrement counter
	bne.w	MainGameLoop	; loop until the counter is zero
	bra.w	NewGame	; counter is zero, restart
TestTitleLoadIntroScreen:
	; clear MEM_CONTROL_PRESSED to prevent entering pause state immediately
	move.w	#$0000,(MEM_CONTROL_PRESSED)
	; --------------------------------------------------------------------------
	; start button was pressed on the title screen
	; in this iteration there is only one menu option
	; future versions will need to determine which action was selected
	; --------------------------------------------------------------------------
	bclr.l	#STATE_FLAG_TITLE_SCREEN,d7 ; clear game state flag
	bset.l	#STATE_FLAG_INTRO_SCREEN,d7 ; set intro screen flag
	ifeq	_DEBUG_
	bset.l	#STATE_FLAG_EXITS_BLOCKED,d7	; set flag blocking the exits
	endif
	move.l	d7,(MEM_GAME_STATE)	; save updated game state
	; set the intro screen counter
	move.w	#INTRO_SCREEN_COUNTER_START,(MEM_INTRO_SCENE_COUNTER)
	lea	SceneIntroDay00,a6	; address of the scene for the title screen
	bsr.w	LoadScene	; branch to LoadScene subroutine
	bsr.w	FadeIn	; fade in to the new scene
	bra.w	MainGameLoop	;	return to start of game loop
;-------------------------------------------------------------------------------
; end screen
;-------------------------------------------------------------------------------
TestEndScreen:
	btst.l	#STATE_FLAG_END_SCREEN,d7 ; test game state
	beq.w	TestIntroScreen	; not on the end screen, move to next test
TestEndScreenTestStartPressed:
	move.b	(MEM_CONTROL_PRESSED),d6	; copy pressed buttons to d6
	andi.b	#BUTTON_START_PRESSED,d6	; test if the start button was pressed
	beq.w	MainGameLoop	; start button not pressed, loop
	; --------------------------------------------------------------------------
	; start button was pressed on the end screen - loop back to the beginning
	; --------------------------------------------------------------------------
	; clear MEM_CONTROL_PRESSED to prevent entering pause state immediately
	move.w	#$0000,(MEM_CONTROL_PRESSED)
EndScreenRestart:
	bra.w	NewGame	; restart
;-------------------------------------------------------------------------------
; day intro screen
;-------------------------------------------------------------------------------
TestIntroScreen:
	btst.l	#STATE_FLAG_INTRO_SCREEN,d7 ; test game state
	beq.w	MainGameLoopEnd	; not on the intro screen, move to next test
	tst.w	(MEM_INTRO_SCENE_COUNTER)	; is the counter already zero
	beq.s	TestIntroScreenWaitButtonPress	; wait for button press
	subq	#$1,(MEM_INTRO_SCENE_COUNTER)	; decrement counter
	bne.w	MainGameLoop	; loop until the counter is zero
TestIntroScreenWaitButtonPress:
	; counter is zero, test if button was pressed
	move.b	(MEM_CONTROL_PRESSED),d6	; copy pressed buttons to d6
	andi.b	#BUTTON_START_PRESSED,d6	; test if the start button was pressed
	beq.w	MainGameLoop	; loop until start is pressed
TestIntroScreenLoadScene:
	; load the next scene
	bclr.l	#STATE_FLAG_INTRO_SCREEN,d7 ; clear game state flag
	bset.l	#STATE_FLAG_EXPLORING,d7	; initial mode is exploring
	move.l	d7,(MEM_GAME_STATE)	; save updated game state
	; determine which scene to load
	move.w	(MEM_ACTIVE_SCENE_EXIT_N),d6	; copy any exit to d6
	mulu.w	#LWORD_SIZE,d6	; SceneDefinitionTable entries are long values
	lea	SceneDefinitionTable,a5	; point to action table
	adda.w	d6,a5	; move to offset location
	move.l	(a5),a6	; a5 has the address of the scene to load
	bsr.w	LoadScene	; branch to LoadScene subroutine
	bsr.w	LoadPlayerSprite	; load the player sprite
	bsr.w	HideSelectorSprite	; hide the menu selector sprite
	cmpi.w	#$0001,(MEM_DAY)	; is this day 01?
	beq.s	TestIntroScreenDay01Setup	; if day 01, go to day 01 setup
	cmpi.w	#$0000,(MEM_DAY)	; is this day 00?
	bne.s	TestIntroScreenEnd	; if not, skip day 00 setup
TestIntroScreenEndDay00Setup:
	; move NPC0 out of frame here
	move.w	#$017F,(MEM_NPC0_SPRITE_X)	; copy x-coordinate
	move.w	#$01AF,(MEM_NPC0_SPRITE_Y)	; copy y-coordinate
	move.w	#$FFFF,(MEM_NPC0_MOVE_FREQUENCY)	; set move frequency to never
	; fix order in sprite sort table
	move.w	#$0002,d2	; NPC0 is the sprite to update
	move.w	(MEM_NPC0_SPRITE_Y),d3	; new y-value	
	bsr.w	UpdateSpriteSortTable	; update the table
	bsr.w	OrderSprites	; force re-sort
	; update NPC0 in the sprite table
	;lea	PLAYER_SPRITE_VDP,a6
	move.l	#NPC0_SPRITE_VDP_Y,(VDP_CONTROL)	; set write location in VDP
	move.w	(MEM_NPC0_SPRITE_Y),(VDP_DATA)	; copy the new y-coordinate
	move.l	#NPC0_SPRITE_VDP_X,(VDP_CONTROL)	; set write location in VDP
	move.w	(MEM_NPC0_SPRITE_X),(VDP_DATA)	; copy the new x-coordinate
	bra.s	TestIntroScreenEnd	; finish intro screen seup
TestIntroScreenDay01Setup:
	; move player sprite into starting position
	move.w	#SPRITE_PLAYER_INIT_X,(MEM_PLAYER_SPRITE_X)	; starting x location
	move.w	#SPRITE_PLAYER_INIT_Y,(MEM_PLAYER_SPRITE_Y)	; starting y location
	move.w	#SPRITE_PLAYER_PATTERN,(MEM_PLAYER_SPRITE_PATTERN_INDEX) ; pattern
	move.w	#DIRECTION_DOWN,(MEM_PLAYER_SPRITE_DIRECTION)	; direction
	move.w	#$0000,(MEM_PLAYER_SPRITE_FRAME)	; frame
TestIntroScreenEnd:
	; reorder all the sprites
	bsr.w	OrderSprites	; order sprites
	; workaround to issue where links aren't set if the table is already sorted
	bsr.w	SetSpriteLinks
	move.w	#$0000,(MEM_FRAME_COUNTER)	; reset frame counter
	bsr.w	FadeIn	; fade in now that everything is setup
MainGameLoopEnd:
	bra.w	MainGameLoop	; return to start of game loop
