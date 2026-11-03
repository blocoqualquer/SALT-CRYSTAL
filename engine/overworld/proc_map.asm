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
DEF PS_BIOME EQU 12
DEF PS_GN    EQU 13 ; gap positions in the walls: north, south (x), west, east (y)
DEF PS_GS    EQU 14
DEF PS_GW    EQU 15
DEF PS_GE    EQU 16
DEF PS_SN    EQU 17 ; wall styles: 0 trees, 1 open grass
DEF PS_SS    EQU 18
DEF PS_SW    EQU 19
DEF PS_SE    EQU 20
DEF PS_J     EQU 21 ; where the roads jog
DEF PS_K     EQU 22

DEF NUM_PROC_BIOMES EQU 5

ProcGenMap::
; Called from LoadBlockData (after the connection strips are in place).
;
; The 3 outermost blocks on every side of a chunk are the "wall": trees (or
; open grass) with a 2-wide road gap. Its shape depends only on the edge
; shared with the neighbour, so the strip we draw for the neighbour is what
; the neighbour really has, and ordinary map connections work.
	ld a, [wProcChunkY]
	dec a
	ld c, a
	ld a, [wProcChunkX]
	ld b, a
	ld d, 0
	call ProcEdge
	ld [wSaltScratch + PS_GN], a
	ld a, b
	ld [wSaltScratch + PS_SN], a
	ld a, [wProcChunkY]
	ld c, a
	ld a, [wProcChunkX]
	ld b, a
	ld d, 0
	call ProcEdge
	ld [wSaltScratch + PS_GS], a
	ld a, b
	ld [wSaltScratch + PS_SS], a
	ld a, [wProcChunkY]
	ld c, a
	ld a, [wProcChunkX]
	dec a
	ld b, a
	ld d, 1
	call ProcEdge
	ld [wSaltScratch + PS_GW], a
	ld a, b
	ld [wSaltScratch + PS_SW], a
	ld a, [wProcChunkY]
	ld c, a
	ld a, [wProcChunkX]
	ld b, a
	ld d, 1
	call ProcEdge
	ld [wSaltScratch + PS_GE], a
	ld a, b
	ld [wSaltScratch + PS_SE], a

; seed for the inside of the chunk
	ld a, [wPlayerID]
	ld hl, wProcChunkX
	xor [hl]
	xor $5c
	ld [wSaltScratch + PS_SEED], a
	ld a, [wPlayerID + 1]
	ld hl, wProcChunkY
	xor [hl]
	xor $c3
	or $01 ; never zero
	ld [wSaltScratch + PS_SEED + 1], a
	ld b, 12
.stir
	call ProcRand
	dec b
	jr nz, .stir
; the biome of this chunk (the first one is always a gentle meadow)
	ld b, NUM_PROC_BIOMES
	call ProcRandMod
	ld b, a
	ld a, [wProcChunkX]
	ld hl, wProcChunkY
	or [hl]
	ld a, b
	jr nz, .got_biome
	xor a
.got_biome
	ld [wSaltScratch + PS_BIOME], a
; where the roads jog
	ld b, 14
	call ProcRandMod
	add 6
	ld [wSaltScratch + PS_J], a
	ld b, 12
	call ProcRandMod
	add 8
	ld [wSaltScratch + PS_K], a

; everything starts as forest, the chunk itself as grass
	ld hl, wOverworldMapBlocks
	ld bc, PROC_STRIDE * (PROC_H + 6)
	ld a, PROC_TREE
	call ByteFill
	ld a, PROC_GRASS
	ld b, 0
	ld c, 0
	ld d, PROC_W
	ld e, PROC_H
	call ProcRect
; patches of tall grass, flowers, ponds and woods, as the biome wants
	ld a, [wSaltScratch + PS_BIOME]
	ld hl, ProcBiomes
	ld bc, 12
	call AddNTimes
	ld a, PROC_TALL
	call ProcBiomeScatter
	ld a, PROC_FLOWERS
	call ProcBiomeScatter
	ld a, PROC_WATER
	call ProcBiomeScatter
	ld a, PROC_TREE
	call ProcBiomeScatter

