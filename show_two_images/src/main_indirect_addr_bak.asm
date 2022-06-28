.p816
.smart

.include "macros.inc"
.include "registers.inc"

.include "header.asm"

.segment "ZEROPAGE"
nmi_count: .res 2

.segment "CODE"

VRAM_CHARS = $0000
VRAM_BG1   = $7000

start:
	.include "init.asm"

	jsr load_img_1

	; Show BG1
	lda #%00000001
	sta TM

	lda #$0f
	sta INIDISP

	lda #$00
	sta $0A

	lda #$00
	sta $10
	lda #$80
	sta $11
	lda #$83
	sta $12
	ldx #VRAM_CHARS
	stx $13

	lda #%10000001
	sta NMITIMEN

mainloop:

	lda nmi_count
@nmi_check:
	wai
	cmp nmi_count
	beq @nmi_check

	lda $0A
	sta $0B
	lda JOY1H
	sta $0A
	eor $0B
	and $0A ; Ignore hold button
	bit #%10000000 ; B button
	beq @btn_not_pressed
		lda #%00000000
		sta TM
		jsr load_img_2
		lda #%00000001
		sta TM
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
	lda #$00
	sta $10
	lda #$80
	sta $11
	lda #$81
	sta $12
	ldy #$0000
@load_tiles_loop:
	lda [$10],y
	sta VMDATAL
	iny
	lda [$10],y
	sta VMDATAH
	iny
	cpy #$8000
	bne @load_tiles_loop
	lda #$82
	sta $12
	ldy #$0000
@load_tiles_loop_2:
	lda [$10],y
	sta VMDATAL
	iny
	lda [$10],y
	sta VMDATAH
	iny
	cpy #$6000
	bne @load_tiles_loop_2
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

load_img_2:
	; Set palette
	stz CGADD
	ldx #$0000
@palette_loop:
	lda palette_data_2, x
	sta CGDATA
	inx
	cpx #$0200
	bne @palette_loop
	; Load tiles
	lda #$80
	sta VMAIN
	ldx $13
	stx VMADDL
	ldy #$0000
@load_tiles_loop:
	lda [$10],y
	sta VMDATAL
	iny
	lda [$10],y
	sta VMDATAH
	iny
	inx
	cpy #$0100
	bne @load_tiles_loop
	stx $13
	lda $11
	inc
	sta $11
	rts

palette_data_1:
	.incbin "res/01_palette.dat"

palette_data_2:
	.incbin "res/02_palette.dat"

.segment "CODE1"

.incbin "res/01_tiles.dat", $0, $8000

.segment "CODE2"

.incbin "res/01_tiles.dat", $8000

.segment "CODE3"

.incbin "res/02_tiles.dat", $0, $8000

.segment "CODE4"

.incbin "res/02_tiles.dat", $8000
