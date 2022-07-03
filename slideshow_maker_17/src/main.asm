.p816
.smart

.include "macros.inc"
.include "registers.inc"

.include "header.asm"

.segment "ZEROPAGE"
nmi_count: .res 1
cur_img: .res 1
load_line_remain: .res 1
tile_bank: .res 1
tile_addr: .res 2
pal_bank: .res 1
pal_addr: .res 2
prev_btn: .res 1
prev_btn_temp: .res 1

.segment "CODE"

VRAM_CHARS = $0000
VRAM_BG1   = $7000

start:
	.include "init.asm"

	; Init variables
	stz nmi_count
	stz prev_btn
	jsr reset_img_index

	; Load image 1
	jsr load_palette
	; Set Graphics Mode 3, 8x8 tiles
	lda #$03
	sta BGMODE
	; Set BG1 and tile map and character data
	lda #>VRAM_BG1
	sta BG1SC
	lda #(>VRAM_CHARS >> 4)
	sta BG12NBA
	lda #$80
	sta VMAIN
	ldx #VRAM_CHARS
	stx VMADDL
	ldy #$000E
@load_tiles_img_1:
	jsr load_tiles
	dey
	bne @load_tiles_img_1
	inc cur_img

	; Set tiles
	ldx #VRAM_BG1
	stx VMADDL
	ldx #$0000
@set_tiles_loop:
	stx VMDATAL
	inx
	cpx #(32 * 28)
	bne @set_tiles_loop

	; Zero out additional tiles
	ldx #$0000
@zero_tiles_loop:
	stz VMDATAL
	stz VMDATAH
	inx
	cpx #(32 * 4)
	bne @zero_tiles_loop

	; Show BG1
	lda #%00000001
	sta TM

	lda #$0f
	sta INIDISP

	lda #%10000001
	sta NMITIMEN

mainloop:

	lda nmi_count
@nmi_check:
	wai
	cmp nmi_count
	beq @nmi_check

	lda prev_btn
	sta prev_btn_temp
	lda JOY1H
	sta prev_btn
	lda load_line_remain
	bne @load_tiles
	lda prev_btn
	eor prev_btn_temp
	and prev_btn ; Ignore hold button
	bit #%10000000 ; B button
	beq @btn_not_pressed
	lda #$00
	sta INIDISP
	jsr load_palette
	ldx #VRAM_CHARS
	stx VMADDL
	lda #$0E
	sta load_line_remain
	bra mainloop
@load_tiles:
	jsr load_tiles
	dec load_line_remain
	bne mainloop
	lda #$0F
	sta INIDISP
	inc cur_img
	lda cur_img
	cmp #$11
	bne mainloop
	jsr reset_img_index
	bra mainloop
@btn_not_pressed:

	bra mainloop

nmi:
	bit RDNMI
	inc nmi_count
_rti:
	rti

reset_img_index:
	stz cur_img
	stz load_line_remain
	lda #$81
	sta tile_bank
	ldx #$8000
	stx tile_addr
	lda #$80
	sta pal_bank
	ldx #$D000
	stx pal_addr
	rts

load_palette:
	stz CGADD
	lda #%00000000
	sta DMAP0
	lda #<CGDATA
	sta BBAD0
	ldx pal_addr
	stx A1T0L
	lda pal_bank
	sta A1B0
	ldx #$0200
	stx DAS0L
	lda #1
	sta MDMAEN
	setA16
	lda pal_addr
	clc
	adc #$200
	sta pal_addr
	setA8
	rts

load_tiles:
	; Load tiles
	LOAD_SIZE=$1000
	lda #%00000001
	sta DMAP0
	lda #<VMDATAL
	sta BBAD0
	ldx tile_addr
	stx A1T0L
	lda tile_bank
	sta A1B0
	ldx #LOAD_SIZE
	stx DAS0L
	lda #$01
	sta MDMAEN
	setA16
	lda tile_addr
	clc
	adc #LOAD_SIZE
	sta tile_addr
	setA8
	bcs @update_bank
	rts
@update_bank:
	ldx #$8000
	stx tile_addr
	inc tile_bank
	rts

.segment "PALETTES"
.incbin "res/01_palette.dat"
.incbin "res/02_palette.dat"
.incbin "res/03_palette.dat"
.incbin "res/04_palette.dat"
.incbin "res/05_palette.dat"
.incbin "res/06_palette.dat"
.incbin "res/07_palette.dat"
.incbin "res/08_palette.dat"
.incbin "res/09_palette.dat"
.incbin "res/10_palette.dat"
.incbin "res/11_palette.dat"
.incbin "res/12_palette.dat"
.incbin "res/13_palette.dat"
.incbin "res/14_palette.dat"
.incbin "res/15_palette.dat"
.incbin "res/16_palette.dat"
.incbin "res/17_palette.dat"

