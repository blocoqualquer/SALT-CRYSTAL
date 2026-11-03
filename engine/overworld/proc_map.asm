; Procedurally generated map prototype.
;
; The map's blocks come from a seed (the trainer ID), so the same save
; always gets the same terrain and nothing has to be stored in the save.
; LoadBlockData calls ProcGenMap after the (empty) ROM blocks are copied
; into wOverworldMapBlocks.

DEF PROC_W EQU PROC_TEST_WIDTH
DEF PROC_H EQU PROC_TEST_HEIGHT
DEF PROC_STRIDE EQU PROC_W + 6

DEF PROC_GRASS    EQU $02
DEF PROC_TALL     EQU $03
DEF PROC_FLOWERS  EQU $04
DEF PROC_TREE     EQU $05
DEF PROC_PATH     EQU $01
DEF PROC_WATER    EQU $57

; scratch layout (wSaltScratch)
DEF PS_SEED  EQU 0 ; dw
DEF PS_X     EQU 2
DEF PS_Y     EQU 3
DEF PS_W     EQU 4
DEF PS_H     EQU 5
DEF PS_BLK   EQU 6
DEF PS_CX    EQU 7
DEF PS_CY    EQU 8
DEF PS_MAXW  EQU 9
DEF PS_MAXH  EQU 10
DEF PS_PX    EQU 11

ProcGenMap::
; seed from the trainer ID
	ld a, [wPlayerID]
	xor $a5
	ld [wSaltScratch + PS_SEED], a
	ld a, [wPlayerID + 1]
	xor $3c
	or $01 ; never zero
	ld [wSaltScratch + PS_SEED + 1], a

; all grass
	ld a, PROC_GRASS
	ld b, 0
	ld c, 0
	ld d, PROC_W
	ld e, PROC_H
	call ProcRect
; patches of tall grass, flowers, ponds and woods
	ld a, PROC_TALL
	ld b, 28
	ld de, 6 << 8 | 4
	call ProcScatter
	ld a, PROC_FLOWERS
	ld b, 12
	ld de, 2 << 8 | 2
	call ProcScatter
	ld a, PROC_WATER
	ld b, 3
	ld de, 4 << 8 | 3
	call ProcScatter
	ld a, PROC_TREE
	ld b, 22
	ld de, 4 << 8 | 4
	call ProcScatter
; ring of trees around the map
	ld a, PROC_TREE
	ld b, 0
	ld c, 0
	ld d, PROC_W
	ld e, 1
	call ProcRect
	ld a, PROC_TREE
	ld b, 0
	ld c, PROC_H - 1
	ld d, PROC_W
	ld e, 1
	call ProcRect
	ld a, PROC_TREE
	ld b, 0
	ld c, 0
	ld d, 1
	ld e, PROC_H
	call ProcRect
	ld a, PROC_TREE
	ld b, PROC_W - 1
	ld c, 0
	ld d, 1
	ld e, PROC_H
	call ProcRect
; clearing at the entrance
	ld a, PROC_GRASS
	ld b, 12
	ld c, PROC_H - 4
	ld d, 6
	ld e, 4
	call ProcRect
; a winding path from the entrance to the top
	ld a, 14
	ld [wSaltScratch + PS_PX], a
	ld c, PROC_H - 1 ; row
.path_row
	push bc
	ld a, [wSaltScratch + PS_PX]
	ld b, a
	ld a, PROC_PATH
	ld d, 2
	ld e, 1
	call ProcRect ; two blocks wide
	pop bc
; the first few rows go straight up
	ld a, c
	cp PROC_H - 4
	jr nc, .next_row
; maybe wander sideways (keeping the path joined)
	push bc
	ld b, 3
	call ProcRandMod
	pop bc
	and a
	jr nz, .next_row
	push bc
	ld b, 2
	call ProcRandMod
	pop bc
	ld b, a
	ld a, [wSaltScratch + PS_PX]
	and a
	jr z, .noop
	ld d, a
	ld a, b
	and a
	ld a, d
	jr z, .go_left
	cp PROC_W - 4
	jr nc, .next_row
	inc a
	jr .shifted
.go_left
	cp 3
	jr c, .next_row
	dec a
.shifted
	ld [wSaltScratch + PS_PX], a
	push bc
	ld b, a
	ld a, PROC_PATH
	ld d, 2
	ld e, 1
	call ProcRect
	pop bc
