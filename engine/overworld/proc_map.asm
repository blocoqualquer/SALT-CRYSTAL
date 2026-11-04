; Procedurally generated world.
;
; The world is 8x8 chunks of 30x27 blocks (240x216 blocks). Every block is a
; pure function of its WORLD position and the seed (the trainer ID), so any
; two chunks agree on their shared edges without storing anything. Terrain:
;  - biomes: a weighted Voronoi diagram (regions of all sizes and shapes)
;  - three layers of random blobs (big, medium, tiny) whose kinds depend on the
;    biome of their centre: lakes, woods, meadows, rocks, flowers...
;  - a few winding roads that cross the world
;  - a coast of sea and mountains around the whole world
; LoadBlockData calls ProcGenMap after the (empty) ROM blocks are copied
; into wOverworldMapBlocks.

DEF PROC_W EQU PROC_TEST_WIDTH
DEF PROC_H EQU PROC_TEST_HEIGHT
DEF PROC_STRIDE EQU PROC_W + 6
DEF PROC_ROWS EQU PROC_H + 6

DEF PROC_GRASS    EQU $02
DEF PROC_TALL     EQU $03
DEF PROC_FLOWERS  EQU $04
DEF PROC_TREE     EQU $05
DEF PROC_PATH     EQU $01
DEF PROC_ROCK     EQU $0a
DEF PROC_WATER    EQU $35

DEF PROC_WORLD    EQU 8 ; chunks per side
DEF PROC_HOME     EQU 4 ; the chunk where the journey starts
DEF NUM_PROC_BIOMES EQU 6
DEF PROC_HOME_U   EQU 134 ; world position of the trailhead (+4 offset)
DEF PROC_HOME_V   EQU 134

; scratch layout (wSaltScratch)
DEF PS_SEED  EQU 0 ; dw
DEF PS_U0    EQU 2 ; world u of buffer column 0
DEF PS_V0    EQU 3
DEF PS_BLK   EQU 4
DEF PS_MODE  EQU 5
DEF PS_A     EQU 6
DEF PS_B     EQU 7
DEF PS_K     EQU 8
DEF PS_CI    EQU 9
DEF PS_CJ    EQU 10
DEF PS_LAYER EQU 11
DEF PS_X     EQU 12
DEF PS_Y     EQU 13
DEF PS_CU    EQU 14
DEF PS_CV    EQU 15
DEF PS_BEST  EQU 16 ; dw
DEF PS_BBIO  EQU 18
DEF PS_QU    EQU 19
DEF PS_QV    EQU 20
DEF PS_DY    EQU 21
DEF PS_ROWS  EQU 22
DEF PS_TMP   EQU 23

; the tail of the block buffer is free: voronoi points, then more scratch
DEF PROC_PTS EQUS "(wOverworldMapBlocks + 1188)"
DEF NUM_PROC_PTS EQU 28 ; 4 columns x 7 rows of 64x32 cells
DEF PX_SHIFT EQUS "(wOverworldMapBlocks + 1272)"
DEF PX_MASK EQUS "(wOverworldMapBlocks + 1273)"
DEF PX_I0 EQUS "(wOverworldMapBlocks + 1274)"
DEF PX_I1 EQUS "(wOverworldMapBlocks + 1275)"
DEF PX_J0 EQUS "(wOverworldMapBlocks + 1276)"
DEF PX_J1 EQUS "(wOverworldMapBlocks + 1277)"
DEF PX_TBL EQUS "(wOverworldMapBlocks + 1278)" ; dw
DEF PX_BIO EQUS "(wOverworldMapBlocks + 1280)"
DEF PX_LANE EQUS "(wOverworldMapBlocks + 1281)"
DEF PX_BASE EQUS "(wOverworldMapBlocks + 1282)"
DEF PX_IDX EQUS "(wOverworldMapBlocks + 1283)"
DEF PX_ROWP EQUS "(wOverworldMapBlocks + 1284)" ; dw
DEF PX_LO EQUS "(wOverworldMapBlocks + 1286)"
DEF PX_HI EQUS "(wOverworldMapBlocks + 1287)"
DEF PX_SIDE EQUS "(wOverworldMapBlocks + 1288)"
DEF PX_POS EQUS "(wOverworldMapBlocks + 1289)"
DEF PX_PREV EQUS "(wOverworldMapBlocks + 1290)"
DEF PX_DEPTH EQUS "(wOverworldMapBlocks + 1291)"
DEF PX_TYPE EQUS "(wOverworldMapBlocks + 1292)"
DEF PX_SALTC EQUS "(wOverworldMapBlocks + 1293)"
DEF PX_SALTD EQUS "(wOverworldMapBlocks + 1294)"
DEF PX_MAXT EQUS "(wOverworldMapBlocks + 1295)"
DEF PX_ROLL EQUS "(wOverworldMapBlocks + 1296)"
DEF PX_DX EQUS "(wOverworldMapBlocks + 1297)"
DEF PX_DY EQUS "(wOverworldMapBlocks + 1298)"

