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
DEF PS_BIOME EQU 12

DEF NUM_PROC_BIOMES EQU 5

ProcGenMap::
; Called from LoadBlockData (after the connection strips are in place).
; Seed = trainer ID mixed with this chunk's coordinates, so every chunk of
; the world is always the same without storing anything.
	ld a, [wPlayerID]
	ld hl, wProcChunkX
	xor [hl]
	xor $a5
	ld [wSaltScratch + PS_SEED], a
	ld a, [wPlayerID + 1]
	ld hl, wProcChunkY
	xor [hl]
	xor $3c
	or $01 ; never zero
	ld [wSaltScratch + PS_SEED + 1], a
	ld b, 12 ; neighbouring chunks differ by a bit: stir them up
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

; the whole buffer (padding included) starts as forest
	ld hl, wOverworldMapBlocks
	ld bc, PROC_STRIDE * (PROC_H + 6)
	ld a, PROC_TREE
	call ByteFill
; clearing
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
; walls of trees around the chunk, and over the strips the neighbours see
	ld a, PROC_TREE
	ld b, -3
	ld c, -3
	ld d, PROC_W + 6
	ld e, 4
	call ProcRect
	ld a, PROC_TREE
	ld b, -3
	ld c, PROC_H - 1
	ld d, PROC_W + 6
	ld e, 4
	call ProcRect
	ld a, PROC_TREE
	ld b, -3
	ld c, 0
	ld d, 4
	ld e, PROC_H
	call ProcRect
	ld a, PROC_TREE
	ld b, PROC_W - 1
	ld c, 0
	ld d, 4
	ld e, PROC_H
	call ProcRect
; entrance clearing
	ld a, PROC_GRASS
	ld b, 12
	ld c, PROC_H - 5
	ld d, 6
	ld e, 4
	call ProcRect
; east-west road, through the walls into the neighbours' strips
	ld a, PROC_PATH
	ld b, -3
	ld c, 13
	ld d, PROC_W + 6
	ld e, 2
	call ProcRect
; north-south gaps in the walls (same place in every chunk)
	ld a, PROC_PATH
	ld b, 14
	ld c, PROC_H - 1
	ld d, 2
	ld e, 4
	call ProcRect
	ld a, PROC_PATH
	ld b, 14
	ld c, -3
	ld d, 2
	ld e, 4
	call ProcRect
; winding north-south path
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
	call ProcRect
	pop bc
	ld a, c
	cp 22
	jr nc, .next_row
	cp 16
	jr nc, .wander
	cp 15
	jr z, .snap
	cp 12
	jr nc, .next_row
	cp 5
	jr nc, .wander
	cp 4
	jr z, .snap
	jr .next_row

.snap
; rejoin the middle column (x = 14) with a horizontal piece
	ld a, [wSaltScratch + PS_PX]
	cp 14
	jr z, .next_row
	jr c, .snap_right
	ld b, 14
	sub 14
	jr .snap_draw
.snap_right
	ld b, a
	ld a, 14
	sub b
.snap_draw
	add 2
	ld d, a
	push bc
	ld a, PROC_PATH
	ld e, 1
	call ProcRect
	pop bc
	ld a, 14
	ld [wSaltScratch + PS_PX], a
	jr .next_row

.wander
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
	ld d, a
	ld a, b
	and a
	ld a, d
	jr z, .go_left
	cp 17
	jr nc, .next_row
	inc a
	jr .shifted
.go_left
	cp 12
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
.next_row
	ld a, c
	and a
	ret z
	dec c
	jp .path_row

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

SaltEdgeCheck::
; Called when the player walks off the edge of a map (EdgeWarpScript).
; Inside a procedural chunk the next chunk is generated by a warp into the
; same map at the opposite edge. Sets wScriptVar to 1 when it did that.
	xor a
	ld [wScriptVar], a
	ld a, [wMapGroup]
	cp GROUP_PROC_TEST
	ret nz
	ld a, [wMapNumber]
	cp MAP_PROC_TEST
	ret nz
	ld a, [wPlayerStepDirection]
	and a ; DOWN
	jr z, .down
	cp UP
	jr z, .up
	cp LEFT
	jr z, .left
; RIGHT
	ld hl, wProcChunkX
	inc [hl]
	xor a
	ld [wXCoord], a
	jr .go
.left
	ld hl, wProcChunkX
	dec [hl]
	ld a, PROC_W * 2 - 1
	ld [wXCoord], a
	jr .go
.up
	ld hl, wProcChunkY
	dec [hl]
	ld a, PROC_H * 2 - 1
	ld [wYCoord], a
	jr .go
.down
	ld hl, wProcChunkY
	inc [hl]
	xor a
	ld [wYCoord], a
.go
	ld a, SPAWN_N_A
	ld [wDefaultSpawnpoint], a
	ld a, MAPSETUP_WARP
	ldh [hMapEntryMethod], a
	ld a, MAPSTATUS_ENTER
	call LoadMapStatus
	ld a, 1
	ld [wScriptVar], a
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
