; Opponent routines for 1-Player game vs CPU
; 
; Title screen addition:
; 2 menu options: 1 player and 2 player
; 1 player option has a difficulty selector beside it
; difficulty 1: cpu has a 90 out of 256 chance to actually move towards ball position
; difficulty 2: cpu has a 120 out of 256 chance to actually move towards ball position
; difficulty 3: cpu has a 180 out of 256 chance to actually move towards ball position
; need to write a pseudorandom number generator
; *************
; * Procedure *
; *************
; 1. Check if movement timer is 0.  If so, conue to step 2. Otherwise, jump to step 4.
; 2. run rng, compare result to difficulty value.  
; 3. If result is greater than difficulty value, return. Else continue.
; 4. Check ball_y; CPU should always try to have the ball hit the center of the paddle.  Paddles are 24px tall, so
; desired ball position is player_2_y + 8
; 4. If ball_y < player_2_y + 8, dec player_2_y. Else if ball_y > player_2_y + 8, inc player_2_y. Else return.

; *******************
; * This is the RNG *
; *******************
.include "constants.inc"
.segment "ZEROPAGE"
difficulty: .res 1 ; cpu difficulty value.  Will be 90, 120, or 180
seed: .res 2       ; initialize 16-bit seed to any value except 0
movetimer: .res 1
.exportzp difficulty, seed, movetimer
.importzp ball_x, ball_y, player2_y, buttons2, ball_dir_x, prev_b2

.segment "CODE"

.proc rng
    php
	pha
	txa
	pha
	tya
	pha
	ldy     #8     ; iteration count (generates 8 bits)
	lda     seed+0
:
	asl        ; shift the register
	rol     seed+1
	bcc     :+
	eor     #$39   ; apply XOR feedback whenever a 1 bit is shifted out
:
	dey
	bne     :--
	sta     seed+0
	cmp     #0
    pla
	tay
	pla
	tax
	pla
	plp
    rts
.endproc

.proc check_if_move
; push registers onto stack
    php
	pha
	txa
	pha
	tya
	pha
    lda     #0
    sta     buttons2
    sta     prev_b2
    lda     movetimer
    cmp     #00
    beq     compare
    lda     ball_dir_x
    cmp     #$00
    bne     return

    sec
    lda     ball_x
    cmp     #120
    bcc     return
   
    jmp     do_move
    
compare:
    jsr     rng
    sec
    lda     seed
    cmp     difficulty
    bcs     return
    lda     #MOVE_TIMER
    sta     movetimer
do_move:
    ldx     movetimer
    dex
    stx     movetimer
    lda     player2_y
    adc     #8
    cmp     ball_y
    bcs     move_up
    bcc     move_down
    beq     return
move_up:
    lda     #BUTTON_UP
    sta     buttons2
    jmp     return
move_down:
    lda     #BUTTON_DOWN
    sta     buttons2
; restore register state and return
return:
    pla
	tay
	pla
	tax
	pla
	plp
    rts
.endproc
.export check_if_move