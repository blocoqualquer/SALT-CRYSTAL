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
DEF PROC_PATH     EQU $71 ; packed brown earth for roads
DEF PROC_SAND     EQU $01 ; pale speckled ground
DEF PROC_ROCK     EQU $0a
DEF PROC_WATER    EQU $35

DEF PROC_WORLD    EQU 8 ; chunks per side
DEF PROC_HOME     EQU 4 ; the chunk where the journey starts
DEF NUM_PROC_BIOMES EQU 9
DEF PROC_SNOW     EQU $00 ; plain pale ground
DEF PROC_HOME_U   EQU 134 ; world position of the trailhead (+4 offset)
DEF PROC_HOME_V   EQU 134
DEF PROC_ISLE_U   EQU 123 ; centre of the island (world u, v)
DEF PROC_ISLE_V   EQU 111
DEF PROC_ISLE_CORE EQU 40 ; certain land within this distance
DEF PROC_ISLE_SPAN EQU 85 ; beyond core + span there is only sea

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
DEF PX_NU EQUS "(wOverworldMapBlocks + 1188)"
DEF PX_NV EQUS "(wOverworldMapBlocks + 1189)"
DEF PX_TU EQUS "(wOverworldMapBlocks + 1190)"
DEF PX_TV EQUS "(wOverworldMapBlocks + 1191)"
DEF PX_N00 EQUS "(wOverworldMapBlocks + 1192)"
DEF PX_N10 EQUS "(wOverworldMapBlocks + 1193)"
DEF PX_N01 EQUS "(wOverworldMapBlocks + 1194)"
DEF PX_N11 EQUS "(wOverworldMapBlocks + 1195)"
DEF PX_NSH EQUS "(wOverworldMapBlocks + 1196)"
DEF PX_NSALT EQUS "(wOverworldMapBlocks + 1197)"
DEF PX_NMASK EQUS "(wOverworldMapBlocks + 1198)"
DEF PX_BT EQUS "(wOverworldMapBlocks + 1200)"
DEF PX_ELEV EQUS "(wOverworldMapBlocks + 1199)"
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
DEF PX_LX0 EQUS "(wOverworldMapBlocks + 1284)"
DEF PX_LY0 EQUS "(wOverworldMapBlocks + 1285)"
DEF PX_LA0 EQUS "(wOverworldMapBlocks + 1286)"
DEF PX_LB0 EQUS "(wOverworldMapBlocks + 1287)"
DEF PX_LCNT EQUS "(wOverworldMapBlocks + 1290)"
DEF PX_BKU EQUS "(wOverworldMapBlocks + 1281)"
DEF PX_BKV EQUS "(wOverworldMapBlocks + 1282)"
DEF PX_BKB EQUS "(wOverworldMapBlocks + 1283)"
DEF PX_PB EQUS "(wOverworldMapBlocks + 1284)"
DEF PX_PE EQUS "(wOverworldMapBlocks + 1285)"
DEF PX_C3 EQUS "(wOverworldMapBlocks + 1278)"
DEF PX_C1 EQUS "(wOverworldMapBlocks + 1272)"
DEF PX_C2 EQUS "(wOverworldMapBlocks + 1275)"

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


; everything is sea to begin with; the island is built from land blobs
	ld hl, wOverworldMapBlocks
	ld bc, PROC_STRIDE * PROC_ROWS
	ld a, PROC_WATER
	call ByteFill
	call ProcWorldEnsure
	ld a, BANK(sMacroMap)
	call OpenSRAM
	call ProcLand
	ld hl, PX_BT
	ld bc, 64
	ld a, $ff
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

	call ProcRidges
	call ProcRoads
	call ProcHome
	call ProcRim
	jp CloseSRAM


DEF V_PL EQUS "(PX_BT + 32)"
DEF V_PH EQUS "(PX_BT + 33)"
DEF V_I  EQUS "(PX_BT + 34)"
DEF V_J  EQUS "(PX_BT + 35)"
DEF V_T  EQUS "(PX_BT + 36)"
DEF V_C  EQUS "(PX_BT + 37)"
DEF V_FX EQUS "(PX_BT + 38)"
DEF V_H  EQUS "(PX_BT + 39)"
DEF V_IC EQUS "(PX_BT + 40)"
DEF PROC_SEA_LEVEL EQU 128

ProcWorldEnsure:
; makes the world map if this game does not have one yet
	ld a, BANK(sMacroMagic)
	call OpenSRAM
	ld a, [sMacroMagic]
	cp $a7
	jr nz, .make
	ld a, [wPlayerID]
	ld b, a
	ld a, [sMacroSeed]
	cp b
	jr nz, .make
	ld a, [wPlayerID + 1]
	ld b, a
	ld a, [sMacroSeed + 1]
	cp b
	jr z, .done
.make
	call ProcWorldGen
	ld a, [wPlayerID]
	ld [sMacroSeed], a
	ld a, [wPlayerID + 1]
	ld [sMacroSeed + 1], a
	ld a, $a7
	ld [sMacroMagic], a
.done
	jp CloseSRAM

ProcWorldGen:
; height at every 8th block (32 x 29 points): noise plus an island-shaped mask
	ld hl, sMacroMap
	ld a, l
	ld [V_PL], a
	ld a, h
	ld [V_PH], a
	xor a
	ld [V_J], a
.row
	xor a
	ld [V_I], a
.col
	ld a, [V_I]
	cp 3
	jp c, .edge
	cp 29
	jp nc, .edge
	ld a, [V_J]
	cp 3
	jp c, .edge
	cp 26
	jp nc, .edge
	ld a, [V_I]
	add a
	add a
	add a
	add 4
	ld [wSaltScratch + PS_QU], a
	ld a, [V_J]
	add a
	add a
	add a
	add 4
	ld [wSaltScratch + PS_QV], a
