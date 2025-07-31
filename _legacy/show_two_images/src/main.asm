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
	jsr load_img_2
	dey
	bne @load_img_1_1
	lda #$82
	sta load_bank
	ldx #$8000
	stx load_addr
	ldy #$0007
@load_img_1_2:
	jsr load_img_2
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
	jsr load_palette
	; lda #$80
	; sta VMAIN
	ldx #VRAM_CHARS
	stx VMADDL
	inc load_status
	bra mainloop
@load_tiles:
	jsr load_img_2
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
	cmp #$85
	bne @load_end
		lda #$81
		sta load_bank
@load_end:
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

load_img_1:
	; Set palette
	stz CGADD
	ldx #$0000
@palette_loop:
	lda palette_data_1, x
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
	; Load tiles
	lda #$80
	sta VMAIN
	ldx #VRAM_CHARS
	stx VMADDL
	lda #%00000001
	sta DMAP0
	lda #<VMDATAL
	sta BBAD0
	ldx #$8000
	stx A1T0L
	lda #$81
	sta A1B0
	ldx #$7000
	stx DAS0L
	lda #1
	sta MDMAEN
	lda #%00000001
	sta DMAP0
	lda #<VMDATAL
	sta BBAD0
	ldx #$8000
	stx A1T0L
	lda #$82
	sta A1B0
	ldx #$7000
	stx DAS0L
	lda #1
	sta MDMAEN
	; Set tiles
	ldx #VRAM_BG1
	stx VMADDL
	ldx #$0000
@set_tiles_loop:
	stx VMDATAL
	inx
	cpx #(32 * 28)
	bne @set_tiles_loop
	rts

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

load_img_2:
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

.segment "CODE1"

.incbin "res/01_tiles.dat", $0, $7000

palette_data_1:
	.incbin "res/01_palette.dat"

.segment "CODE2"

.incbin "res/01_tiles.dat", $7000

.segment "CODE3"

.incbin "res/02_tiles.dat", $0, $7000

palette_data_2:
	.incbin "res/02_palette.dat"

.segment "CODE4"

.incbin "res/02_tiles.dat", $7000
