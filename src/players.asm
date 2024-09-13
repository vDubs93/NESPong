; Paddle movement code for player 1 and player 2
; TODO: Add CPU player

.include "constants.inc"
.segment "ZEROPAGE"
.importzp buttons1, buttons2, prev_b1, prev_b2, player1_y, player2_y, cursor_y
.segment "CODE"

.export checkbuttons
.import check_if_move
.proc checkbuttons
	
check_p1up_pressed:
	lda 	buttons1
	and 	#BUTTON_UP
	beq 	check_p1down_pressed
	lda 	player1_y
	cmp		#TOPWALL
	beq		check_p1down_pressed
	lda 	player1_y
	sec
	sbc 	#$04
	sta 	player1_y
	jmp		check_p2up_pressed
check_p1down_pressed:
	lda 	buttons1
	and	 	#BUTTON_DOWN
	beq 	check_p2up_pressed
	lda		player1_y
	clc
	adc		#$10
	cmp		#BOTTOMWALL
	beq		check_p2up_pressed
	lda 	player1_y
	clc
	adc 	#$04
	sta		player1_y

check_p2up_pressed:
	lda		cursor_y
	cmp		#$80
	beq		skip_cpu
	jsr		check_if_move
skip_cpu:
	lda 	buttons2
	and 	#BUTTON_UP
	beq 	check_p2down_pressed
	lda 	player2_y
	cmp		#TOPWALL
	beq		check_p2down_pressed
	lda 	player2_y
	sec
	sbc 	#$04
	sta 	player2_y
	jmp		player1_move
check_p2down_pressed:
	lda 	buttons2
	and	 	#BUTTON_DOWN
	beq 	player1_move
	lda		player2_y
	clc
	adc		#$10
	cmp		#BOTTOMWALL
	beq		player1_move
	lda 	player2_y
	clc
	adc 	#$04
	sta		player2_y
	
player1_move:
	lda 	player1_y
	sta		$0204
	clc
	adc		#$08
	sta		$0208
	clc
	adc		#$08
	sta		$020c

player2_move:
	lda		player2_y
	sta		$0210
	clc
	adc		#$08
	sta		$0214
	clc
	adc		#$08
	sta		$0218
	
return:
	rts
.endproc
