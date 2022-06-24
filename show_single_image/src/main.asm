.p816
.smart

.include "macros.inc"
.include "registers.inc"

.include "header.asm"

.segment "CODE"

VRAM_CHARS = $0000
VRAM_BG1   = $7000

start:
	.include "init.asm"

	; Set palette
	stz CGADD
	lda #$00
	sta $00
@palette_loop:
	lda #$00
	sta CGDATA
	lda $00
	sta CGDATA
	lda #$7F
	sta CGDATA
	lda $00
	sta CGDATA
	inc A
	sta $00
	cmp #$80
	bne @palette_loop

	; Set Graphics Mode 3, 8x8 tiles
	lda #$03
	sta BGMODE

	; Set BG1 and tile map and character data
	lda #>VRAM_BG1
	sta BG1SC
	lda #(>VRAM_CHARS >> 4)
	sta BG12NBA

	; Load character data into VRAM
	lda #$80
	sta VMAIN
	ldx #VRAM_CHARS
	stx VMADDL
	ldx #$00
@charset_loop:
	stz VMDATAL
	stz VMDATAH
	inx
	cpx #$20
	bne @charset_loop
	ldx #$00
@charset_loop_1:
	lda #$FF
	sta VMDATAL
	stz VMDATAH
	inx
	cpx #$08
	bne @charset_loop_1
	ldx #$00
@charset_loop_1_1:
	stz VMDATAL
	stz VMDATAH
	inx
	cpx #$18
	bne @charset_loop_1_1

	; Set all position as blank
	ldx #VRAM_BG1
	stx VMADDL
@clear_screen_loop:
	stz VMDATAL
	stz VMDATAH
	inx
	cpx #(VRAM_BG1 + 32 * 32)
	bne @clear_screen_loop

	; Set some tile
	ldx #(VRAM_BG1 + 14 * 32 + 16)
	stx VMADDL
	lda #$01
	sta VMDATAL
	stz VMDATAH
	sta VMDATAL
	stz VMDATAH

	; Show BG1
	lda #%00000001
	sta TM

	lda #$0f
	sta INIDISP

	; Test load pcx data into RAM
	ldx #$00
load_pcx_loop:
	lda $818000,x
	sta $7E0000,x
	inx
	cpx #$8000
	bne load_pcx_loop
	ldx #$00
load_pcx_loop_3:
	lda $828000,x
	sta $7E8000,x
	inx
	cpx #$5B2F
	bne load_pcx_loop_3

busywait:
	bra busywait

nmi:
	bit RDNMI
_rti:
	rti

.segment "CODE1"

pcx_data: .incbin "res/Great_Wave_off_Kanagawa2.pcx", $0, $8000

.segment "CODE2"

pcx_data_2: .incbin "res/Great_Wave_off_Kanagawa2.pcx", $8000
