; reset console, clear RAM (set all RAM addresses to $FE, because $00 doesn't work?  I think?)
.include "constants.inc"
.segment "CODE"
.export reset
.import main
.import vblankwait
.import init_apu
.import play_tone
.proc reset
	sei
	cld
	LDX 	#$00
	STX 	PPUCTRL
	STX 	PPUMASK
	jsr		vblankwait
clrmem:
	lda 	#$FE
	sta 	$0200,x
	inx
	bne 	clrmem
	jsr		init_apu
	jsr		vblankwait
	jmp		main
.endproc