; three octaves of noise
	ld a, 6
	ld [PX_NSH], a
	ld a, $30
	ld [PX_NSALT], a
	call ProcNoise
	srl a
	ld [V_T], a
	ld a, 5
	ld [PX_NSH], a
	ld a, $31
	ld [PX_NSALT], a
	call ProcNoise
	srl a
	srl a
	ld hl, V_T
	add [hl]
	ld [hl], a
	ld a, 4
	ld [PX_NSH], a
	ld a, $32
	ld [PX_NSALT], a
	call ProcNoise
	srl a
	srl a
	ld hl, V_T
	add [hl]
	ld [hl], a
; island mask: 255 - 2 * distance to the centre
	ld a, [wSaltScratch + PS_QV]
	ld c, a
	ld a, [wSaltScratch + PS_QU]
	call ProcIsleDist
	ld c, a
	srl a
	add c ; 1.5 * distance
	jr c, .nomask
	cpl
	jr .mask
.nomask
	xor a
.mask
; h = 5/8 noise + 3/8 mask
	ld c, a
	srl a
	srl a
	ld b, a
	ld a, c
	srl a
	srl a
	srl a
	add b
	ld b, a
	ld a, [V_T]
	ld c, a
	srl a
	ld d, a
	ld a, c
	srl a
	srl a
	srl a
	add d
	add b
	jr .store
.edge
	xor a
.store
	ld hl, V_PL
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld h, b
	ld l, c
	ld [hli], a
	ld a, l
	ld [V_PL], a
	ld a, h
	ld [V_PH], a
	ld a, [V_I]
	inc a
	ld [V_I], a
	cp 32
	jp nz, .col
	ld a, [V_J]
	inc a
	ld [V_J], a
	cp 29
	jp nz, .row
	ret

ProcMul8:
; a = x, c = f (0..7); returns a = x * f / 8
	ld e, a
	ld d, 0
	ld hl, 0
	bit 0, c
	jr z, .b1
	add hl, de
.b1
	sla e
	rl d
	bit 1, c
	jr z, .b2
	add hl, de
.b2
	sla e
	rl d
	bit 2, c
	jr z, .b3
	add hl, de
.b3
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	ret

ProcMix:
; b = p, a = q, c = f (0..7); returns a = p + (q - p) * f / 8
	cp b
	jr c, .down
	sub b
	push bc
	call ProcMul8
	pop bc
	add b
	ret
.down
	cpl
	inc a
	add b ; p - q
	push bc
	call ProcMul8
	pop bc
	cpl
	inc a
	add b
	ret

ProcLand:
; land is wherever the world map is high enough (blended between its points)
	ld hl, wOverworldMapBlocks
	ld a, l
	ld [V_PL], a
	ld a, h
	ld [V_PH], a
	xor a
	ld [V_I], a
.row
	ld a, [wSaltScratch + PS_V0]
	ld b, a
	ld a, [V_I]
	add b
	cp 4
	jp c, .next_row
	sub 4
	ld b, a
	and 7
	ld [V_T], a
	ld a, b
	srl a
	srl a
	srl a
	cp 28
	jp nc, .next_row
	ld [V_J], a
; the row of points blended vertically
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, sMacroMap
	add hl, de
	ld de, PX_BT
	ld b, 32
.vert
	push bc
	push hl
	push de
	ld a, [hl]
	ld b, a
	ld de, 32
	add hl, de
	ld a, [hl]
	ld a, [V_T]
	ld c, a
	ld a, [hl]
	call ProcMix
	pop de
	ld [de], a
	inc de
	pop hl
	inc hl
	pop bc
	dec b
	jr nz, .vert
	xor a
	ld [V_C], a
.col
	ld a, [wSaltScratch + PS_U0]
	ld b, a
	ld a, [V_C]
	add b
	cp 4
	jp c, .skip
	sub 4
	ld b, a
	and 7
	ld [V_FX], a
	ld a, b
	srl a
	srl a
	srl a
	ld e, a
	ld d, 0
	ld hl, PX_BT
	add hl, de
	ld a, [hli]
	ld b, a
	ld d, [hl]
	ld a, [V_FX]
	ld c, a
	ld a, d
	call ProcMix
	ld [V_H], a
; a little roughness from the permutation table
	ld a, [wSaltScratch + PS_U0]
	ld b, a
	ld a, [V_C]
	add b
	ld e, a
	ld d, 0
	ld hl, ProcPerm
	add hl, de
	ld a, [hl]
	ld b, a
	ld a, [wSaltScratch + PS_V0]
	ld c, a
	ld a, [V_I]
	add c
	add b
	ld e, a
	ld d, 0
	ld hl, ProcPerm
	add hl, de
	ld a, [hl]
	and 3
	ld hl, V_H
	add [hl]
	jr c, .land
	cp PROC_SEA_LEVEL + 2
	jr c, .skip
.land
	ld hl, V_PL
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, [V_C]
	ld e, a
	ld d, 0
	add hl, de
	ld [hl], PROC_GRASS
.skip
	ld a, [V_C]
	inc a
	ld [V_C], a
	cp PROC_STRIDE
	jp nz, .col
.next_row
	ld a, [V_PL]
	ld l, a
	ld a, [V_PH]
	ld h, a
	ld de, PROC_STRIDE
	add hl, de
	ld a, l
	ld [V_PL], a
	ld a, h
	ld [V_PH], a
	ld a, [V_I]
	inc a
	ld [V_I], a
	cp PROC_ROWS
	jp nz, .row
	ret

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
	jp ProcRand