.segment "CODE01"
.incbin "res/01_tiles.dat", $0000, $8000
.segment "CODE02"
.incbin "res/01_tiles.dat", $8000
.incbin "res/02_tiles.dat", $0000, $2000
.segment "CODE03"
.incbin "res/02_tiles.dat", $2000, $8000
.segment "CODE04"
.incbin "res/02_tiles.dat", $A000
.incbin "res/03_tiles.dat", $0000, $4000
.segment "CODE05"
.incbin "res/03_tiles.dat", $4000, $8000
.segment "CODE06"
.incbin "res/03_tiles.dat", $C000
.incbin "res/04_tiles.dat", $0000, $6000
.segment "CODE07"
.incbin "res/04_tiles.dat", $6000
.segment "CODE08"
.incbin "res/05_tiles.dat", $0000, $8000
.segment "CODE09"
.incbin "res/05_tiles.dat", $8000
.incbin "res/06_tiles.dat", $0000, $2000
.segment "CODE10"
.incbin "res/06_tiles.dat", $2000, $8000
.segment "CODE11"
.incbin "res/06_tiles.dat", $A000
.incbin "res/07_tiles.dat", $0000, $4000
.segment "CODE12"
.incbin "res/07_tiles.dat", $4000, $8000
.segment "CODE13"
.incbin "res/07_tiles.dat", $C000
.incbin "res/08_tiles.dat", $0000, $6000
.segment "CODE14"
.incbin "res/08_tiles.dat", $6000
.segment "CODE15"
.incbin "res/09_tiles.dat", $0000, $8000
.segment "CODE16"
.incbin "res/09_tiles.dat", $8000
.incbin "res/10_tiles.dat", $0000, $2000
.segment "CODE17"
.incbin "res/10_tiles.dat", $2000, $8000
.segment "CODE18"
.incbin "res/10_tiles.dat", $A000
.incbin "res/11_tiles.dat", $0000, $4000
.segment "CODE19"
.incbin "res/11_tiles.dat", $4000, $8000
.segment "CODE20"
.incbin "res/11_tiles.dat", $C000
.incbin "res/12_tiles.dat", $0000, $6000
.segment "CODE21"
.incbin "res/12_tiles.dat", $6000
.segment "CODE22"
.incbin "res/13_tiles.dat", $0000, $8000
.segment "CODE23"
.incbin "res/13_tiles.dat", $8000
.incbin "res/14_tiles.dat", $0000, $2000
.segment "CODE24"
.incbin "res/14_tiles.dat", $2000, $8000
.segment "CODE25"
.incbin "res/14_tiles.dat", $A000
.incbin "res/15_tiles.dat", $0000, $4000
.segment "CODE26"
.incbin "res/15_tiles.dat", $4000, $8000
.segment "CODE27"
.incbin "res/15_tiles.dat", $C000
.incbin "res/16_tiles.dat", $0000, $6000
.segment "CODE28"
.incbin "res/16_tiles.dat", $6000
.segment "CODE29"
.incbin "res/17_tiles.dat", $0000, $8000
.segment "CODE30"
.incbin "res/17_tiles.dat", $8000


; .segment "CODE01"
; .incbin "res/01_tiles.dat", $0, $8000
; .segment "CODE02"
; .incbin "res/01_tiles.dat", $8000
; .incbin "res/02_tiles.dat", $0, $2000
; .segment "CODE03"
; .incbin "res/02_tiles.dat", $2000, $8000
; .segment "CODE04"
; .incbin "res/02_tiles.dat", $A000

; .segment "CODE01"
; .incbin "res/01_tiles.dat", $0, $7000
; .incbin "res/01_palette.dat"
; .segment "CODE02"
; .incbin "res/01_tiles.dat", $7000

; .segment "CODE03"
; .incbin "res/02_tiles.dat", $0, $7000
; .incbin "res/02_palette.dat"
; .segment "CODE04"
; .incbin "res/02_tiles.dat", $7000

; .segment "CODE05"
; .incbin "res/03_tiles.dat", $0, $7000
; .incbin "res/03_palette.dat"
; .segment "CODE06"
; .incbin "res/03_tiles.dat", $7000

; .segment "CODE07"
; .incbin "res/04_tiles.dat", $0, $7000
; .incbin "res/04_palette.dat"
; .segment "CODE08"
; .incbin "res/04_tiles.dat", $7000

; .segment "CODE09"
; .incbin "res/05_tiles.dat", $0, $7000
; .incbin "res/05_palette.dat"
; .segment "CODE10"
; .incbin "res/05_tiles.dat", $7000

; .segment "CODE11"
; .incbin "res/06_tiles.dat", $0, $7000
; .incbin "res/06_palette.dat"
; .segment "CODE12"
; .incbin "res/06_tiles.dat", $7000

; .segment "CODE13"
; .incbin "res/07_tiles.dat", $0, $7000
; .incbin "res/07_palette.dat"
; .segment "CODE14"
; .incbin "res/07_tiles.dat", $7000

; .segment "CODE15"
; .incbin "res/08_tiles.dat", $0, $7000
; .incbin "res/08_palette.dat"
; .segment "CODE16"
; .incbin "res/08_tiles.dat", $7000

; .segment "CODE17"
; .incbin "res/09_tiles.dat", $0, $7000
; .incbin "res/09_palette.dat"
; .segment "CODE18"
; .incbin "res/09_tiles.dat", $7000

; .segment "CODE19"
; .incbin "res/10_tiles.dat", $0, $7000
; .incbin "res/10_palette.dat"
; .segment "CODE20"
; .incbin "res/10_tiles.dat", $7000

; .segment "CODE21"
; .incbin "res/11_tiles.dat", $0, $7000
; .incbin "res/11_palette.dat"
; .segment "CODE22"
; .incbin "res/11_tiles.dat", $7000

; .segment "CODE23"
; .incbin "res/12_tiles.dat", $0, $7000
; .incbin "res/12_palette.dat"
; .segment "CODE24"
; .incbin "res/12_tiles.dat", $7000

; .segment "CODE25"
; .incbin "res/13_tiles.dat", $0, $7000
; .incbin "res/13_palette.dat"
; .segment "CODE26"
; .incbin "res/13_tiles.dat", $7000

; .segment "CODE27"
; .incbin "res/14_tiles.dat", $0, $7000
; .incbin "res/14_palette.dat"
; .segment "CODE28"
; .incbin "res/14_tiles.dat", $7000

; .segment "CODE29"
; .incbin "res/15_tiles.dat", $0, $7000
; .incbin "res/15_palette.dat"
; .segment "CODE30"
; .incbin "res/15_tiles.dat", $7000