ProcGenMap::
	ld a, [wProcChunkX]
	cp PROC_WORLD
	jr nc, .outside
	ld a, [wProcChunkY]
	cp PROC_WORLD
	jr c, .inside
.outside
	ld hl, wOverworldMapBlocks
	ld bc, PROC_STRIDE * PROC_ROWS
	ld a, PROC_WATER
	jp ByteFill

.inside
; U0 = chunk x * 30 + 1, V0 = chunk y * 27 + 1
	ld a, [wProcChunkX]
	ld c, a
	ld a, 1
	inc c
	jr .u_start
.u_add
	add 30
.u_start
	dec c
	jr nz, .u_add
	ld [wSaltScratch + PS_U0], a
	ld a, [wProcChunkY]
	ld c, a
	ld a, 1
	inc c
	jr .v_start
.v_add
	add 27
.v_start
	dec c
	jr nz, .v_add
	ld [wSaltScratch + PS_V0], a

	call ProcBuildPoints

; everything is grass to begin with
	ld hl, wOverworldMapBlocks
	ld bc, PROC_STRIDE * PROC_ROWS
	ld a, PROC_GRASS
	call ByteFill

; the three blob layers: big (cells of 16), medium (8), tiny (4)
	xor a
.layer
	ld [wSaltScratch + PS_LAYER], a
	call ProcBlobLayer
	ld a, [wSaltScratch + PS_LAYER]
	inc a
	cp 3
	jr nz, .layer

	call ProcRoads
	call ProcHome
	call ProcCoast
	jp ProcRim

ProcHome:
; a clearing with the trailhead at the start chunk
	ld a, [wProcChunkX]
	cp PROC_HOME
	ret nz
	ld a, [wProcChunkY]
	cp PROC_HOME
	ret nz
	ld a, PROC_GRASS
	ld b, 10
	ld c, 21
	ld d, 9
	ld e, 8
	call ProcFillRect
	ld a, PROC_PATH
	ld b, 13
	ld c, 25
	ld d, 2
	ld e, 2
	jp ProcFillRect

ProcFillRect:
; a = block, b = x, c = y (buffer coordinates), d = width, e = height
	ld [wSaltScratch + PS_BLK], a
	ld a, d
	ld [wSaltScratch + PS_TMP], a
.row
	push bc
	ld a, c
	call ProcRowPtr
	pop bc
	ld a, b
	add l
	ld l, a
	jr nc, .nc
	inc h
.nc
	ld a, [wSaltScratch + PS_TMP]
	ld d, a
	ld a, [wSaltScratch + PS_BLK]
.col
	ld [hli], a
	dec d
	jr nz, .col
	inc c
	dec e
	jr nz, .row
	ret

ProcBuildPoints:
; the biome diagram: one point per 64x32 cell of the world
	ld c, 0 ; j
.j
	ld b, 0 ; i
.i
	push bc
	ld d, $a5
	call ProcSeed
; index = j * 4 + i
	pop bc
	push bc
	ld a, c
	add a
	add a
	add b
	ld e, a
	add a
	add e ; * 3
	ld e, a
	ld d, 0
	ld hl, PROC_PTS
	add hl, de
; px = i * 64 + 16 + rand & 31
	pop bc
	push bc
	ld a, b
	swap a
	add a
	add a ; i * 64 (i < 4)
	ld d, a
	call ProcRand
	and $1f
	add 16
	add d
	ld [hli], a
; py = j * 32 + 8 + rand & 15
	pop bc
	push bc
	ld a, c
	swap a
	add a ; j * 32
	ld d, a
	call ProcRand
	and $0f
	add 8
	add d
	ld [hli], a
; weights (3 bits) and biome
	call ProcRand
	and 7
	swap a
	add a ; << 5
	ld d, a
	push de
	ld b, NUM_PROC_BIOMES
	call ProcRandMod
	pop de
	or d
	ld [hl], a
	pop bc
	inc b
	ld a, b
	cp 4
	jr nz, .i
	inc c
	ld a, c
	cp 7
	jr nz, .j
	ret

ProcSeed:
; seed = hash of (b, c, d) and the trainer ID; stirred
	ld a, [wPlayerID]
	xor b
	ld [wSaltScratch + PS_SEED], a
	ld a, b
	swap a
	xor c
	ld e, a
	ld a, [wPlayerID + 1]
	xor e
	xor d
	or 1
	ld [wSaltScratch + PS_SEED + 1], a
	call ProcRand
	call ProcRand
	call ProcRand
	jp ProcRand