ProcHash8:
; a = hash of (b, c, d)
	call ProcSeed
	jp ProcRand

ProcBiomeCoarse:
; b = world u, c = world v; returns a = biome of the 8x8 square they are in.
; Remembered in a small table of the squares around this chunk.
	ld a, b
	srl a
	srl a
	srl a
	ld b, a
	ld a, c
	srl a
	srl a
	srl a
	ld c, a
	ld a, [wSaltScratch + PS_U0]
	srl a
	srl a
	srl a
	ld d, a
	ld a, b
	sub d
	inc a
	ld d, a ; column in the table
	cp 8
	jr nc, .compute
	ld a, [wSaltScratch + PS_V0]
	srl a
	srl a
	srl a
	ld e, a
	ld a, c
	sub e
	inc a
	cp 8
	jr nc, .compute
	add a
	add a
	add a
	add d
	ld l, a
	ld h, 0
	ld de, PX_BT
	add hl, de
	ld a, [hl]
	cp $ff
	ret nz
	push hl
	call .compute
	pop hl
	ld [hl], a
	ret
.compute
	ld a, b
	add a
	add a
	add a
	add 4
	ld b, a
	ld a, c
	add a
	add a
	add a
	add 4
	ld c, a

ProcBiomeAt:
; b = world u, c = world v; returns a = biome, from elevation and moisture
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
	jr nc, .terrain
	ld a, c
	sub PROC_HOME_V
	jr nc, .ay
	cpl
	inc a
.ay
	cp 26
	jr nc, .terrain
	xor a
	ret
.terrain
; elevation: the height of the world map under this square
	ld a, [wSaltScratch + PS_QV]
	srl a
	srl a
	srl a
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, [wSaltScratch + PS_QU]
	srl a
	srl a
	srl a
	add l
	ld l, a
	jr nc, .hgt
	inc h
.hgt
	ld de, sMacroMap
	add hl, de
	ld a, [hl]
	ld c, 0
	cp 145
	jr c, .e_done
	inc c
	cp 160
	jr c, .e_done
	inc c
	cp 175
	jr c, .e_done
	inc c
.e_done
	ld a, c
	add a
	add a
	ld [PX_ELEV], a ; level * 4
; moisture level 0..3
	ld a, 6
	ld [PX_NSH], a
	ld a, $20
	ld [PX_NSALT], a
	call ProcNoise
	ld c, 0
	cp 94
	jr c, .m_done
	inc c
	cp 117
	jr c, .m_done
	inc c
	cp 153
	jr c, .m_done
	inc c
.m_done
	ld a, [PX_ELEV]
	add c
	ld hl, ProcBiomeTable
	add l
	ld l, a
	jr nc, .t
	inc h
.t
	ld a, [hl]
	ret

ProcBiomeTable:
; rows: elevation low to high; columns: moisture dry to wet
	db 6, 6, 8, 8 ; desert, desert, swamp, swamp (the coast)
	db 6, 0, 4, 8 ; desert, meadow, flowers, swamp
	db 3, 1, 1, 1 ; forest
	db 5, 7, 7, 7 ; mountains, snow (the heart of the island)

ProcNoise:
; smooth 2D noise 0..255 at world (PS_QU, PS_QV); PX_NSH = grid shift, PX_NSALT = salt
	ld a, [PX_NSH]
	sub 3
	ld c, a
	ld a, [wSaltScratch + PS_QU]
.tu
	srl a
	dec c
	jr nz, .tu
	and 7
	ld [PX_TU], a
	ld a, [PX_NSH]
	sub 3
	ld c, a
	ld a, [wSaltScratch + PS_QV]
.tv
	srl a
	dec c
	jr nz, .tv
	and 7
	ld [PX_TV], a
	ld a, [PX_NSH]
	ld c, a
	ld a, [wSaltScratch + PS_QU]
.su
	srl a
	dec c
	jr nz, .su
	ld [PX_NU], a
	ld a, [PX_NSH]
	ld c, a
	ld a, [wSaltScratch + PS_QV]
.sv
	srl a
	dec c
	jr nz, .sv
	ld [PX_NV], a
; the four corners
	ld a, [PX_NU]
	ld b, a
	ld a, [PX_NV]
	ld c, a
	call ProcNode
	ld [PX_N00], a
	ld a, [PX_NV]
	inc a
	ld c, a
	ld a, [PX_NU]
	ld b, a
	call ProcNode
	ld [PX_N01], a
	ld a, [PX_NU]
	inc a
	ld b, a
	ld a, [PX_NV]
	inc a
	ld c, a
	call ProcNode
	ld [PX_N11], a
	ld a, [PX_NV]
	ld c, a
	ld a, [PX_NU]
	inc a
	ld b, a
	call ProcNode
	ld [PX_N10], a
; along u twice, then along v
	ld a, [PX_N00]
	ld b, a
	ld a, [PX_N10]
	ld c, a
	ld a, [PX_TU]
	ld d, a
	call ProcLerp8
	ld [PX_N00], a
	ld a, [PX_N01]
	ld b, a
	ld a, [PX_N11]
	ld c, a
	ld a, [PX_TU]
	ld d, a
	call ProcLerp8
	ld c, a
	ld a, [PX_N00]
	ld b, a
	ld a, [PX_TV]
	ld d, a
; falls into the last lerp

ProcLerp8:
; a = b + (c - b) * d >> shift
	ld a, c
	sub b
	jr nc, .up
	cpl
	inc a
	call ProcScale
	ld c, a
	ld a, b
	sub c
	ret
.up
	call ProcScale
	add b
	ret

