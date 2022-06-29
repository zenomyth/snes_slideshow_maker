.p816
.smart

.include "macros.inc"
.include "registers.inc"

.include "header.asm"

.segment "ZEROPAGE"
nmi_count: .res 1
load_status: .res 1
load_addr: .res 2
load_bank: .res 1
prev_btn: .res 1
prev_btn_temp: .res 1

.segment "CODE"

VRAM_CHARS = $0000
VRAM_BG1   = $7000

start:
	.include "init.asm"

	; Init variables
	stz prev_btn
	stz load_status

	; Load image 1
	lda #$81
	sta load_bank
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
	ldx #$8000
	stx load_addr
	ldy #$0007
@load_img_1_1:
	jsr load_img
	dey
	bne @load_img_1_1
	lda #$82
	sta load_bank
	ldx #$8000
	stx load_addr
	ldy #$0007
@load_img_1_2:
	jsr load_img
	dey
	bne @load_img_1_2

	;Set pointer to image 2
	lda #$83
	sta load_bank
	ldx #$8000
	stx load_addr

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
	lda load_status
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
	inc load_status
	bra mainloop
@load_tiles:
	jsr load_img
	ldx load_addr
	cpx #$F000
	bne mainloop
	lda load_status
	cmp #$01
	beq @load_tiles_2
	; Load end
	inc load_bank
	ldx #$8000
	stx load_addr
	lda load_bank
	cmp #$9F
	bne @load_end
		lda #$81
		sta load_bank
@load_end:
	lda #$0F
	sta INIDISP
	stz load_status
	bra mainloop
@load_tiles_2:
	inc load_bank
	ldx #$8000
	stx load_addr
	inc load_status
	bra mainloop
@btn_not_pressed:

	bra mainloop

nmi:
	bit RDNMI
	inc nmi_count
_rti:
	rti

load_palette:
	stz CGADD
	lda #%00000000
	sta DMAP0
	lda #<CGDATA
	sta BBAD0
	ldx #$F000
	stx A1T0L
	lda load_bank
	sta A1B0
	ldx #$0200
	stx DAS0L
	lda #1
	sta MDMAEN
	rts

load_img:
	; Load tiles
	LOAD_SIZE=$1000
	lda #%00000001
	sta DMAP0
	lda #<VMDATAL
	sta BBAD0
	ldx load_addr
	stx A1T0L
	lda load_bank
	sta A1B0
	ldx #LOAD_SIZE
	stx DAS0L
	lda #$01
	sta MDMAEN
	setA16
	lda load_addr
	clc
	adc #LOAD_SIZE
	sta load_addr
	setA8
	rts

.segment "CODE01"
.incbin "res/01_tiles.dat", $0, $7000
.incbin "res/01_palette.dat"
.segment "CODE02"
.incbin "res/01_tiles.dat", $7000

.segment "CODE03"
.incbin "res/02_tiles.dat", $0, $7000
.incbin "res/02_palette.dat"
.segment "CODE04"
.incbin "res/02_tiles.dat", $7000

.segment "CODE05"
.incbin "res/03_tiles.dat", $0, $7000
.incbin "res/03_palette.dat"
.segment "CODE06"
.incbin "res/03_tiles.dat", $7000

.segment "CODE07"
.incbin "res/04_tiles.dat", $0, $7000
.incbin "res/04_palette.dat"
.segment "CODE08"
.incbin "res/04_tiles.dat", $7000

.segment "CODE09"
.incbin "res/05_tiles.dat", $0, $7000
.incbin "res/05_palette.dat"
.segment "CODE10"
.incbin "res/05_tiles.dat", $7000

.segment "CODE11"
.incbin "res/06_tiles.dat", $0, $7000
.incbin "res/06_palette.dat"
.segment "CODE12"
.incbin "res/06_tiles.dat", $7000

.segment "CODE13"
.incbin "res/07_tiles.dat", $0, $7000
.incbin "res/07_palette.dat"
.segment "CODE14"
.incbin "res/07_tiles.dat", $7000

.segment "CODE15"
.incbin "res/08_tiles.dat", $0, $7000
.incbin "res/08_palette.dat"
.segment "CODE16"
.incbin "res/08_tiles.dat", $7000

.segment "CODE17"
.incbin "res/09_tiles.dat", $0, $7000
.incbin "res/09_palette.dat"
.segment "CODE18"
.incbin "res/09_tiles.dat", $7000

.segment "CODE19"
.incbin "res/10_tiles.dat", $0, $7000
.incbin "res/10_palette.dat"
.segment "CODE20"
.incbin "res/10_tiles.dat", $7000

.segment "CODE21"
.incbin "res/11_tiles.dat", $0, $7000
.incbin "res/11_palette.dat"
.segment "CODE22"
.incbin "res/11_tiles.dat", $7000

.segment "CODE23"
.incbin "res/12_tiles.dat", $0, $7000
.incbin "res/12_palette.dat"
.segment "CODE24"
.incbin "res/12_tiles.dat", $7000

.segment "CODE25"
.incbin "res/13_tiles.dat", $0, $7000
.incbin "res/13_palette.dat"
.segment "CODE26"
.incbin "res/13_tiles.dat", $7000

.segment "CODE27"
.incbin "res/14_tiles.dat", $0, $7000
.incbin "res/14_palette.dat"
.segment "CODE28"
.incbin "res/14_tiles.dat", $7000

.segment "CODE29"
.incbin "res/15_tiles.dat", $0, $7000
.incbin "res/15_palette.dat"
.segment "CODE30"
.incbin "res/15_tiles.dat", $7000