ProcHash8:
; a = hash of (b, c, d)
	call ProcSeed
	jp ProcRand

ProcBiomeAt:
; b = world u, c = world v; returns a = biome
	ld a, b
	ld [wSaltScratch + PS_QU], a
	ld a, c
	ld [wSaltScratch + PS_QV], a
; the start clearing is always meadow
	ld a, b
	sub PROC_HOME_U
	jr nc, .ax
	cpl
	inc a
.ax
	cp 30
	jr nc, .search
	ld a, c
	sub PROC_HOME_V
	jr nc, .ay
	cpl
	inc a
.ay
	cp 26
	jr nc, .search
	xor a
	ret
.search
	ld a, $ff
	ld [wSaltScratch + PS_BEST], a
	ld [wSaltScratch + PS_BEST + 1], a
; cell (i0, j0) = (u >> 6, v >> 5); try the 3x3 cells around it
	ld a, [wSaltScratch + PS_QV]
	swap a
	srl a
	and $07
	dec a
	ld c, a ; j
	ld a, 3
	ld [wSaltScratch + PS_DY], a
.jloop
	ld a, c
	cp 7
	jr nc, .jnext
	ld a, [wSaltScratch + PS_QU]
	swap a
	srl a
	srl a
	and 3
	dec a
	ld b, a ; i
	ld a, 3
	ld [wSaltScratch + PS_ROWS], a
.iloop
	ld a, b
	cp 4
	jr nc, .inext
	push bc
	call ProcTryPoint
	pop bc
.inext
	inc b
	ld hl, wSaltScratch + PS_ROWS
	dec [hl]
	jr nz, .iloop
.jnext
	inc c
	ld hl, wSaltScratch + PS_DY
	dec [hl]
	jr nz, .jloop
	ld a, [wSaltScratch + PS_BBIO]
	ret

ProcTryPoint:
; point (b = i, c = j): keeps the nearest in PS_BEST / PS_BBIO
	ld a, c
	add a
	add a
	add b
	ld e, a
	add a
	add e
	ld e, a
	ld d, 0
	ld hl, PROC_PTS
	add hl, de
	ld a, [wSaltScratch + PS_QU]
	sub [hl]
	jr nc, .dx
	cpl
	inc a
.dx
	ld [PX_DX], a
	inc hl
	ld a, [wSaltScratch + PS_QV]
	sub [hl]
	jr nc, .dy
	cpl
	inc a
.dy
	ld [PX_DY], a
	inc hl
	ld a, [hl]
	ld [wSaltScratch + PS_TMP], a ; weights << 5 | biome
	swap a
	srl a
	and 7
	ld hl, .weights
	add l
	ld l, a
	jr nc, .wl
	inc h
.wl
	ld b, [hl] ; ax in the high nibble, ay in the low
; hl = |dx| * ax + |dy| * ay
	ld a, [PX_DX]
	ld l, a
	ld h, 0
	ld a, b
	swap a
	and $0f
	cp 2
	jr c, .x_done
	jr z, .x_two
	ld a, [PX_DX]
	ld e, a
	ld d, 0
	add hl, hl
	add hl, de
	jr .x_done
.x_two
	add hl, hl
.x_done
	ld a, [PX_DY]
	ld e, a
	ld d, 0
	add hl, de
	ld a, b
	and $0f
	cp 2
	jr c, .y_done
	add hl, de
	jr z, .y_done
	add hl, de
.y_done
; keep it if it is smaller than the best so far
	ld a, [wSaltScratch + PS_BEST + 1]
	cp h
	jr c, .nope
	jr nz, .better
	ld a, [wSaltScratch + PS_BEST]
	cp l
	jr c, .nope
	jr z, .nope
.better
	ld a, l
	ld [wSaltScratch + PS_BEST], a
	ld a, h
	ld [wSaltScratch + PS_BEST + 1], a
	ld a, [wSaltScratch + PS_TMP]
	and $1f
	ld [wSaltScratch + PS_BBIO], a
.nope
	ret

.weights
	db $11, $11, $12, $21, $13, $31, $22, $11

ProcBlobLayer:
; one layer of blobs (layer in PS_LAYER)
	ld a, [wSaltScratch + PS_LAYER]
	ld c, a
	add a
	add c ; * 3
	ld c, a
	ld b, 0
	ld hl, .layers
	add hl, bc
	ld a, [hli]
	ld [PX_SHIFT], a
	ld a, [hli]
	ld [PX_TBL], a
	ld a, [hli]
	ld [PX_TBL + 1], a
	ld a, [hl]
	ld [PX_MAXT], a