ProcScale:
; a = a * d >> 3 (d = 0..7)
	push bc
	ld e, a
	ld c, d
	ld d, 0
	ld hl, 0
	bit 0, c
	jr z, .b1
	add hl, de
.b1
	sla e
	rl d
	bit 1, c
	jr z, .b2
	add hl, de
.b2
	sla e
	rl d
	bit 2, c
	jr z, .b3
	add hl, de
.b3
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	ld a, l
	pop bc
	ret

ProcNode:
; b = i, c = j: a random byte per grid node, from a permutation table and the seed
	ld a, [wPlayerID]
	add b
	ld hl, PX_NSALT
	add [hl]
	ld hl, ProcPerm
	add l
	ld l, a
	jr nc, .a
	inc h
.a
	ld a, [hl]
	add c
	ld hl, wPlayerID + 1
	add [hl]
	ld hl, ProcPerm
	add l
	ld l, a
	jr nc, .b
	inc h
.b
	ld a, [hl]
	ret

ProcPerm:
	db 158, 28, 102, 188, 247, 177, 130, 55, 101, 157, 206, 154, 183, 107, 81, 39
	db 114, 12, 173, 105, 174, 225, 254, 59, 230, 253, 38, 92, 87, 231, 165, 233
	db 182, 72, 70, 80, 249, 207, 167, 186, 122, 17, 5, 192, 42, 45, 109, 77
	db 215, 16, 171, 108, 234, 200, 33, 95, 212, 104, 175, 185, 43, 223, 116, 47
	db 100, 115, 40, 41, 67, 88, 78, 32, 221, 97, 228, 68, 94, 117, 134, 211
	db 86, 245, 197, 163, 132, 159, 145, 195, 11, 1, 250, 96, 148, 9, 164, 75
	db 139, 153, 58, 36, 170, 187, 184, 133, 79, 242, 166, 205, 131, 191, 62, 237
	db 151, 93, 162, 73, 227, 238, 64, 85, 150, 111, 140, 168, 201, 21, 196, 198
	db 53, 216, 138, 34, 26, 246, 224, 248, 119, 194, 252, 2, 6, 204, 123, 15
	db 236, 106, 90, 124, 4, 23, 176, 76, 241, 193, 172, 203, 125, 144, 226, 65
	db 220, 110, 91, 10, 239, 126, 13, 8, 3, 98, 35, 179, 214, 146, 56, 63
	db 235, 155, 149, 103, 14, 135, 89, 31, 218, 160, 113, 69, 27, 229, 209, 118
	db 147, 24, 219, 222, 190, 54, 189, 181, 25, 19, 137, 180, 152, 112, 143, 178
	db 51, 20, 18, 251, 57, 52, 120, 136, 66, 199, 141, 22, 30, 82, 84, 46
	db 99, 232, 255, 48, 208, 202, 44, 127, 213, 7, 71, 217, 0, 128, 169, 161
	db 244, 37, 60, 156, 142, 243, 121, 74, 29, 240, 210, 49, 61, 50, 83, 129

ProcBlobLayer:
; one layer of blobs (layer in PS_LAYER)
	ld a, [wSaltScratch + PS_LAYER]
	add a
	add a ; * 4
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
	db 191
	db 3
	dw ProcLayerMedium
	db 181
	db 2
	dw ProcLayerTiny
	db 111
	db 4 ; land: big blobs
	dw ProcLayerBig
	db 255
	db 3 ; land: small blobs along the coast
	dw ProcLayerBig
	db 255

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
; most cells grow nothing: the seed's last number is the roll
	ld [PX_ROLL], a
	ld hl, PX_MAXT
	cp [hl]
	ret nc
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
	ld a, [wSaltScratch + PS_LAYER]
	cp 3
	jp nc, ProcLandCell
; biome at the centre (looked up per 8x8 square)
	ld a, [wSaltScratch + PS_CU]
	ld b, a
	ld a, [wSaltScratch + PS_CV]
	ld c, a
	call ProcBiomeCoarse
; kind thresholds for this biome
	ld c, a
	add a
	ld b, a
	add a
	add b ; biome * 6
	add c
	sub c
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
	cp 6
	jr nz, .kind
	ret ; nothing grows here
.found
; kind record: table + 24 + kind * 7
	ld hl, PX_TBL
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, NUM_PROC_BIOMES * 6
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
ProcCutK:
; c = corner cut; stores K and places the blob
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
ProcPlace:
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
	cp 140
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
	cp 140
	ret nc
	ld [wSaltScratch + PS_Y], a
	call ProcBlob
	jp ProcLobes

ProcLandCell:
; a land blob: the nearer to the middle of the world, the likelier it is
	ld a, [wSaltScratch + PS_CV]
	ld c, a
	ld a, [wSaltScratch + PS_CU]
	call ProcIsleDist
	ld d, a
	ld a, d
	sub PROC_ISLE_CORE
	jr nc, .far
	ld a, 255
	jr .have_odds
.far
	cp PROC_ISLE_SPAN
	jr c, .fall
	xor a
	jr .have_odds
.fall
	ld e, a
	add a
	add e
	ld e, a
	ld a, 255
	sub e
.have_odds
	ld e, a
	ld a, [wSaltScratch + PS_LAYER]
	cp 4
	ld a, e
	jr nz, .compare
	srl a
.compare
	ld e, a
	ld a, [PX_ROLL]
	cp e
	ret nc
	ld a, [wSaltScratch + PS_LAYER]
	cp 4
	jr z, .small
	call ProcRand
	and 7
	add 5
	ld [wSaltScratch + PS_A], a
	call ProcRand
	and 7
	add 5
	ld [wSaltScratch + PS_B], a
	jr .shape
