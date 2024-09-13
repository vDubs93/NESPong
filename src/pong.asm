.include "header.inc"
.include "constants.inc"


.segment "ZEROPAGE"
gamestate: 	.res 1
buttons1: 	.res 1
prev_b1:	.res 1
buttons2:	.res 1
prev_b2:	.res 1
score1:		.res 2
score2:		.res 2
p1_counter:	.res 1
p2_counter: .res 1
player1_y:	.res 1
player2_y:	.res 1
ball_x:		.res 1
ball_y:		.res 1
ball_dir_x:	.res 1
ball_dir_y:	.res 1
ball_spd_x:	.res 1
ball_spd_y:	.res 1
bgpointlo:	.res 1
bgpointhi:	.res 1
counterlo:	.res 1
counterhi:	.res 1
nmi_wait:	.res 1
cursor_y:	.res 1
.exportzp ball_x, ball_dir_x, ball_spd_x
.exportzp ball_y, ball_dir_y, ball_spd_y
.exportzp player1_y
.exportzp player2_y
.exportzp buttons1, buttons2, prev_b1, prev_b2, cursor_y
.exportzp score1, score2, p1_counter, p2_counter
.importzp difficulty, seed, movetimer
.segment "BSS"
title_up:	.res 1
paused:		.res 1
clr_nm_tbl:	.res 1

.segment "CODE"

.proc irq
	rti
.endproc
.import play_tone
.proc nmi
sprite_dma:
	lda 	#$00
	sta		nmi_wait
	sta 	OAMADDR
	lda 	#$02
	sta 	OAMDMA
	lda 	#$00
	sta 	PPUSCROLL
	sta 	PPUSCROLL
nmi_done:
	rti
.endproc

.import reset
.import read_controller

.export main

.proc main
	lda		#00
	sta		movetimer
	lda 	#00
	sta		difficulty
	lda		#80
	sta		seed+1
	lda		#$00
	sta		clr_nm_tbl
	lda 	#$80
	sta 	ball_x
	sta 	ball_y
	sec
	sbc		#$08
	sta 	player1_y
	sta 	player2_y
	lda		#$67
	sta		cursor_y
	lda 	#$00
	sta		p1_counter
	sta		p2_counter
	sta		score1
	sta		score1+1
	sta		score2
	sta		score2+1
	sta		paused
	sta		gamestate
	sta		title_up
	sta 	ball_dir_x
	sta 	ball_dir_y
	sta 	buttons1
	lda 	#$02
	sta 	ball_spd_x
	sta 	ball_spd_y
	ldx 	PPUSTATUS
	ldx 	#$3f
	stx 	PPUADDR
	ldx 	#$00
	stx 	PPUADDR
	ldx 	#$00
load_palettes:
	lda 	palette,x
	sta 	PPUDATA
	inx
	cpx 	#$20
	bne 	load_palettes
load_background:
	lda 	PPUSTATUS
	lda 	#$20
	sta 	PPUADDR
	lda 	#$00
	sta 	PPUADDR

	ldx 	#$00
load_attribute:
	lda 	PPUSTATUS
	lda 	#$23
	sta 	PPUADDR
	lda 	#$c0
	sta 	PPUADDR

	ldx 	#$00
attribute_loop:
	lda 	attribute,x
	sta 	PPUDATA
	inx
	cpx 	#$08
	bne 	attribute_loop

	lda 	#%10010000
	sta 	PPUCTRL

	lda 	#%00011110
	sta 	PPUMASK
do_frame:
    inc 	nmi_wait
	lda		gamestate
	cmp		#AT_GAME
	beq		run_game
	bcc		run_title
	bcs		run_lose
run_game:
	jsr		state_game
	jmp 	wait_for_nmi
run_title:
	jsr		state_title
	inc		seed
	jmp		wait_for_nmi
run_lose:	
	jsr		state_game_over
	inc 	seed
wait_for_nmi:
	lda 	nmi_wait
	beq 	do_frame
	jmp 	wait_for_nmi
.endproc



.proc state_game
	jsr 	read_controller
	jsr		show_score
	lda 	buttons1
	cmp		prev_b1
	beq		start_not_pressed
	lda		buttons1
	and		#BUTTON_START
	beq		start_not_pressed
	lda		paused
	eor		#$FF
	sta		paused
start_not_pressed:	
	lda		paused
	cmp		#%00000000
	beq		no_pause
	bne		game_paused
no_pause:
	jsr 	checkbuttons
	jsr		moveball
game_paused:
	rts
.endproc

.proc show_score
	php
	pha
	txa
	pha
	tya
	pha
;show player 1 score
	ldx		#$00
	lda		#$0F
	sta		$021c
	sta		$0220
	sta		$0224
	sta		$0228
	lda		score1,x	;10s place of p1 score
	adc		#$03
	sta		$021D
	lda		score2,x	;10s place of p2 score
	adc		#$04
	sta		$0225
	inx
	lda		score1,x	;1s place of p1 score
	adc		#$04
	sta		$0221
	lda		score2,x	;1s place of p2 score
	adc		#$04
	sta		$0229