; mask = (1 << shift) - 1
	ld a, [PX_SHIFT]
	ld b, a
	ld a, 1
.m
	add a
	dec b
	jr nz, .m
	dec a
	ld [PX_MASK], a
; cell window: i from max(0, (U0 >> s) - 2) to min(imax, ((U0 + 35) >> s) + 2)
	ld a, [wSaltScratch + PS_U0]
	call ProcShr
	sub 2
	jr nc, .i0
	xor a
.i0
	ld [PX_I0], a
	ld a, [wSaltScratch + PS_U0]
	add 35
	call ProcShr
	add 2
	ld b, a
	ld a, 247
	call ProcShr
	cp b
	jr nc, .i1ok
	ld b, a
.i1ok
	ld a, b
	ld [PX_I1], a
	ld a, [wSaltScratch + PS_V0]
	call ProcShr
	sub 2
	jr nc, .j0
	xor a
.j0
	ld [PX_J0], a
	ld a, [wSaltScratch + PS_V0]
	add 32
	call ProcShr
	add 2
	ld b, a
	ld a, 223
	call ProcShr
	cp b
	jr nc, .j1ok
	ld b, a
.j1ok
	ld a, b
	ld [PX_J1], a

	ld a, [PX_J0]
	ld [wSaltScratch + PS_CJ], a
.jloop
	ld a, [PX_I0]
	ld [wSaltScratch + PS_CI], a
.iloop
	call ProcCell
	ld hl, wSaltScratch + PS_CI
	inc [hl]
	ld a, [PX_I1]
	cp [hl]
	jr nc, .iloop
	ld hl, wSaltScratch + PS_CJ
	inc [hl]
	ld a, [PX_J1]
	cp [hl]
	jr nc, .jloop
	ret

.layers
	db 4
	dw ProcLayerBig
	db 171
	db 3
	dw ProcLayerMedium
	db 171
	db 2
	dw ProcLayerTiny
	db 101

ProcShr:
; a >>= PX_SHIFT
	push bc
	ld b, a
	ld a, [PX_SHIFT]
	ld c, a
	ld a, b
.s
	srl a
	dec c
	jr nz, .s
	pop bc
	ret

ProcShl:
; a <<= PX_SHIFT
	push bc
	ld b, a
	ld a, [PX_SHIFT]
	ld c, a
	ld a, b
.s
	add a
	dec c
	jr nz, .s
	pop bc
	ret

ProcCell:
; the blob of cell (PS_CI, PS_CJ) in the current layer
	ld a, [wSaltScratch + PS_CI]
	ld b, a
	ld a, [wSaltScratch + PS_CJ]
	ld c, a
	ld a, [wSaltScratch + PS_LAYER]
	swap a
	xor $3c
	ld d, a
	call ProcSeed
; centre
	ld a, [wSaltScratch + PS_CI]
	call ProcShl
	ld b, a
	call ProcRand
	ld c, a
	ld a, [PX_MASK]
	and c
	add b
	ld [wSaltScratch + PS_CU], a
	ld a, [wSaltScratch + PS_CJ]
	call ProcShl
	ld b, a
	call ProcRand
	ld c, a
	ld a, [PX_MASK]
	and c
	add b
	ld [wSaltScratch + PS_CV], a
; most cells grow nothing: roll first and skip without asking the biome
	call ProcRand
	ld [PX_ROLL], a
	ld hl, PX_MAXT
	cp [hl]
	ret nc
; biome at the centre
	ld a, [wSaltScratch + PS_CU]
	ld b, a
	ld a, [wSaltScratch + PS_CV]
	ld c, a
	call ProcBiomeAt
; kind thresholds for this biome
	add a
	add a
	ld hl, PX_TBL
	ld e, [hl]
	inc hl
	ld d, [hl]
	add e
	ld e, a
	jr nc, .t
	inc d
.t
	ld a, [PX_ROLL]
	ld b, a
	ld c, 0
.kind
	ld a, [de]
	inc de
	cp b ; carry when threshold < roll
	jr z, .next_kind
	jr nc, .found
.next_kind
	inc c
	ld a, c
	cp 4
	jr nz, .kind
	ret ; nothing grows here
.found
; kind record: table + 24 + kind * 7
	ld hl, PX_TBL
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, 24
	add hl, de
	ld a, c
	add a
	add a
	add a
	sub c ; * 7
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hli]
	ld [wSaltScratch + PS_BLK], a
	ld a, [hli]
	ld [wSaltScratch + PS_MODE], a
; a = base + rand & mask
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	call ProcRand
	and c
	add b
	ld [wSaltScratch + PS_A], a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	call ProcRand
	and c
	add b
	ld [wSaltScratch + PS_B], a
; corner cut, at most min(a, b)
	ld a, [hl]
	ld c, a
	call ProcRand
	and c
	ld c, a
	ld a, [wSaltScratch + PS_A]
	cp c
	jr nc, .cut_a
	ld c, a
.cut_a
	ld a, [wSaltScratch + PS_B]
	cp c
	jr nc, .cut_b
	ld c, a
.cut_b
; K = a + b - cut
	ld a, [wSaltScratch + PS_A]
	ld b, a
	ld a, [wSaltScratch + PS_B]
	add b
	sub c
	ld [wSaltScratch + PS_K], a
; centre in buffer space, biased by 32: cu + 32 - U0
	ld a, [wSaltScratch + PS_CU]
	ld l, a
	ld h, 0
	ld de, 32
	add hl, de
	ld a, [wSaltScratch + PS_U0]
	ld e, a
	ld d, 0
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	or a
	ret nz
	ld a, l
	cp 82
	ret nc
	ld [wSaltScratch + PS_X], a
	ld a, [wSaltScratch + PS_CV]
	ld l, a
	ld h, 0
	ld de, 32
	add hl, de
	ld a, [wSaltScratch + PS_V0]
	ld e, a
	ld d, 0
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	or a
	ret nz
	ld a, l
	cp 82
	ret nc
	ld [wSaltScratch + PS_Y], a
	jp ProcBlob

ProcBlob:
; paint an octagon: half sizes a, b, corner cut so that |dx| + |dy| <= K
	ld a, [wSaltScratch + PS_B]
	ld c, a
	add a
	inc a
	ld [wSaltScratch + PS_ROWS], a
	ld a, c
	cpl
	inc a
	ld [wSaltScratch + PS_DY], a
.row
	ld a, [wSaltScratch + PS_Y]
	ld b, a
	ld a, [wSaltScratch + PS_DY]
	add b
	cp 32
	jp c, .next_row
	cp 65
	jp nc, .next_row
	sub 32
	call ProcRowPtr
; w = min(a, K - |dy|)
	ld a, [wSaltScratch + PS_DY]
	bit 7, a
	jr z, .pos
	cpl
	inc a
.pos
	ld b, a
	ld a, [wSaltScratch + PS_K]
	sub b
	ld b, a
	ld a, [wSaltScratch + PS_A]
	cp b
	jr nc, .w_ok
	ld b, a
.w_ok
; lo = X - w, hi = X + w, clipped to 32..67
	ld a, [wSaltScratch + PS_X]
	sub b
	jr nc, .lo_pos
	xor a
.lo_pos
	cp 32
	jr nc, .lo_ok
	ld a, 32
.lo_ok
	ld d, a
	ld a, [wSaltScratch + PS_X]
	add b
	cp 68
	jr c, .hi_ok
	ld a, 67
.hi_ok
	cp d
	jr c, .next_row
	sub d
	inc a
	ld b, a ; count
	ld a, d
	sub 32
	add l
	ld l, a
	jr nc, .ptr
	inc h
.ptr
	ld a, [wSaltScratch + PS_BLK]
	ld e, a
	ld a, [wSaltScratch + PS_MODE]
	and a
	jr z, .always
	dec a
	jr z, .grass_only
; never over water
.dry
	ld a, [hl]
	sub $30
	cp $0b
	jr c, .dry_skip
	ld [hl], e
.dry_skip
	inc hl
	dec b
	jr nz, .dry
	jr .next_row
.grass_only
	ld a, [hl]
	cp PROC_GRASS
	jr nz, .grass_skip
	ld [hl], e
.grass_skip
	inc hl
	dec b
	jr nz, .grass_only
	jr .next_row
.always
	ld [hl], e
	inc hl
	dec b
	jr nz, .always
.next_row
	ld hl, wSaltScratch + PS_DY
	inc [hl]
	ld hl, wSaltScratch + PS_ROWS
	dec [hl]
	jp nz, .row
	ret

ProcRoadSeg:
; b = segment, c = lane salt, d = hash salt; returns a = lane base + 0..7
	call ProcHash8
	and 7
	ld hl, PX_BASE
	add [hl]
	ret

ProcRoadCur:
; the road's position in the current segment (PX_POS >> 3)
	ld a, [PX_POS]
	srl a
	srl a
	srl a
	ld b, a
ProcRoadCurB:
	ld a, [PX_LANE]
	ld hl, PX_SALTC
	add [hl]
	ld c, a
	ld a, [PX_SALTD]
	ld d, a
	call ProcRoadSeg
	ld [PX_DEPTH], a
	ret

ProcRoadStep:
; returns b = first, e = last position of the road on this row / column
	ld a, [PX_POS]
	and 7
	jr z, .jog
	ld a, [PX_IDX]
	and a
	jr nz, .single
	call ProcRoadCur
	jr .single
.jog
	call ProcRoadCur
	ld a, [PX_POS]
	srl a
	srl a
	srl a
	dec a
	ld b, a
	ld a, [PX_LANE]
	ld hl, PX_SALTC
	add [hl]
	ld c, a
	ld a, [PX_SALTD]
	ld d, a
	call ProcRoadSeg
	ld e, a
	ld a, [PX_DEPTH]
	cp e
	jr nc, .cur_high
	ld b, a
	ret
.cur_high
	ld b, e
	ld e, a
	ret
.single
	ld a, [PX_DEPTH]
	ld b, a
	ld e, a
	ret

ProcRoads:
; three winding roads across the world, and three across the other way
	ld a, $40
	ld [PX_SALTC], a
	ld a, $3b
	ld [PX_SALTD], a
	xor a
.v_lane
	ld [PX_LANE], a
	ld b, a
	ld c, $11
	ld d, $22
	call ProcHash8
	and $0f
	ld c, a
	ld a, [PX_LANE]
	swap a
	add a
	add a ; lane * 64
	add c
	add 56
	ld [PX_BASE], a
	xor a
.v_row
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_V0
	add [hl]
	ld [PX_POS], a
	call ProcRoadStep
	inc e
	ld a, [PX_IDX]
	ld d, a
	call ProcRoadRow
	ld a, [PX_IDX]
	inc a
	cp PROC_ROWS
	jr nz, .v_row
	ld a, [PX_LANE]
	inc a
	cp 3
	jr nz, .v_lane

	ld a, $50
	ld [PX_SALTC], a
	ld a, $4d
	ld [PX_SALTD], a
	xor a
.h_lane
	ld [PX_LANE], a
	ld b, a
	ld c, $33
	ld d, $44
	call ProcHash8
	and $0f
	ld c, a
	ld a, [PX_LANE]
	ld b, a
	add a
	add a
	add a
	sub b ; lane * 7
	add a
	add a
	add a ; lane * 56
	add c
	add 52
	ld [PX_BASE], a
	xor a
.h_col
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_U0
	add [hl]
	ld [PX_POS], a
	call ProcRoadStep
	inc e
	ld a, [PX_IDX]
	ld d, a
	call ProcRoadCol
	ld a, [PX_IDX]
	inc a
	cp PROC_STRIDE
	jr nz, .h_col
	ld a, [PX_LANE]
	inc a
	cp 3
	jr nz, .h_lane
	ret

ProcRoadRow:
; path on buffer row d, from world u b to world u e (inclusive)
	ld a, [wSaltScratch + PS_U0]
	ld c, a
	ld a, e
	sub c
	ret c
	cp PROC_STRIDE
	jr c, .hi
	ld a, PROC_STRIDE - 1
.hi
	ld e, a
	ld a, b
	sub c
	jr nc, .lo
	xor a
.lo
	cp PROC_STRIDE
	ret nc
	ld b, a
	ld a, e
	sub b
	ret c
	inc a
	ld c, a
	ld a, d
	push bc
	call ProcRowPtr
	pop bc
	ld a, b
	add l
	ld l, a
	jr nc, .p
	inc h
.p
	ld a, PROC_PATH
.fill
	ld [hli], a
	dec c
	jr nz, .fill
	ret

ProcRoadCol:
; path on buffer column d, from world v b to world v e (inclusive)
	ld a, [wSaltScratch + PS_V0]
	ld c, a
	ld a, e
	sub c
	ret c
	cp PROC_ROWS
	jr c, .hi
	ld a, PROC_ROWS - 1
.hi
	ld e, a
	ld a, b
	sub c
	jr nc, .lo
	xor a
.lo
	cp PROC_ROWS
	ret nc
	ld b, a
	ld a, e
	sub b
	ret c
	inc a
	ld c, a
	ld a, b
	push bc
	call ProcRowPtr
	pop bc
	ld a, d
	add l
	ld l, a
	jr nc, .p
	inc h
.p
	ld de, PROC_STRIDE
.fill
	ld [hl], PROC_PATH
	add hl, de
	dec c
	jr nz, .fill
	ret

ProcCoast:
; sea and mountains around the world; only the outer chunks have any.
	ld a, [wProcChunkX]
	and a
	jr z, .sides
	cp PROC_WORLD - 1
	jr nz, .horizontal
.sides
	xor a
.v_row
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_V0
	add [hl]
	ld c, a
	ld a, [wProcChunkX]
	and a
	jr nz, .east
	ld b, 0
	call ProcCoastAt ; a = block, b = depth
	ld c, a
	ld a, b
	add 3 ; world u < 4 + depth
	cp PROC_STRIDE
	jr c, .w_ok
	ld a, PROC_STRIDE
.w_ok
	ld b, a
	ld a, [PX_IDX]
	ld d, a
	ld e, 0
	ld a, c
	call ProcCoastRow
	jr .v_next
.east
	ld a, [PX_IDX]
	ld hl, wSaltScratch + PS_V0
	add [hl]
	ld c, a
	ld b, 1
	call ProcCoastAt
	ld c, a
	ld a, 33
	sub b ; first column = 244 - depth - U0 (U0 = 211)
	ld e, a
	ld a, PROC_STRIDE
	sub e
	ld b, a
	ld a, [PX_IDX]
	ld d, a
	ld a, c
	call ProcCoastRow
.v_next
	ld a, [PX_IDX]
	inc a
	cp PROC_ROWS
	jr nz, .v_row
.horizontal
	ld a, [wProcChunkY]
	and a
	jr z, .tops
	cp PROC_WORLD - 1
	ret nz
.tops
	xor a
.h_col
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_U0
	add [hl]
	ld c, a
	ld a, [wProcChunkY]
	and a
	jr nz, .south
	ld b, 2
	call ProcCoastAt
	ld c, a
	ld a, b
	add 3
	cp PROC_ROWS
	jr c, .n_ok
	ld a, PROC_ROWS
.n_ok
	ld b, a
	ld a, [PX_IDX]
	ld d, a
	ld e, 0
	ld a, c
	call ProcCoastCol
	jr .h_next
.south
	ld a, [PX_IDX]
	ld hl, wSaltScratch + PS_U0
	add [hl]
	ld c, a
	ld b, 3
	call ProcCoastAt
	ld c, a
	ld a, 30
	sub b ; first row = 220 - depth - V0 (V0 = 190)
	ld e, a
	ld a, PROC_ROWS
	sub e
	ld b, a
	ld a, [PX_IDX]
	ld d, a
	ld a, c
	call ProcCoastCol
.h_next
	ld a, [PX_IDX]
	inc a
	cp PROC_STRIDE
	jr nz, .h_col
	ret

ProcCoastAt:
; b = side (0 W, 1 E, 2 N, 3 S), c = position along the side;
; returns a = block (sea or mountain), b = depth
	ld a, b
	ld [PX_SIDE], a
	ld a, c
	ld [PX_POS], a
	srl a
	srl a
	srl a
	srl a
	srl a
	ld c, a
	ld d, $71
	call ProcHash8 ; (side, segment)
	and 7
	cp 3
	ld a, PROC_WATER
	jr nc, .kind
	ld a, PROC_ROCK
.kind
	ld [PX_TYPE], a
; depth from two scales of noise
	ld a, [PX_POS]
	srl a
	srl a
	srl a
	ld c, a
	ld a, [PX_SIDE]
	ld b, a
	ld d, $33
	call ProcHash8
	and 7
	ld [PX_DEPTH], a
	ld a, [PX_POS]
	srl a
	srl a
	ld c, a
	ld a, [PX_SIDE]
	or $10
	ld b, a
	ld d, $35
	call ProcHash8
	ld c, a
	ld a, [PX_TYPE]
	cp PROC_WATER
	ld a, c
	jr nz, .rocky
	and 7
	add 8
	jr .depth
.rocky
	and 3
	add 7
.depth
	ld hl, PX_DEPTH
	add [hl]
	ld b, a
	ld a, [PX_TYPE]
	ret

ProcCoastRow:
; a = block, d = row, e = first column, b = count
	ld c, a
	ld a, b
	and a
	ret z
	push bc
	ld a, d
	call ProcRowPtr
	pop bc
	ld a, e
	add l
	ld l, a
	jr nc, .p
	inc h
.p
.fill
	ld [hl], c
	inc hl
	dec b
	jr nz, .fill
	ret

ProcCoastCol:
; a = block, d = column, e = first row, b = count
	ld c, a
	ld a, b
	and a
	ret z
	push bc
	ld a, e
	call ProcRowPtr
	pop bc
	ld a, d
	add l
	ld l, a
	jr nc, .p
	inc h
.p
	ld de, PROC_STRIDE
.fill
	ld [hl], c
	add hl, de
	dec b
	jr nz, .fill
	ret

ProcRim:
; water next to land gets the rocky shore blocks
	ld hl, wOverworldMapBlocks
	ld c, 0
.row
	ld b, 0
.col
	ld a, [hl]
	sub $30
	cp $0b
	jr nc, .next
	ld d, 0
	ld a, c
	and a
	jr z, .no_up
	push hl
	ld a, l
	sub PROC_STRIDE
	ld l, a
	jr nc, .u
	dec h
.u
	ld a, [hl]
	pop hl
	sub $30
	cp $0b
	jr c, .no_up
	set 0, d
.no_up
	ld a, c
	cp PROC_ROWS - 1
	jr z, .no_down
	push hl
	ld a, l
	add PROC_STRIDE
	ld l, a
	jr nc, .dn
	inc h
.dn
	ld a, [hl]
	pop hl
	sub $30
	cp $0b
	jr c, .no_down
	set 1, d
.no_down
	ld a, b
	and a
	jr z, .no_left
	dec hl
	ld a, [hl]
	inc hl
	sub $30
	cp $0b
	jr c, .no_left
	set 2, d
.no_left
	ld a, b
	cp PROC_STRIDE - 1
	jr z, .no_right
	inc hl
	ld a, [hl]
	dec hl
	sub $30
	cp $0b
	jr c, .no_right
	set 3, d
.no_right
	push hl
	ld e, d
	ld d, 0
	ld hl, ProcRimBlocks
	add hl, de
	ld a, [hl]
	pop hl
	ld [hl], a
.next
	inc hl
	inc b
	ld a, b
	cp PROC_STRIDE
	jr nz, .col
	inc c
	ld a, c
	cp PROC_ROWS
	jr nz, .row
	ret

ProcRimBlocks:
; index: up land = 1, down = 2, left = 4, right = 8
	db $35, $31, $39, $35
	db $34, $30, $38, $34
	db $36, $32, $3a, $36
	db $35, $31, $39, $35

; Blob layers: 6 biomes x 4 cumulative odds (out of 256) for the 4 kinds,
; then 4 kinds of: block, mode (0 always, 1 only on grass, 2 never on water),
; a base, a mask, b base, b mask, corner-cut mask.
; biomes: meadow, forest, lakes, tall grass, flowers, mountains
ProcLayerBig:
	db 10, 30, 60, 60
	db  4, 150, 160, 160
	db 130, 150, 160, 160
	db  4, 14, 140, 140
	db  4, 14, 100, 100
	db  4, 24, 40, 170
	db PROC_WATER,  0, 3, 7, 3, 3, 7 ; lake
	db PROC_TREE,   2, 3, 7, 3, 7, 7 ; big wood
	db PROC_TALL,   2, 3, 7, 3, 7, 7 ; tall grass field
	db PROC_ROCK,   2, 2, 7, 2, 7, 7 ; rocky mass

ProcLayerMedium:
	db 30, 90, 110, 110
	db 10, 20, 120, 120
	db 20, 30, 80, 80
	db 120, 130, 150, 150
	db 20, 150, 170, 170
	db 10, 15, 45, 130
	db PROC_TALL,    1, 1, 3, 1, 3, 3
	db PROC_FLOWERS, 1, 1, 3, 0, 3, 3
	db PROC_TREE,    1, 1, 3, 1, 3, 3
	db PROC_ROCK,    1, 0, 3, 0, 1, 1

ProcLayerTiny:
	db 15, 50, 70, 70
	db 4, 10, 70, 70
	db 10, 20, 40, 40
	db 60, 70, 80, 80
	db 10, 90, 100, 100
	db 5, 8, 20, 90
	db PROC_TREE,    1, 0, 1, 0, 0, 0
	db PROC_FLOWERS, 1, 0, 1, 0, 1, 0
	db PROC_TALL,    1, 0, 1, 0, 1, 0
	db PROC_ROCK,    1, 0, 1, 0, 0, 0

ProcRand:
; xorshift16 (7, 9, 8) on the seed; returns a random byte in a
	push de
	push hl
	ld hl, wSaltScratch + PS_SEED
	ld e, [hl]
	inc hl
	ld d, [hl]
; x ^= x << 7
	ld a, e
	srl a
	ld h, a
	ld a, 0
	rra
	ld l, a
	ld a, d
	rrca
	and $80
	or h
	xor d
	ld d, a
	ld a, e
	xor l
	ld e, a
; x ^= x >> 9
	ld a, d
	srl a
	xor e
	ld e, a
; x ^= x << 8
	xor d
	ld d, a
	ld hl, wSaltScratch + PS_SEED
	ld [hl], e
	inc hl
	ld [hl], d
	ld a, d
	pop hl
	pop de
	ret

ProcRandMod:
; a = random number in [0, b)
	call ProcRand
.loop
	cp b
	ret c
	sub b
	jr .loop


ProcRowPtr:
; hl = start of buffer row a (a * 36 + buffer); keeps bc, de
	push de
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl ; * 4
	ld d, h
	ld e, l
	add hl, hl
	add hl, hl
	add hl, hl ; * 32
	add hl, de ; * 36
	ld de, wOverworldMapBlocks
	add hl, de
	pop de
	ret