.noop
.next_row
	ld a, c
	and a
	ret z
	dec c
	jr .path_row

ProcRand:
; xorshift16 on the seed; returns a random byte in a
	push bc
	push de
	push hl
	ld hl, wSaltScratch + PS_SEED
	ld e, [hl]
	inc hl
	ld d, [hl]
; x ^= x << 7
	ld h, d
	ld l, e
	ld b, 7
.shift
	add hl, hl
	dec b
	jr nz, .shift
	ld a, h
	xor d
	ld d, a
	ld a, l
	xor e
	ld e, a
; x ^= x >> 9
	ld a, d
	srl a
	xor e
	ld e, a
; x ^= x << 8
	ld a, e
	xor d
	ld d, a
	ld hl, wSaltScratch + PS_SEED
	ld [hl], e
	inc hl
	ld [hl], d
	ld a, d
	pop hl
	pop de
	pop bc
	ret

ProcRandMod:
; a = random number in [0, b)
	call ProcRand
.loop
	cp b
	ret c
	sub b
	jr .loop

ProcPutBlock:
; a = block, d = x, e = y (blocks); ignores spots outside the map
	push bc
	push de
	push hl
	push af
	ld a, d
	cp PROC_W
	jr nc, .skip
	ld a, e
	cp PROC_H
	jr nc, .skip
	ld hl, wOverworldMapBlocks + 3 * PROC_STRIDE + 3
	ld a, e
	ld bc, PROC_STRIDE
	call AddNTimes
	ld c, d
	ld b, 0
	add hl, bc
	pop af
	ld [hl], a
	jr .done
.skip
	pop af
.done
	pop hl
	pop de
	pop bc
	ret

ProcRect:
; fill a rectangle: a = block, b = x, c = y, d = width, e = height
	ld [wSaltScratch + PS_BLK], a
	ld a, b
	ld [wSaltScratch + PS_X], a
	ld a, c
	ld [wSaltScratch + PS_Y], a
	ld a, d
	ld [wSaltScratch + PS_W], a
	ld a, e
	ld [wSaltScratch + PS_H], a
	ld a, c
	ld [wSaltScratch + PS_CY], a
	ld b, e
.row
	push bc
	ld a, [wSaltScratch + PS_X]
	ld [wSaltScratch + PS_CX], a
	ld a, [wSaltScratch + PS_W]
	ld c, a
.col
	push bc
	ld a, [wSaltScratch + PS_CX]
	ld d, a
	ld a, [wSaltScratch + PS_CY]
	ld e, a
	ld a, [wSaltScratch + PS_BLK]
	call ProcPutBlock
	ld hl, wSaltScratch + PS_CX
	inc [hl]
	pop bc
	dec c
	jr nz, .col
	ld hl, wSaltScratch + PS_CY
	inc [hl]
	pop bc
	dec b
	jr nz, .row
	ret

ProcScatter:
; drop b random rectangles of block a, at most d x e blocks each
	ld [wSaltScratch + PS_BLK], a
	ld a, d
	ld [wSaltScratch + PS_MAXW], a
	ld a, e
	ld [wSaltScratch + PS_MAXH], a
.next
	push bc
	ld b, PROC_W
	call ProcRandMod
	ld [wSaltScratch + PS_CX], a ; (reused as scratch for x)
	ld b, PROC_H
	call ProcRandMod
	ld [wSaltScratch + PS_CY], a
	ld a, [wSaltScratch + PS_MAXW]
	ld b, a
	call ProcRandMod
	inc a
	ld d, a
	ld a, [wSaltScratch + PS_MAXH]
	ld b, a
	call ProcRandMod
	inc a
	ld e, a
	ld a, [wSaltScratch + PS_CX]
	ld b, a
	ld a, [wSaltScratch + PS_CY]
	ld c, a
	ld a, [wSaltScratch + PS_BLK]
	push af
	ld a, [wSaltScratch + PS_MAXW]
	push af
	ld a, [wSaltScratch + PS_MAXH]
	push af
	ld a, [wSaltScratch + PS_BLK]
	call ProcRect
	pop af
	ld [wSaltScratch + PS_MAXH], a
	pop af
	ld [wSaltScratch + PS_MAXW], a
	pop af
	ld [wSaltScratch + PS_BLK], a
	pop bc
	dec b
	jr nz, .next
	ret
