; PPU addresses
PPUCTRL         = $2000
PPUMASK         = $2001
PPUSTATUS       = $2002
OAMADDR         = $2003
PPUSCROLL       = $2005
PPUADDR         = $2006
PPUDATA         = $2007

; Pulse 1 channel addresses
PULSE1_DUTYVOL  = $4000
PULSE1_SWEEP    = $4001
PULSE1_PERIODLO = $4002
PULSE1_PERIODHI = $4003

; Pulse 2 channel addresses
PULSE2_DUTYVOL  = $4004
PULSE2_SWEEP    = $4005
PULSE2_PERIODLO = $4006
PULSE2_PERIODHI = $4007

; Triangle channel addresses
TRI_ENABLE      = $4008 ; No duty cycle or volume control.  Just on or off.
; TRI_UNUSED    = $4009 ; This register isn't used.
TRI_PERIODLO    = $400A
TRI_PERIODHI    = $400B

; OAM DMA trigger address
OAMDMA          = $4014

; flags for APU activation
APUFLAGS        = $4015

; Controller read addresses
JOYPAD1         = $4016
JOYPAD2         = $4017

; Button constants (it was easier to just assign 1 in base 10 and then shift left as many times as needed for each button)
BUTTON_A        = 1 << 7
BUTTON_B        = 1 << 6
BUTTON_SELECT   = 1 << 5
BUTTON_START    = 1 << 4
BUTTON_UP       = 1 << 3
BUTTON_DOWN     = 1 << 2
BUTTON_LEFT     = 1 << 1
BUTTON_RIGHT    = 1 << 0

; Player movement directions?  Possibly left over from a previous tutorial project?
PLAYER_DOWN     = $00
PLAYER_RIGHT    = $01
PLAYER_LEFT     = $02
PLAYER_UP       = $03

; constants for pong

; Screen borders for ball
RIGHTWALL 	=$F6
TOPWALL		=$20
BOTTOMWALL	=$D8
LEFTWALL	=$02

; State machine values
AT_TITLE	=$00
AT_GAME		=$01
AT_LOSE		=$02

; Paddle X values
PADDLE1_X	=$08
PADDLE2_X	=$F0

; CPU movement timer
MOVE_TIMER = 10
