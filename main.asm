; This file contains the boilerplate code for starting developping a new NES
; game fast without caring about writing the hardware specific initialization
; for the console
;
; Format: iNES

; This segment is used to describe what components of the NES your game will be
; using. This part is essentially dedicated to tell the emulator what hardware
; will be used
.segment "HEADER"

  .byte "NES"     ; Flag 1,2 and 3: Constant "NES" + MS-DOS EOF
  .byte $1A       ; MS-DOS EOF
  .byte $02       ; Flag 4: Amount of PGR ROM (in 16 KB unit)
  .byte $01       ; Flag 5: Amount of CHR ROM (in  8 KB unit)
  .byte %00000000 ; Flag 6: Mapper used -> Horizontal
  .byte $00       ; Flag 7
  .byte $00       ; Flag 8
  .byte $00       ; Flag 9: TV System NTSC ($01 is PAL)
  .byte $00
  ; Fillers
  .byte $00 $00 $00 $00 $00

; This area of the memory goes from $00 to $FF and is mainly used to describe
; variables for your program
.segment "ZEROPAGE"

; This area is where the PRG ROM starts
.segment "CODE"

WAITFORVBLANK:
  BIT $2002
  BPL WAITFORVBLANK
  RTS

IRQ:
  RTI

RESET:
  SEI       ; Turns off interupts
  CLD       ; Turns off decimal mode
  LDX #$40
  STX $4017 ; Turns off audio
  LDX #$FF
  TXS       ; Sets the stack pointer to $FF
  INX       ; X Register is now #$00
  STX $2000 ; Zero the PPUCTRL
  STX $2001 ; Zero the PPUMASK
  STX $4010 ; Turn off audio IRQ

  JSR WAITFORVBLANK

  TXA ; A Register is now #$00

CLEARMEM:
  STA $0100, X
  STA $0300, X
  STA $0400, X
  STA $0500, X
  STA $0600, X
  STA $0700, X
  LDA #$FF
  STA $0200, X
  LDA #$00
  INX
  BNE CLEARMEM

.segment "VECTORS"
  .word VBLANK
  .word RESET
  .word IRQ

; This area represents the CHR ROM
.segment "CHARS"