.small
	call ProcRand
	and 3
	add 2
	ld [wSaltScratch + PS_A], a
	call ProcRand
	and 3
	add 2
	ld [wSaltScratch + PS_B], a
.shape
	ld a, PROC_GRASS
	ld [wSaltScratch + PS_BLK], a
	xor a
	ld [wSaltScratch + PS_MODE], a
	call ProcRand
	and 7
	ld c, a
	jp ProcCutK

ProcIsleDist:
; a = world u, c = world v; returns a = octagonal distance to the island centre
	sub PROC_ISLE_U
	jr nc, .dx
	cpl
	inc a
.dx
	ld b, a
	ld a, c
	sub PROC_ISLE_V
	jr nc, .dy
	cpl
	inc a
.dy
	ld c, a
	srl a
	srl a
	srl a
	add c ; dy * 9 / 8
	cp b
	jr nc, .d1
	ld a, b
.d1
	ld d, a
	ld a, b
	add c
	ld e, a
	srl a
	srl a
	ld l, a
	ld a, e
	sub l ; (dx + dy) * 3 / 4
	cp d
	jr c, .dist
	ld d, a
.dist
	ld a, d
	ret

ProcCore:
; the heart of the island is always land
	ld a, PROC_ISLE_U
	ld [wSaltScratch + PS_CU], a
	ld a, PROC_ISLE_V
	ld [wSaltScratch + PS_CV], a
	ld a, 34
	ld [wSaltScratch + PS_A], a
	ld a, 28
	ld [wSaltScratch + PS_B], a
	ld a, PROC_GRASS
	ld [wSaltScratch + PS_BLK], a
	xor a
	ld [wSaltScratch + PS_MODE], a
	ld a, 3
	ld [wSaltScratch + PS_LAYER], a
	ld c, 12
	jp ProcCutK

ProcLobes:
; a lumpy blob: a few smaller octagons around the main one
	ld a, [wSaltScratch + PS_LAYER]
	cp 2
	ret z
	cp 4
	ret z
	ld a, [wSaltScratch + PS_A]
	ld [PX_LA0], a
	ld a, [wSaltScratch + PS_B]
	ld [PX_LB0], a
	ld a, [wSaltScratch + PS_X]
	ld [PX_LX0], a
	ld a, [wSaltScratch + PS_Y]
	ld [PX_LY0], a
	ld a, 2
	ld [PX_LCNT], a
.lobe
; centre: main centre moved by up to half the radius either way
	ld a, [PX_LA0]
	inc a
	ld b, a
	call ProcRandMod
	ld c, a
	ld a, [PX_LA0]
	srl a
	ld b, a
	ld a, c
	sub b
	ld hl, PX_LX0
	add [hl]
	ld e, a
	ld a, [PX_LB0]
	inc a
	ld b, a
	call ProcRandMod
	ld c, a
	ld a, [PX_LB0]
	srl a
	ld b, a
	ld a, c
	sub b
	ld hl, PX_LY0
	add [hl]
	ld d, a
; size: about half of the main one
	call ProcRand
	and 1
	ld c, a
	ld a, [PX_LA0]
	srl a
	inc a
	add c
	ld [wSaltScratch + PS_A], a
	call ProcRand
	and 1
	ld c, a
	ld a, [PX_LB0]
	srl a
	inc a
	add c
	ld [wSaltScratch + PS_B], a
; K = a + b - min(a, b) / 2
	ld b, a
	ld a, [wSaltScratch + PS_A]
	cp b
	jr c, .min
	ld a, b
.min
	srl a
	ld c, a
	ld a, [wSaltScratch + PS_A]
	ld b, a
	ld a, [wSaltScratch + PS_B]
	add b
	sub c
	ld [wSaltScratch + PS_K], a
	ld a, e
	cp 140
	jr nc, .skip
	ld a, d
	cp 140
	jr nc, .skip
	ld a, e
	ld [wSaltScratch + PS_X], a
	ld a, d
	ld [wSaltScratch + PS_Y], a
	call ProcBlob
.skip
	ld hl, PX_LCNT
	dec [hl]
	jr nz, .lobe
	ret

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

ProcLerp:
; smooth 1D noise. hl = cache (key, node 0, node 1); PS_A = shift, PS_B = mask,
; PS_K = salt, PS_CI = id, PS_CJ = position. Returns a = value 0..mask.
	push hl
	ld a, [wSaltScratch + PS_A]
	ld c, a
	ld a, [wSaltScratch + PS_CJ]
.key
	srl a
	dec c
	jr nz, .key
	ld d, a ; key = position >> shift
	pop hl
	ld a, [hl]
	cp d
	jr z, .cached
	ld a, d
	ld [hli], a
	push hl
	ld b, d
	ld a, [wSaltScratch + PS_CI]
	ld c, a
	ld a, [wSaltScratch + PS_K]
	push de
	ld d, a
	call ProcHash8
	pop de
	ld hl, wSaltScratch + PS_B
	and [hl]
	ld [wSaltScratch + PS_CU], a
	ld b, d
	inc b
	ld a, [wSaltScratch + PS_CI]
	ld c, a
	ld a, [wSaltScratch + PS_K]
	ld d, a
	call ProcHash8
	ld hl, wSaltScratch + PS_B
	and [hl]
	ld [wSaltScratch + PS_CV], a
	pop hl
	ld a, [wSaltScratch + PS_CU]
	ld [hli], a
	ld a, [wSaltScratch + PS_CV]
	ld [hl], a
	jr .have
.cached
	inc hl
	ld a, [hli]
	ld [wSaltScratch + PS_CU], a
	ld a, [hl]
	ld [wSaltScratch + PS_CV], a
