; This file contains the boilerplate code for starting developping a new NES
; game fast without caring about writing the hardware specific initialization
; for the console.
;
; Format: iNES

; This segment is used to describe what components of the NES your game will be
; using. This part is essentially dedicated to tell the emulator what hardware
; will be used.
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

.segment "ZEROPAGE"

.segmemt "RESET"


.segment "CLEARMEM"

.segment "CODE"

VBLANK:
