; There are duplicate procedures here... why?  I'm going to need to go over this project again
.include "constants.inc"
.segment "CODE"

.export init_apu
.export play_tone
.proc init_apu
	ldy #$13
loop:
	lda 	regs,y
	sta 	PULSE1_DUTYVOL, y
	dey
	bpl 	loop
	lda		#$0F
	sta		APUFLAGS
	lda		#$40
	sta		$4017
	rts
.endproc

.proc play_tone
	lda #%10000001
	sta $4000,y
	lda periodTableHi,x
	ora #%00000000
	sta $4003,y
	lda periodTableLo,x
	sta $4002,y
	rts
.endproc

.segment "RODATA"
; Low bytes for standard tuning
periodTableLo:
  .byte $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
  .byte $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
  .byte $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
  .byte $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  .byte $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  .byte $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  .byte $1f,$1d,$1b,$1a,$18,$17,$15,$14

periodTableHi:
  .byte $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  .byte $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00
regs:
	.byte $30,$08,$00,$00
	.byte $30,$08,$00,$00
	.byte $80,$00,$00,$00
	.byte $30,$00,$00,$00
	.byte $00,$00,$00,$00