.have
; t = the 3 bits of the position just below the grid shift (8 steps)
	ld a, [wSaltScratch + PS_A]
	sub 3
	ld c, a
	ld a, [wSaltScratch + PS_CJ]
	jr z, .no_shift
.ts
	srl a
	dec c
	jr nz, .ts
.no_shift
	and 7
	ld d, a
	ld a, [wSaltScratch + PS_CV]
	ld hl, wSaltScratch + PS_CU
	sub [hl] ; next - this
	jr nc, .up
	cpl
	inc a
	call ProcScale
	ld b, a
	ld a, [wSaltScratch + PS_CU]
	sub b
	ret
.up
	call ProcScale
	ld b, a
	ld a, [wSaltScratch + PS_CU]
	add b
	ret

ProcLerpCall:
; a = shift, b = mask, c = salt, hl = cache (PS_CI = id, PS_CJ = position)
	ld [wSaltScratch + PS_A], a
	ld a, b
	ld [wSaltScratch + PS_B], a
	ld a, c
	ld [wSaltScratch + PS_K], a
	jp ProcLerp

ProcRidges:
; mountain ranges across the middle of the world: two north-south, two east-west.
; They have gaps; the roads that cross them make the passes.
	ld a, PROC_ROCK
	ld [wSaltScratch + PS_BLK], a
	ld a, 2
	ld [wSaltScratch + PS_MODE], a
	xor a
.v_ridge
	ld [PX_LANE], a
	add 4
	ld [wSaltScratch + PS_CI], a
	ld a, [PX_LANE]
	ld b, a
	ld c, $91
	ld d, $93
	call ProcHash8
	and $0f
	ld c, a
	ld a, [PX_LANE]
	ld b, a
	add a
	add a
	add a
	add a
	ld e, a ; * 16
	ld a, b
	add a
	add a
	add a
	add a
	add a
	add a
	add a ; * 128 (mod 256)
	sub e ; ridge * 112
	add c
	add 50
	ld [PX_BASE], a
	ld a, $ff
	ld [PX_C1], a
	ld [PX_C2], a
	ld [PX_C3], a
	ld [PX_PB], a
.v_row
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_V0
	add [hl]
	call ProcRidgeSpan
	jr c, .v_gap
	call ProcMergeSpan
	ld a, [PX_IDX]
	inc a
	jr z, .v_skip
	dec a
	ld d, a
	call ProcRoadRow
	jr .v_skip
.v_gap
	ld a, $ff
	ld [PX_PB], a
.v_skip
	ld a, [PX_IDX]
	inc a
	cp PROC_ROWS
	jr nz, .v_row
	ld a, [PX_LANE]
	inc a
	cp 2
	jr nz, .v_ridge

	xor a
.h_ridge
	ld [PX_LANE], a
	add 6
	ld [wSaltScratch + PS_CI], a
	ld a, [PX_LANE]
	ld b, a
	ld c, $92
	ld d, $93
	call ProcHash8
	and $0f
	ld c, a
	ld a, [PX_LANE]
	ld b, a
	add a
	add a
	add a
	add a
	ld e, a
	ld a, b
	add a
	add a
	add a
	add a
	add a
	add a
	add a
	sub e
	add c
	add 56
	ld [PX_BASE], a
	ld a, $ff
	ld [PX_C1], a
	ld [PX_C2], a
	ld [PX_C3], a
	ld [PX_PB], a
.h_col
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_U0
	add [hl]
	call ProcRidgeSpan
	jr c, .h_gap
	call ProcMergeSpan
	ld a, [PX_IDX]
	inc a
	jr z, .h_skip
	dec a
	ld d, a
	call ProcRoadCol
	jr .h_skip
.h_gap
	ld a, $ff
	ld [PX_PB], a
.h_skip
	ld a, [PX_IDX]
	inc a
	cp PROC_STRIDE
	jr nz, .h_col
	ld a, [PX_LANE]
	inc a
	cp 2
	jr nz, .h_ridge
	ret

ProcRidgeSpan:
; a = position along the ridge; returns b = first, e = last position across it,
; or carry set when there is a gap here
	ld [wSaltScratch + PS_CJ], a
	ld a, 4
	ld b, 7
	ld c, $83
	ld hl, PX_C3
	call ProcLerpCall
	cp 2
	jr c, .gap
	ld a, 5
	ld b, 31
	ld c, $81
	ld hl, PX_C1
	call ProcLerpCall
	ld hl, PX_BASE
	add [hl]
	ld [PX_DEPTH], a
	ld a, 3
	ld b, 3
	ld c, $82
	ld hl, PX_C2
	call ProcLerpCall
	add 2 ; half width 2..5
	ld c, a
	ld a, [PX_DEPTH]
	sub c
	ld b, a
	ld a, [PX_DEPTH]
	add c
	ld e, a
	and a ; clears carry
	ret
.gap
	scf
	ret

ProcMergeSpan:
; b = first, e = last: widen them to meet the previous row's span, remember this one
	ld a, b
	ld [wSaltScratch + PS_TMP], a
	ld a, e
	ld [wSaltScratch + PS_ROWS], a
	ld a, [PX_PB]
	cp $ff
	jr z, .remember
	cp b
	jr nc, .lo
	ld b, a
.lo
	ld a, [PX_PE]
	cp e
	jr c, .remember
	ld e, a
.remember
	ld a, [wSaltScratch + PS_TMP]
	ld [PX_PB], a
	ld a, [wSaltScratch + PS_ROWS]
	ld [PX_PE], a
	ret