;check score 1s place digit
	ldx 	#$01
	lda		score1,x
	beq 	check_p2
	cmp		score1
	beq		end_game
check_p2:
	ldx		#$01
	lda		score2,x
	beq		return
	cmp		score2
	beq		end_game
	jmp		return
end_game:
	lda		#$02
	sta		gamestate

return:
	pla
	tay
	pla
	tax
	pla
	plp
	rts
.endproc

.import moveball

.import checkbuttons

.proc state_title
	php
	pha
	txa
	pha
	tya
	pha
	lda		title_up
	bne 	skip_display
	jsr		display_title
	lda 	#0
	sta		difficulty
	lda		#$0E
	sta		$0201
	lda		#$00
	sta		$0202
	lda		#$50
	sta 	$0203
	ldx		#$30
	lda		sprites,x
	sta		$0204
	inx
	lda		sprites,X
	sta		$0205
	inx
	lda		sprites,x
	sta		$0206
	inx
	lda		sprites,x
	sta		$0207
	inx
	
skip_display:
	lda 	cursor_y
	sta		$0200
	lda		#$04
	adc		difficulty
	sta		$0205
	jsr		read_controller
	lda		buttons1
	cmp		prev_b1
	beq		check_start
check_right:
	lda 	buttons1
	and		#BUTTON_RIGHT
	beq		check_left
	lda		difficulty
	cmp		#$02
	beq		check_left
	inc		difficulty
check_left:
	lda		buttons1
	and		#BUTTON_LEFT
	beq		check_select
	lda		difficulty
	beq 	check_select
	dec 	difficulty
check_select:
	lda 	buttons1
	and		#BUTTON_SELECT
	beq		check_start
	lda		cursor_y
	cmp		#$80
	bne		move_cursor_down
	lda		#$67
	jmp		store_cursor
move_cursor_down:
	lda		#$80
store_cursor:
	sta		cursor_y
check_start:
	
	lda 	buttons1
	and		#BUTTON_START
	beq		check_point
	jsr		clear_nametable
	jsr		play_field
	lda		#$00
	sta		title_up
	lda		#$01
	sta		gamestate
	lda		#$80
	sta		ball_x
	sta		ball_y
	lda		#$78
	sta		player1_y
	sta		player2_y
	lda		difficulty
	cmp		#0
	beq		set_difficulty_0
	lda		difficulty
	cmp		#1
	beq		set_difficulty_1
	lda		difficulty
	cmp		#2
	beq		set_difficulty_2

set_difficulty_0:
	lda		#30
	jmp		set_difficulty
set_difficulty_1:
	lda		#40
	jmp		set_difficulty
check_point:
	jmp keep_title
set_difficulty_2:
	lda		#90
set_difficulty:
	sta		difficulty
	lda 	#$00
	sta		p1_counter
	sta		p2_counter
	sta		score1
	sta		score1+1
	sta		score2
	sta		score2+1
	sta		paused
	ldx 	#$2c
load_sprites:
	lda 	sprites,x
	sta 	$0200,x
	dex
	bne 	load_sprites
	lda 	#$FE
	sta 	$0200
	sta 	$0203
	lda 	#PADDLE1_X
	sta		$0207
	sta		$020b
	sta		$020f
	lda		#PADDLE2_X
	sta		$0213
	sta		$0217
	sta		$021b
	lda		#$FE
	sta		$0204
	sta		$0208
	sta		$020c
	sta		$0210
	sta		$0214
	sta		$0218
	sta		$021c
	sta		$0220
	sta		$0224
	sta		$0228
	lda 	#$00
keep_title:
	pla
	tay
	pla
	tax
	pla
	plp
	rts
.endproc

.proc state_game_over
	php
	pha
	txa
	pha
	tya
	pha
	lda		title_up
	bne		skip_display
	jsr		display_game_over
skip_display:
	jsr		read_controller
	lda 	buttons1
	and		#%00010000
	beq		keep_screen
	jsr		clear_nametable
	jsr		display_title
	lda		#$00
	sta		title_up
	sta		p1_counter
	sta		p2_counter
	sta		score1
	sta		score1+1
	sta		score2
	sta		score2+1
	lda		#$00
	sta		gamestate
	lda		#$80
	sta		ball_x
	sta		ball_y
	lda		#$78
	sta		player1_y
	sta		player2_y
keep_screen:
	pla
	tay
	pla
	tax
	pla
	plp
	rts
.endproc

.proc display_title
	jsr		clear_nametable
	inc		title_up
	lda 	#$00
	sta		PPUMASK
	sta		PPUCTRL
	;clear sprites off of screen
	lda 	#$FE
	sta 	$0200
	sta 	$0203
	lda		#$FE
	sta		$0204
	sta		$0208
	sta		$020c
	sta		$0210
	sta		$0214
	sta		$0218
	sta		$021c
	sta		$0220
	sta		$0224
	sta		$0228
	lda		#<title
	sta		bgpointlo
	lda		#>title
	sta		bgpointhi
	jsr		draw_tilemap
	ldx		PPUSTATUS
	lda 	#$22
	sta		PPUADDR
	lda		#$50
	sta		PPUADDR
	tya
	sta		PPUDATA
	ldx		PPUSTATUS
	lda		#$2B
	sta		PPUADDR
	lda		#$E8
	sta		PPUADDR
	ldx 	#$08
	lda		#%01010101