; corners are always trees
	ld a, PROC_TREE
	ld b, -3
	ld c, -3
	ld d, 6
	ld e, 6
	call ProcRect
	ld a, PROC_TREE
	ld b, PROC_W - 3
	ld c, -3
	ld d, 6
	ld e, 6
	call ProcRect
	ld a, PROC_TREE
	ld b, -3
	ld c, PROC_H - 3
	ld d, 6
	ld e, 6
	call ProcRect
	ld a, PROC_TREE
	ld b, PROC_W - 3
	ld c, PROC_H - 3
	ld d, 6
	ld e, 6
	call ProcRect
; the four walls (trees or open grass)
	ld a, [wSaltScratch + PS_SN]
	call ProcWallBlock
	ld b, 3
	ld c, -3
	ld d, PROC_W - 6
	ld e, 6
	call ProcRect
	ld a, [wSaltScratch + PS_SS]
	call ProcWallBlock
	ld b, 3
	ld c, PROC_H - 3
	ld d, PROC_W - 6
	ld e, 6
	call ProcRect
	ld a, [wSaltScratch + PS_SW]
	call ProcWallBlock
	ld b, -3
	ld c, 3
	ld d, 6
	ld e, PROC_H - 6
	call ProcRect
	ld a, [wSaltScratch + PS_SE]
	call ProcWallBlock
	ld b, PROC_W - 3
	ld c, 3
	ld d, 6
	ld e, PROC_H - 6
	call ProcRect
; road gaps through the walls
	ld a, [wSaltScratch + PS_GN]
	ld b, a
	ld a, PROC_PATH
	ld c, -3
	ld d, 2
	ld e, 6
	call ProcRect
	ld a, [wSaltScratch + PS_GS]
	ld b, a
	ld a, PROC_PATH
	ld c, PROC_H - 3
	ld d, 2
	ld e, 6
	call ProcRect
	ld a, [wSaltScratch + PS_GW]
	ld c, a
	ld a, PROC_PATH
	ld b, -3
	ld d, 6
	ld e, 2
	call ProcRect
	ld a, [wSaltScratch + PS_GE]
	ld c, a
	ld a, PROC_PATH
	ld b, PROC_W - 3
	ld d, 6
	ld e, 2
	call ProcRect

; north-south road: down from the north gap to a random row, a sideways
; jog, then down to the south gap
	ld a, [wSaltScratch + PS_J]
	sub 1
	ld e, a ; rows 3 .. J+1
	ld a, [wSaltScratch + PS_GN]
	ld b, a
	ld c, 3
	ld d, 2
	ld a, PROC_PATH
	call ProcRect
	ld a, [wSaltScratch + PS_GN]
	ld b, a
	ld a, [wSaltScratch + PS_GS]
	call ProcMinSpan
	ld d, b ; width
	ld b, a ; x
	ld a, [wSaltScratch + PS_J]
	ld c, a
	ld e, 2
	ld a, PROC_PATH
	call ProcRect
	ld a, [wSaltScratch + PS_J]
	ld b, a
	ld a, PROC_H - 3
	sub b
	ld e, a
	ld a, b
	ld c, a
	ld a, [wSaltScratch + PS_GS]
	ld b, a
	ld d, 2
	ld a, PROC_PATH
	call ProcRect
; east-west road, the same idea
	ld a, [wSaltScratch + PS_K]
	sub 1
	ld d, a ; columns 3 .. K+1
	ld a, [wSaltScratch + PS_GW]
	ld c, a
	ld b, 3
	ld e, 2
	ld a, PROC_PATH
	call ProcRect
	ld a, [wSaltScratch + PS_GW]
	ld b, a
	ld a, [wSaltScratch + PS_GE]
	call ProcMinSpan
	ld e, b ; height
	ld c, a ; y
	ld a, [wSaltScratch + PS_K]
	ld b, a
	ld d, 2
	ld a, PROC_PATH
	call ProcRect
	ld a, [wSaltScratch + PS_K]
	ld b, a
	ld a, PROC_W - 3
	sub b
	ld d, a
	ld a, [wSaltScratch + PS_GE]
	ld c, a
	ld e, 2
	ld a, PROC_PATH
	call ProcRect
