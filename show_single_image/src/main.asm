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
	ldx #$0000
@palette_loop:
	lda palette_data, x
	sta CGDATA
	inx
	cpx #$0200
	bne @palette_loop

	; Set Graphics Mode 3, 8x8 tiles
	lda #$03
	sta BGMODE

	; Set BG1 and tile map and character data
	lda #>VRAM_BG1
	sta BG1SC
	lda #(>VRAM_CHARS >> 4)
	sta BG12NBA

	; Set tiles
	lda #$80
	sta VMAIN
	ldx #VRAM_CHARS
	stx VMADDL
	ldx #$0000
load_tiles_loop:
	lda $818000,x
	sta VMDATAL
	inx
	lda $818000,x
	sta VMDATAH
	inx
	cpx #$8000
	bne load_tiles_loop
	ldx #$0000
load_tiles_loop_2:
	lda $828000,x
	sta VMDATAL
	inx
	lda $828000,x
	sta VMDATAH
	inx
	cpx #$6000
	bne load_tiles_loop_2

	; Set all position as blank
	ldx #VRAM_BG1
	stx VMADDL
	ldx #$0000
@clear_screen_loop:
	stx VMDATAL
	; stz VMDATAH
	inx
	cpx #(32 * 28)
	bne @clear_screen_loop

	; Show BG1
	lda #%00000001
	sta TM

	lda #$0f
	sta INIDISP

busywait:
	bra busywait

nmi:
	bit RDNMI
_rti:
	rti

palette_data:
	.incbin "res/palette.dat"

.segment "CODE1"

pcx_data: .incbin "res/tiles.dat", $0, $8000

.segment "CODE2"

pcx_data_2: .incbin "res/tiles.dat", $8000