write_attribute:
	sta		PPUDATA
	dex
	bne		write_attribute
	
	lda 	#%00011110
	sta 	PPUMASK
	lda 	#%10010000
	sta 	PPUCTRL
return:
	rts
.endproc

.proc play_field

	lda 	#$00
	sta		PPUMASK
	sta		PPUCTRL
	lda		#<playfield
	sta		bgpointlo
	lda		#>playfield
	sta		bgpointhi
	jsr		draw_tilemap
	lda 	#%00011110
	sta 	PPUMASK
	lda 	#%10010000
	sta 	PPUCTRL
	rts
.endproc

.proc clear_nametable
	lda 	#$00
	sta		PPUMASK
	sta		PPUCTRL
	lda 	PPUSTATUS
	lda 	#$20
	sta 	PPUADDR
	lda		#$00
	sta		PPUADDR
	ldy		#$30
outer_loop:
	ldx		#$32
inner_loop:
	lda		#$00
	sta 	PPUDATA
	dex
	cpx 	#$00
	bne 	inner_loop
	dey
	cpy		#$00
	bne		outer_loop
	lda 	#$00
	sta		clr_nm_tbl
	lda 	#%00011110
	sta 	PPUMASK
	lda 	#%10010000
	sta 	PPUCTRL
	rts
.endproc

.proc display_game_over
	jsr		clear_nametable
	inc		title_up
	lda 	#$00
	sta		PPUMASK
	sta		PPUCTRL
	;clear sprites off of screen
	lda 	#$FE
	sta 	$0200
	sta 	$0203
	lda 	#PADDLE1_X
	sta		$0207
	sta		$020b
	sta		$020f
	lda		#PADDLE2_X
	sta		$0213
	sta		$0217
	sta		$021b
	lda		#$FE
	sta		$0204
	sta		$0208
	sta		$020c
	sta		$0210
	sta		$0214
	sta		$0218
	sta		$021c
	sta		$0220
	sta		$0224
	sta		$0228
	lda		#<gameover
	sta		bgpointlo
	lda		#>gameover
	sta		bgpointhi
	jsr		draw_tilemap
;figure out which player won
	lda		p1_counter
	sec
	sbc		p2_counter
	bcc		player_2_win
	ldy		#$0E
	jmp 	player_1_win
player_2_win:
	ldy		#$0F
player_1_win:

	ldx		PPUSTATUS
	lda 	#$22
	sta		PPUADDR
	lda		#$50
	sta		PPUADDR
	tya
	sta		PPUDATA
	ldx		PPUSTATUS
	lda		#$2B
	sta		PPUADDR
	lda		#$E8
	sta		PPUADDR
	ldx 	#$08
	lda		#%01010101
write_attribute:
	sta		PPUDATA
	dex
	bne		write_attribute
	
	lda 	#%00011110
	sta 	PPUMASK
	lda 	#%10010000
	sta 	PPUCTRL
return:
	rts
.endproc

.proc draw_tilemap
	lda		#$00
	sta		counterlo
	lda		#$04
	sta		counterhi
	ldy		#$00
load_background:
	ldx		PPUSTATUS
	lda		#$20
	sta		PPUADDR
	lda		#$00
	sta		PPUADDR
outer_loop:

inner_loop:
	lda		(bgpointlo),y
	sta		PPUDATA
	iny
	cpy 	#$00
	bne		inner_loop
	inc		bgpointhi
	inx
	cpx		#$04
	bne		outer_loop
	rts
.endproc
.export vblankwait

.proc vblankwait
loop:
	bit 	PPUSTATUS
	bpl 	loop
	rts
.endproc

.segment "VECTORS"
.addr nmi, reset, irq

.segment "RODATA"
title:
.incbin "title.nam"
playfield:
.incbin "playfield.nam"
gameover:
.incbin "game_over.nam"
sprites:
	.byte $FE, $00, $01, $80
	.byte $FE, $01, $00, $80
	.byte $FE, $02, $00, $88
	.byte $FE, $03, $00, $80
	.byte $FE, $01, $00, $80
	.byte $FE, $02, $00, $88
	.byte $FE, $03, $00, $80
	.byte $FE, $00, $00, $40
	.byte $FE, $00, $00, $48
	.byte $FE, $00, $00, $E0
	.byte $FE, $00, $00, $E8
	.byte $50, $0E, $00, $20
	.byte $9F, $04, $00, $A8
background:

attribute:
	.byte %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
palette:
	.byte $0F,$00,$10,$20
	.byte $0F,$1c,$2c,$3c
	.byte $0F,$00,$10,$20
	.byte $0F,$00,$10,$20
	.byte $0F,$00,$10,$20
	.byte $0F,$1c,$2c,$3c
	.byte $0F,$00,$10,$20
	.byte $0F,$00,$10,$20
	
.segment "CHR"
.incbin "PONG.chr"