; the first chunk has a trailhead: the way back to town
	ld a, [wProcChunkX]
	ld hl, wProcChunkY
	or [hl]
	ret nz
	ld a, PROC_PATH
	ld b, 10
	ld c, 22
	ld d, 2
	ld e, 2
	jp ProcRect

ProcWallBlock:
; a = wall style (0 trees, 1 grass) -> a = block
	and a
	ld a, PROC_TREE
	ret z
	ld a, PROC_GRASS
	ret

ProcMinSpan:
; a, b = two positions -> a = the smaller, b = their distance + 2
	cp b
	jr c, .a_smaller
	sub b
	add 2
	ld c, a
	ld a, b
	ld b, c
	ret
.a_smaller
	ld c, a
	ld a, b
	sub c
	add 2
	ld b, a
	ld a, c
	ret

ProcEdge:
; The shared edge of two chunks. b, c = chunk x, y; d = 0 for the edge on
; its south side, 1 for the one on its east side.
; Returns a = where the road gap is, b = wall style (0 trees, 1 open).
	push bc
	ld a, d
	and a
	ld e, $00
	jr z, .lo
	ld e, $e1
.lo
	ld a, [wPlayerID]
	xor e
	xor b
	xor $a5
	or $01
	ld [wSaltScratch + PS_SEED], a
	ld a, d
	and a
	ld e, $00
	jr z, .hi
	ld e, $17
.hi
	ld a, [wPlayerID + 1]
	xor e
	xor c
	xor $3c
	ld [wSaltScratch + PS_SEED + 1], a
	ld b, 8
.stir
	call ProcRand
	dec b
	jr nz, .stir
	ld a, d
	and a
	ld b, PROC_W - 9
	jr z, .range
	ld b, PROC_H - 9
.range
	call ProcRandMod
	add 4
	ld e, a ; gap
	call ProcRand
	and 3
	ld a, 0
	jr nz, .wall
	inc a
.wall
	ld h, a ; style
	pop bc
; the way home starts in the first chunk: keep its south gap in a known spot
	ld a, d
	and a
	jr nz, .done
	ld a, b
	or c
	jr nz, .done
	ld e, 14
	ld h, 0
.done
	ld a, e
	ld b, h
	ret

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
; a = block, d = x, e = y (blocks, -3..PROC_W+2); clips to the padded buffer
	push bc
	push de
	push hl
	push af
	ld a, d
	add 3
	cp PROC_STRIDE
	jr nc, .skip
	ld d, a
	ld a, e
	add 3
	cp PROC_H + 6
	jr nc, .skip
	ld hl, wOverworldMapBlocks
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

ProcBiomeScatter:
; hl -> count, max width, max height of one kind of patch (block in a)
	ld b, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld e, [hl]
	inc hl
	push hl
	call ProcScatter
	pop hl
	ret

ProcBiomes:
; per biome: tall grass, flowers, water, trees (count, max w, max h)
	; 0 meadow
	db 14, 5, 3,  24, 2, 2,   1, 3, 2,   8, 2, 2
	; 1 forest
	db  6, 3, 3,   4, 1, 1,   1, 2, 2,  70, 4, 4
	; 2 lakes
	db 10, 4, 3,   6, 2, 2,   9, 6, 4,  14, 3, 3
	; 3 tall grass
	db 60, 7, 5,   8, 2, 2,   1, 3, 2,   8, 3, 3
	; 4 flower field
	db  6, 3, 2,  60, 3, 3,   2, 3, 2,   6, 2, 2
