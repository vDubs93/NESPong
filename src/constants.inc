PPUCTRL         = $2000
PPUMASK         = $2001
PPUSTATUS       = $2002
OAMADDR         = $2003
PPUSCROLL       = $2005
PPUADDR         = $2006
PPUDATA         = $2007

PULSE1_DUTYVOL  = $4000
PULSE1_SWEEP    = $4001
PULSE1_PERIODLO = $4002
PULSE1_PERIODHI = $4003

PULSE2_DUTYVOL  = $4004
PULSE2_SWEEP    = $4005
PULSE2_PERIODLO = $4006
PULSE2_PERIODHI = $4007

TRI_ENABLE      = $4008 ; No duty cycle or volume control.  Just on or off.
; TRI_UNUSED    = $4009 ; This register isn't used.
TRI_PERIODLO    = $400A
TRI_PERIODHI    = $400B

OAMDMA          = $4014
APUFLAGS        = $4015
JOYPAD1         = $4016
JOYPAD2         = $4017

BUTTON_A        = 1 << 7
BUTTON_B        = 1 << 6
BUTTON_SELECT   = 1 << 5
BUTTON_START    = 1 << 4
BUTTON_UP       = 1 << 3
BUTTON_DOWN     = 1 << 2
BUTTON_LEFT     = 1 << 1
BUTTON_RIGHT    = 1 << 0

PLAYER_DOWN     = $00
PLAYER_RIGHT    = $01
PLAYER_LEFT     = $02
PLAYER_UP       = $03