ProcRoadPos:
; a = position along the lane; returns a = where the lane is
	ld [wSaltScratch + PS_CJ], a
	ld a, 5
	ld [wSaltScratch + PS_A], a
	ld a, 31
	ld [wSaltScratch + PS_B], a
	ld hl, PX_C1
	call ProcLerp
	ld hl, PX_BASE
	add [hl]
	ret

ProcRoads:
; three winding roads across the world, and three across the other way
	ld a, PROC_PATH
	ld [wSaltScratch + PS_BLK], a
	ld a, 2
	ld [wSaltScratch + PS_MODE], a
	ld a, $60
	ld [wSaltScratch + PS_K], a
	xor a
.v_lane
	ld [PX_LANE], a
	ld [wSaltScratch + PS_CI], a
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
	add 50
	ld [PX_BASE], a
	ld a, $ff
	ld [PX_C1], a
	ld [PX_PB], a
.v_row
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_V0
	add [hl]
	call ProcRoadPos
	ld b, a
	ld e, a
	inc e
	call ProcMergeSpan
	ld a, [PX_IDX]
	inc a
	jr z, .v_prime
	dec a
	ld d, a
	call ProcRoadRow
.v_prime
	ld a, [PX_IDX]
	inc a
	cp PROC_ROWS
	jr nz, .v_row
	ld a, [PX_LANE]
	inc a
	cp 3
	jr nz, .v_lane

	ld a, $70
	ld [wSaltScratch + PS_K], a
	xor a
.h_lane
	ld [PX_LANE], a
	ld [wSaltScratch + PS_CI], a
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
	add 46
	ld [PX_BASE], a
	ld a, $ff
	ld [PX_C1], a
	ld [PX_PB], a
.h_col
	ld [PX_IDX], a
	ld hl, wSaltScratch + PS_U0
	add [hl]
	call ProcRoadPos
	ld b, a
	ld e, a
	inc e
	call ProcMergeSpan
	ld a, [PX_IDX]
	inc a
	jr z, .h_prime
	dec a
	ld d, a
	call ProcRoadCol
.h_prime
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
.fill
	ld a, [wSaltScratch + PS_MODE]
	and a
	jr z, .put
	ld a, [hl]
	sub $30
	cp $0b
	jr c, .skip
.put
	ld a, [wSaltScratch + PS_BLK]
	ld [hl], a
.skip
	inc hl
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
	ld a, [wSaltScratch + PS_MODE]
	and a
	jr z, .put
	ld a, [hl]
	sub $30
	cp $0b
	jr c, .skip
.put
	ld a, [wSaltScratch + PS_BLK]
	ld [hl], a
.skip
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
	ld a, $ff
	ld [PX_C1], a
	ld [PX_C2], a
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
	ld a, $ff
	ld [PX_C1], a
	ld [PX_C2], a
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

ProcCorners:
; the four corners of the world are cut diagonally, so the land is not a box.
; Reaches 42 blocks in from both edges, so chunks 0, 1, 6 and 7 take part.
	ld a, [wProcChunkX]
	cp 2
	jr c, .x_ok
	cp 6
	ret c
.x_ok
	ld a, [wProcChunkY]
	cp 2
	jr c, .y_ok
	cp 6
	ret c
.y_ok
	ld a, [wProcChunkX]
	cp 4
	ld a, 0
	jr c, .x_west
	inc a
.x_west
	ld [wSaltScratch + PS_X], a
	ld a, [wProcChunkY]
	cp 4
	ld a, 0
	jr c, .y_north
	inc a
.y_north
	ld [wSaltScratch + PS_Y], a
	ld c, 0
.row
; dv = distance of this row from the north / south edge of the world
	ld a, [wSaltScratch + PS_Y]
	and a
	jr nz, .south_row
	ld a, [wSaltScratch + PS_V0]
	add c
	sub 4
	jr nc, .have_dv
	xor a
	jr .have_dv
.south_row
	ld a, 219
	ld hl, wSaltScratch + PS_V0
	sub [hl]
	sub c
	jr nc, .have_dv
	xor a
.have_dv
	cp 42
	jr nc, .next_row
	ld e, a
	ld a, c
	call ProcRowPtr
	ld b, 0
.col
	ld a, [wSaltScratch + PS_X]
	and a
	jr nz, .east_col
	ld a, [wSaltScratch + PS_U0]
	add b
	sub 4
	jr nc, .have_du
	xor a
	jr .have_du
.east_col
	ld a, 243
	push hl
	ld hl, wSaltScratch + PS_U0
	sub [hl]
	pop hl
	sub b
	jr nc, .have_du
	xor a
.have_du
	cp 42
	jr nc, .next
	add e
	cp 42
	jr nc, .next
	ld [hl], PROC_WATER
.next
	inc hl
	inc b
	ld a, b
	cp PROC_STRIDE
	jr nz, .col
.next_row
	inc c
	ld a, c
	cp PROC_ROWS
	jp nz, .row
	ret

ProcCoastAt:
; b = side (0 W, 1 E, 2 N, 3 S), c = position along the side;
; returns a = block (sea or mountain), b = depth
	ld a, b
	ld [wSaltScratch + PS_CI], a
	ld a, c
	ld [wSaltScratch + PS_CJ], a
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
; depth: slow bends plus small bumps
	ld a, 3
	ld [wSaltScratch + PS_A], a
	ld a, 3
	ld [wSaltScratch + PS_B], a
	ld a, $33
	ld [wSaltScratch + PS_K], a
	ld hl, PX_C1
	call ProcLerp
	ld [PX_DEPTH], a
	ld a, 5
	ld [wSaltScratch + PS_A], a
	ld a, 15
	ld [wSaltScratch + PS_B], a
	ld a, $35
	ld [wSaltScratch + PS_K], a
	ld hl, PX_C2
	call ProcLerp
	ld hl, PX_DEPTH
	add [hl]
	add 6 ; depth 6..24 (deeper would reach the next chunk in)
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
	sub $30
	cp $0b
	jr c, .up_water
	call ProcMaybeSand
	pop hl
	set 0, d
	jr .no_up
