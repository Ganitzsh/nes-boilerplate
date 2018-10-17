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
  .byte $00, $00, $00, $00, $00

; This area of the memory goes from $00 to $FF and is mainly used to describe
; variables for your program
.segment "ZEROPAGE"

.segment "STARTUP"

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

; Basically now what you have to do is to clear the memory to avoid unwanted
; glitches when the game is starting
CLEARMEM:
  STA $0100, X
  STA $0300, X
  STA $0400, X
  STA $0500, X
  STA $0600, X
  STA $0700, X
  LDA #$FF
  ; Fills the $0200 level with $FF to clean the sprites memory
  STA $0200, X
  LDA #$00
  INX           ; if X != $00 keep clearing
  BNE CLEARMEM  ; else X == $00 then zero flag set and BNE is not triggered

  SPRITE_SIZE   = 4 ; 4 bytes
  TOTAL_SPRITES = 8 ; 4 sprites
  SPRITES_SIZE  = TOTAL_SPRITES * SPRITE_SIZE

  ; Prepare the PPU to receive the palette. It's basically telling the PPU at
  ; which address you will start storing the palette
  LDA $2002    ; Read PPUSTATUS to reset the high/low latch to high
  LDA #$3F
  STA $2006    ; Write the high byte of $3F00 address
  LDA #$00
  STA $2006    ; Write the low byte of $3F00 addres

  LDX #$00
LOADPALETTE:
  LDA PALETTE, X  ; Get color
  STA $2007       ; Store it into PPU
  INX             ; Next color
  CPX #$20        ; if x == 32 all colors are loaded
  BNE LOADPALETTE ; else keep loading

  JSR WAITFORVBLANK

  LDX #$00
LOADSPRITES:
  LDA SPRITES, X
  STA $0200, X
  INX
  CPX #SPRITES_SIZE
  BNE LOADSPRITES

  LDA #%10000000   ; enable NMI, sprites from Pattern Table 0
  STA $2000
  LDA #%00010000   ; enable sprites
  STA $2001

GAMELOOP:
  JSR WAITFORVBLANK
  JMP GAMELOOP

VBLANK:
  LDA #$00
  STA $2003  ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014  ; set the high byte (02) of the RAM address, start the transfer
  RTI

SPRITES:
  .byte $80,$00,$00,$80
  .byte $80,$01,$00,$88
  .byte $88,$02,$00,$80
  .byte $88,$03,$00,$88
  .byte $90,$04,$00,$80
  .byte $90,$05,$00,$88
  .byte $98,$06,$00,$80
  .byte $98,$07,$00,$88

PALETTE:
  ; Background palette data
  ; NOTE: You can change these data, they are simply for the template
  .byte $0F,$31,$32,$33
  .byte $0F,$35,$36,$37
  .byte $0F,$39,$3A,$3B
  .byte $0F,$3D,$3E,$0F

  ; Sprite palette data
  .byte $0F,$1C,$15,$14
  .byte $0F,$02,$38,$3C
  .byte $0F,$1C,$15,$14
  .byte $0F,$02,$38,$3C

; Set up the vectors and redirect notifications
.segment "VECTORS"
  .word VBLANK
  .word RESET
  .word 0

; This area represents the CHR ROM
.segment "CHARS"
  .incbin "mario.chr"
