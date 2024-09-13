; NESPong-specific reset procedure, RAM clearing and APU initialization
.include "constants.inc"
.segment "ZEROPAGE"
.importzp player_x, player_y, player_frame, player_dir, player_health

.segment "CODE"
.import main
.export reset
.proc reset
    sei
    cld
    ldx #$00
    stx PPUCTRL
    stx PPUMASK
    stx PPUSCROLL
    stx PPUSCROLL
    jsr clearmem
    jsr init_apu
vblankwait:
    bit PPUSTATUS
    bpl vblankwait
    jmp main
.endproc

.proc clearmem ; setting all RAM to $00 seems to not work, at least with Nintaco. Maybe not with FCEUX?
    ldx #$00
clear_loop: 
    lda #$00
    sta $0000,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    lda #$FE
    sta $0200,x
    inx
    bne clear_loop
    rts
.endproc

.proc init_apu ; Get that sound reset yo
    ldx #$13
loop:
    lda regs,y
    sta $4000,y
    dey
    bpl loop

    lda #$0f
    sta $4015
    lda #$40
    sta $4017
    rts

regs:
    .byte $30, $08, $00, $00
    .byte $30, $08, $00, $00
    .byte $80, $00, $00, $00
    .byte $30, $00, $00, $00
    .byte $00, $00, $00, $00
.endproc