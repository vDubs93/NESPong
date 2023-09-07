.include "constants.inc"

.segment "ZEROPAGE"
.importzp buttons1, buttons2, prev_b1, prev_b2

.segment "CODE"

.export read_controller
.proc read_controller
	lda		buttons1
	sta		prev_b1
	lda		buttons2
	sta		prev_b2
;Player 1
    lda     #$01 ; strobe the controller
    sta     JOYPAD1
    sta     buttons1
    lsr     a ; shift 1 into carry, making A hold $00
    sta     JOYPAD1 ; latch input
read_loop1:
    lda     JOYPAD1 ; get next bit from controller
    lsr     a ; shift 1 into carry
    rol     buttons1 ; rotate bits into buttons
    bcc     read_loop1
;Player 2
    lda     #$01 ; strobe the controller
    sta     JOYPAD2
    sta     buttons2
    lsr     a ; shift 1 into carry, making A hold $00
    sta     JOYPAD2 ; latch input
read_loop2:
    lda     JOYPAD2 ; get next bit from controller
    lsr     a ; shift 1 into carry
    rol     buttons2 ; rotate bits into buttons
    bcc     read_loop2
return:
    rts
.endproc