.up_water
	pop hl
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
	sub $30
	cp $0b
	jr c, .down_water
	call ProcMaybeSand
	pop hl
	set 1, d
	jr .no_down
.down_water
	pop hl
.no_down
	ld a, b
	and a
	jr z, .no_left
	dec hl
	ld a, [hl]
	sub $30
	cp $0b
	jr c, .left_water
	call ProcMaybeSand
	inc hl
	set 2, d
	jr .no_left
.left_water
	inc hl
.no_left
	ld a, b
	cp PROC_STRIDE - 1
	jr z, .no_right
	inc hl
	ld a, [hl]
	sub $30
	cp $0b
	jr c, .right_water
	call ProcMaybeSand
	dec hl
	set 3, d
	jr .no_right
.right_water
	dec hl
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
	jp nz, .row
	ret

ProcMaybeSand:
; hl = a land block next to water at column b, row c: grass-like ground
; becomes sand, about 3 times out of 4 (decided by the world position)
	ld a, [hl]
	sub PROC_GRASS
	cp 3
	ret nc
	push de
	ld a, [wSaltScratch + PS_U0]
	add b
	ld d, a
	ld a, [wSaltScratch + PS_V0]
	add c
	ld e, a
	srl a
	xor d
	ld d, a
	srl a
	srl a
	xor e
	and 3
	pop de
	ret z
	ld [hl], PROC_SAND
	ret

ProcRimBlocks:
; index: up land = 1, down = 2, left = 4, right = 8
	db $35, $31, $39, $35
	db $34, $30, $38, $34
	db $36, $32, $3a, $36
	db $35, $31, $39, $35

; Blob layers: 9 biomes x 6 cumulative odds (out of 256) for the 6 kinds,
; then 6 kinds of: block, mode (0 always, 1 only on grass, 2 never on water),
; a base, a mask, b base, b mask, corner-cut mask.
; biomes: meadow, forest, lakes, tall grass, flowers, mountains, desert, snow, swamp
ProcLayerBig:
	db 10, 30, 60, 60, 66, 66
	db  4, 150, 160, 160, 160, 160
	db 130, 150, 160, 160, 170, 170
	db  4, 14, 140, 140, 140, 140
	db  4, 14, 100, 100, 100, 100
	db  4, 24, 40, 170, 170, 170
	db  2, 6, 6, 60, 190, 190
	db  0, 10, 10, 40, 40, 190
	db 40, 60, 130, 130, 130, 130
	db PROC_WATER,  0, 3, 7, 3, 3, 7 ; lake
	db PROC_TREE,   2, 3, 7, 3, 7, 7 ; big wood
	db PROC_TALL,   2, 3, 7, 3, 7, 7 ; tall grass field
	db PROC_ROCK,   2, 2, 7, 2, 7, 7 ; rocky mass
	db PROC_SAND,   2, 3, 7, 3, 3, 7 ; dunes
	db PROC_SNOW,   2, 4, 7, 4, 7, 7 ; snowfield

ProcLayerMedium:
	db 30, 90, 110, 110, 120, 120
	db 10, 20, 120, 120, 120, 120
	db 20, 30, 80, 80, 90, 90
	db 120, 130, 150, 150, 150, 150
	db 20, 150, 170, 170, 170, 170
	db 10, 15, 45, 130, 140, 140
	db 5, 5, 15, 60, 150, 150
	db 0, 0, 30, 50, 50, 175
	db 20, 20, 90, 90, 90, 90
	db PROC_TALL,    1, 1, 3, 1, 3, 3
	db PROC_FLOWERS, 1, 1, 3, 0, 3, 3
	db PROC_TREE,    1, 1, 3, 1, 3, 3
	db PROC_ROCK,    1, 0, 3, 0, 1, 1
	db PROC_SAND,    1, 1, 3, 1, 3, 3
	db PROC_SNOW,    1, 1, 3, 1, 3, 3

ProcLayerTiny:
	db 15, 50, 70, 70, 75, 75
	db 4, 10, 70, 70, 70, 70
	db 10, 20, 40, 40, 50, 50
	db 60, 70, 80, 80, 80, 80
	db 10, 90, 100, 100, 100, 100
	db 5, 8, 20, 90, 100, 100
	db 2, 2, 6, 30, 100, 100
	db 10, 10, 10, 40, 40, 100
	db 50, 50, 90, 90, 90, 90
	db PROC_TREE,    1, 0, 1, 0, 0, 0
	db PROC_FLOWERS, 1, 0, 1, 0, 1, 0
	db PROC_TALL,    1, 0, 1, 0, 1, 0
	db PROC_ROCK,    1, 0, 1, 0, 0, 0
	db PROC_SAND,    1, 0, 1, 0, 1, 0
	db PROC_SNOW,    1, 0, 1, 0, 1, 0

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
	push de
	push hl
	ld e, a
	ld d, 0
	ld h, 0
	ld l, 0
	ld a, b
	ld d, a
; hl = e * d (8 iterations), result is the high byte
	ld b, 8
	ld a, e
.mul
	add hl, hl
	rlca
	jr nc, .next
	push bc
	ld b, 0
	ld c, d
	add hl, bc
	pop bc
.next
	dec b
	jr nz, .mul
	ld a, h
	pop hl
	pop de
	ret


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
