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

DEF G_X EQUS "(wOverworldMapBlocks + 1190)"
DEF G_Y EQUS "(wOverworldMapBlocks + 1191)"
DEF G_W EQUS "(wOverworldMapBlocks + 1192)"
DEF G_H EQUS "(wOverworldMapBlocks + 1193)"
DEF G_K EQUS "(wOverworldMapBlocks + 1194)"
DEF G_B EQUS "(wOverworldMapBlocks + 1195)"
DEF G_WMIN EQUS "(wOverworldMapBlocks + 1196)"
DEF G_WR EQUS "(wOverworldMapBlocks + 1197)"
DEF G_HMIN EQUS "(wOverworldMapBlocks + 1198)"
DEF G_HR EQUS "(wOverworldMapBlocks + 1199)"
DEF G_I EQUS "(wOverworldMapBlocks + 1200)"
DEF G_J EQUS "(wOverworldMapBlocks + 1201)"
DEF G_T EQUS "(wOverworldMapBlocks + 1202)"
DEF G_PY EQUS "(wOverworldMapBlocks + 1203)"
DEF G_PH EQUS "(wOverworldMapBlocks + 1204)"
DEF G_CX EQUS "(wOverworldMapBlocks + 1205)"
DEF G_CY EQUS "(wOverworldMapBlocks + 1206)"
DEF G_BEST EQUS "(wOverworldMapBlocks + 1207)"
DEF G_BI EQUS "(wOverworldMapBlocks + 1208)"
DEF G_BJ EQUS "(wOverworldMapBlocks + 1209)"
DEF G_CNT EQUS "(wOverworldMapBlocks + 1210)"
DEF G_BW EQUS "(wOverworldMapBlocks + 1211)"
DEF G_ORI EQUS "(wOverworldMapBlocks + 1212)"
DEF G_X1 EQUS "(wOverworldMapBlocks + 1213)"
DEF G_Y1 EQUS "(wOverworldMapBlocks + 1214)"
DEF G_X2 EQUS "(wOverworldMapBlocks + 1215)"
DEF G_Y2 EQUS "(wOverworldMapBlocks + 1216)"
DEF G_YH EQUS "(wOverworldMapBlocks + 1217)"
DEF G_XV EQUS "(wOverworldMapBlocks + 1218)"
DEF G_HB EQUS "(wOverworldMapBlocks + 1219)"
DEF G_RX EQUS "(wOverworldMapBlocks + 1220)"
DEF G_RY EQUS "(wOverworldMapBlocks + 1221)"
DEF G_RW EQUS "(wOverworldMapBlocks + 1222)"
DEF G_RH EQUS "(wOverworldMapBlocks + 1223)"
DEF G_RB EQUS "(wOverworldMapBlocks + 1224)"
DEF G_RK EQUS "(wOverworldMapBlocks + 1225)"
DEF G_RBLK EQUS "(wOverworldMapBlocks + 1226)"
DEF G_FC EQUS "(wOverworldMapBlocks + 1227)"
DEF G_FW EQUS "(wOverworldMapBlocks + 1228)"
DEF G_R EQUS "(wOverworldMapBlocks + 1229)"
DEF G_C EQUS "(wOverworldMapBlocks + 1230)"
DEF G_BIO EQUS "(wOverworldMapBlocks + 1231)"
DEF G_N EQUS "(wOverworldMapBlocks + 1233)"
DEF G_SY EQUS "(wOverworldMapBlocks + 1234)"
DEF G_SH EQUS "(wOverworldMapBlocks + 1235)"
DEF G_DX EQUS "(wOverworldMapBlocks + 1239)"
DEF G_DY EQUS "(wOverworldMapBlocks + 1241)"
DEF G_SX EQUS "(wOverworldMapBlocks + 1242)"
DEF G_QX EQUS "(wOverworldMapBlocks + 1243)"
DEF G_QY EQUS "(wOverworldMapBlocks + 1244)"
DEF G_QW EQUS "(wOverworldMapBlocks + 1245)"
DEF G_QH EQUS "(wOverworldMapBlocks + 1246)"
DEF G_SEAF EQUS "(wOverworldMapBlocks + 1237)"
DEF G_SEA EQUS "(wOverworldMapBlocks + 1238)"
DEF G_TRYW EQUS "(wOverworldMapBlocks + 1240)"
DEF G_IN EQUS "(wOverworldMapBlocks + 1270)"
DEF PX_NSALT EQUS "(wOverworldMapBlocks + 1188)"

; ---------------------------------------------------------------------------
; The world: PLACES (towns, forests, caves, lakes, ...) joined by wide ROUTES.
; Both are plain rectangles in world block coordinates, made once per game and
; kept in SRAM (sZone): byte 0 = number of places, byte 1 = number of routes,
; then places (x, y, w, h, kind, biome) from +2 and routes (x, y, w, h, biome)
; from +122. Everything outside the rectangles is a wall of trees.
; Kinds: 0 town, 1 forest, 2 cave, 3 lake, 4 desert, 5 snow, 6 swamp.
; Biomes: 1 meadow, 2 forest, 3 desert, 4 snow, 5 swamp, 6 mountain.

DEF ZN_PLACES EQU 2
DEF ZN_ROUTES EQU 122
DEF ZN_SIZE   EQU 400
DEF PROC_MAGIC EQU $ac

MACRO RForEach
	xor a
	ld [G_N], a
.loop\@
	ld a, [sZone + 1]
	ld b, a
	ld a, [sZone]
	add b
	ld b, a
	ld a, [G_N]
	cp b
	jr z, .done\@
	call RLoad
	call \1
	ld a, [G_N]
	inc a
	ld [G_N], a
	jr .loop\@
.done\@
ENDM

ProcGenAny::
; builds the map if this is one of the procedural ones
	ld a, [wMapNumber]
	cp MAP_PROC_CAVE
	jp z, ProcGenCave
	cp MAP_PROC_TEST
	ret nz

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

	call ProcWorldEnsure
	ld hl, wOverworldMapBlocks
	ld bc, PROC_STRIDE * PROC_ROWS
	ld a, PROC_TREE
	call ByteFill
	ld a, BANK(sZone)
	call OpenSRAM
	xor a
	ld [PX_NSALT], a
	RForEach RPassWall
	RForEach RPassGroundR
	RForEach RPassLaneR
	RForEach RPassGroundP
	RForEach RPassWater
	RForEach RPassRim
	call RDecor
	RForEach RPassLaneP
	RForEach RPassCave
	call ProcHome
	jp CloseSRAM

ProcWorldEnsure:
; makes the world if this game does not have one yet
	ld a, BANK(sMacroMagic)
	call OpenSRAM
	ld a, [sMacroMagic]
	cp PROC_MAGIC
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
	call RGenWorld
	ld a, [wPlayerID]
	ld [sMacroSeed], a
	ld a, [wPlayerID + 1]
	ld [sMacroSeed + 1], a
	ld a, PROC_MAGIC
	ld [sMacroMagic], a
.done
	jp CloseSRAM


; ---------------------------------------------------------------------------
; making the world

RGenWorld:
	ld b, 0
	ld c, 0
	ld d, $5a
	call ProcSeed
	ld hl, sZone
	ld bc, ZN_SIZE
	xor a
	call ByteFill
	call RGenPlaces
	jp RGenEdges

RPlaceAddr:
; a = index; hl = its record (6 bytes)
	ld l, a
	ld h, 0
	add hl, hl
	ld e, l
	ld d, h
	add hl, hl
	add hl, de
	ld de, sZone + ZN_PLACES
	add hl, de
	ret

RRouteAddr:
; a = index; hl = its record (5 bytes)
	ld e, a
	ld d, 0
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, de
	ld de, sZone + ZN_ROUTES
	add hl, de
	ret

RGenPlaces:
; the first place is a fixed town around the trailhead
	xor a
	call RPlaceAddr
	ld a, 126
	ld [hli], a
	ld a, 127
	ld [hli], a
	ld a, 16
	ld [hli], a
	ld a, 14
	ld [hli], a
	xor a
	ld [hli], a
	ld a, 1
	ld [hl], a
	ld [sZone], a
	ld b, 6
	call ProcRandMod
	add 12
	ld [G_T], a
	ld a, 600 % 256
	ld [G_TRYW], a
	ld a, 600 / 256
	ld [G_TRYW + 1], a
.try
	ld hl, G_TRYW
	ld a, [hl]
	sub 1
	ld [hli], a
	ld a, [hl]
	sbc 0
	ld [hl], a
	ret c
	ld a, [sZone]
	ld b, a
	ld a, [G_T]
	cp b
	ret z
; a kind of place and its size
	ld b, 10
	call ProcRandMod
	ld e, a
	ld d, 0
	ld hl, RKindPick
	add hl, de
	ld a, [hl]
	ld [G_K], a
	ld e, a
	ld d, 0
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, de
	ld de, RKinds
	add hl, de
	ld a, [hli]
	ld [G_WMIN], a
	ld a, [hli]
	ld [G_WR], a
	ld a, [hli]
	ld [G_HMIN], a
	ld a, [hli]
	ld [G_HR], a
	ld a, [hl]
	ld [G_B], a
	ld a, [G_WR]
	ld b, a
	call ProcRandMod
	ld b, a
	ld a, [G_WMIN]
	add b
	ld [G_W], a
	ld a, [G_HR]
	ld b, a
	call ProcRandMod
	ld b, a
	ld a, [G_HMIN]
	add b
	ld [G_H], a
; position, inside the world with a margin of 6
	ld a, [G_W]
	cpl
	inc a
	add 228
	ld b, a
	call ProcRandMod
	add 6
	ld [G_X], a
	ld a, [G_H]
	cpl
	inc a
	add 204
	ld b, a
	call ProcRandMod
	add 6
	ld [G_Y], a
; it must keep its distance from every other place
	xor a
	ld [G_I], a
.chk
	ld a, [sZone]
	ld b, a
	ld a, [G_I]
	cp b
	jr z, .fits
	call RPlaceAddr
	call RPlaceHit
	jp c, .try
	ld a, [G_I]
	inc a
	ld [G_I], a
	jr .chk
.fits
	ld a, [sZone]
	call RPlaceAddr
	ld a, [G_X]
	ld [hli], a
	ld a, [G_Y]
	ld [hli], a
	ld a, [G_W]
	ld [hli], a
	ld a, [G_H]
	ld [hli], a
	ld a, [G_K]
	ld [hli], a
	ld a, [G_B]
	ld [hl], a
	ld hl, sZone
	inc [hl]
	jp .try

RPlaceHit:
; hl = a place; carry set when the new place (G_X, G_Y, G_W, G_H) is too close to it
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld [G_PY], a
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld [G_PH], a
	ld a, [G_X]
	ld b, a
	ld a, [G_W]
	ld c, a
	call RAxis
	ret nc
	ld a, [G_PY]
	ld d, a
	ld a, [G_PH]
	ld e, a
	ld a, [G_Y]
	ld b, a
	ld a, [G_H]
	ld c, a
	jp RAxis

RAxis:
; b = start 1, c = length 1, d = start 2, e = length 2: carry when they come within 10 of each other
	ld a, d
	add e
	add 10
	cp b
	jr c, .no
	jr z, .no
	ld a, b
	add c
	add 10
	cp d
	jr c, .no
	jr z, .no
	scf
	ret
.no
	and a
	ret

RCentre:
; a = place; returns b = x, c = y of its centre
	call RPlaceAddr
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
	srl a
	add b
	ld b, a
	ld a, [hl]
	srl a
	add c
	ld c, a
	ret

RDist:
; a = distance between the centres of places G_I and G_J (never more than 254)
	ld a, [G_I]
	call RCentre
	ld a, b
	ld [G_CX], a
	ld a, c
	ld [G_CY], a
	ld a, [G_J]
	call RCentre
	ld a, [G_CX]
	sub b
	jr nc, .dx
	cpl
	inc a
.dx
	ld d, a
	ld a, [G_CY]
	sub c
	jr nc, .dy
	cpl
	inc a
.dy
	add d
	ret nc
	ld a, 254
	ret

RMinDist:
; b, c -> a = the smaller, d = their difference
	ld a, b
	cp c
	jr c, .blt
	ld a, b
	sub c
	ld d, a
	ld a, c
	ret
.blt
	ld a, c
	sub b
	ld d, a
	ld a, b
	ret

RGenEdges:
; every place is joined to the rest (shortest links first), plus a few extra loops
	ld hl, G_IN
	ld bc, 20
	xor a
	call ByteFill
	ld a, 1
	ld [G_IN], a
	ld [G_CNT], a
.edge
	ld a, $ff
	ld [G_BEST], a
	xor a
	ld [G_I], a
.bi
	ld a, [G_I]
	ld e, a
	ld d, 0
	ld hl, G_IN
	add hl, de
	ld a, [hl]
	or a
	jr z, .bi_next
	xor a
	ld [G_J], a
.bj
	ld a, [G_J]
	ld e, a
	ld d, 0
	ld hl, G_IN
	add hl, de
	ld a, [hl]
	or a
	jr nz, .bj_next
	call RDist
	ld b, a
	ld a, [G_BEST]
	cp b
	jr c, .bj_next
	jr z, .bj_next
	ld a, b
	ld [G_BEST], a
	ld a, [G_I]
	ld [G_BI], a
	ld a, [G_J]
	ld [G_BJ], a
.bj_next
	ld a, [G_J]
	inc a
	ld [G_J], a
	ld b, a
	ld a, [sZone]
	cp b
	jr nz, .bj
.bi_next
	ld a, [G_I]
	inc a
	ld [G_I], a
	ld b, a
	ld a, [sZone]
	cp b
	jr nz, .bi
	ld a, [G_BJ]
	ld e, a
	ld d, 0
	ld hl, G_IN
	add hl, de
	ld [hl], 1
	ld a, [G_BI]
	ld [G_I], a
	ld a, [G_BJ]
	ld [G_J], a
	call RAddRoute
	ld a, [G_CNT]
	inc a
	ld [G_CNT], a
	ld b, a
	ld a, [sZone]
	cp b
	jp nz, .edge
; extra loops between places that are not far apart
	xor a
	ld [G_SEA], a
	ld [G_SEAF], a
	ld a, 16
	ld [G_T], a
.extra
	ld a, [sZone]
	ld b, a
	call ProcRandMod
	ld [G_I], a
	ld a, [sZone]
	ld b, a
	call ProcRandMod
	ld [G_J], a
	ld b, a
	ld a, [G_I]
	cp b
	jr z, .skip
	call RDist
	cp 110
	jr nc, .skip
	ld a, [G_SEA]
	cp 2
	jr nc, .land
	ld a, 1
	ld [G_SEAF], a
	ld hl, G_SEA
	inc [hl]
.land
	call RAddRoute
	xor a
	ld [G_SEAF], a
.skip
	ld a, [G_T]
	dec a
	ld [G_T], a
	jr nz, .extra
	ret

RAddRoute:
; a wide route from place G_I to place G_J: one horizontal and one vertical rectangle
	ld a, [G_I]
	call RCentre
	ld a, b
	ld [G_X1], a
	ld a, c
	ld [G_Y1], a
	ld a, [G_J]
	call RCentre
	ld a, b
	ld [G_X2], a
	ld a, c
	ld [G_Y2], a
	ld b, 6
	call ProcRandMod
	add 5
	ld [G_BW], a
	srl a
	ld [G_HB], a
	ld b, 8
	call ProcRandMod
	ld e, a
	ld d, 0
	ld hl, RRouteBiomes
	add hl, de
	ld a, [hl]
	ld [G_RB], a
	ld a, [G_SEAF]
	or a
	jr z, .nosea
	ld a, 7
	ld [G_RB], a
.nosea
	ld b, 2
	call ProcRandMod
	or a
	jr nz, .o1
	ld a, [G_Y1]
	ld [G_YH], a
	ld a, [G_X2]
	ld [G_XV], a
	jr .oc
.o1
	ld a, [G_Y2]
	ld [G_YH], a
	ld a, [G_X1]
	ld [G_XV], a
.oc
; horizontal part: x = min - half, w = distance + width, y = row - half, h = width
	ld a, [G_X1]
	ld b, a
	ld a, [G_X2]
	ld c, a
	call RMinDist
	ld b, a
	ld a, [G_HB]
	ld c, a
	ld a, b
	sub c
	ld [G_RX], a
	ld a, [G_BW]
	add d
	ld [G_RW], a
	ld a, [G_YH]
	ld c, a
	ld a, [G_HB]
	ld b, a
	ld a, c
	sub b
	ld [G_RY], a
	ld a, [G_BW]
	ld [G_RH], a
	call RPutRoute
; vertical part
	ld a, [G_Y1]
	ld b, a
	ld a, [G_Y2]
	ld c, a
	call RMinDist
	ld b, a
	ld a, [G_HB]
	ld c, a
	ld a, b
	sub c
	ld [G_RY], a
	ld a, [G_BW]
	add d
	ld [G_RH], a
	ld a, [G_XV]
	ld c, a
	ld a, [G_HB]
	ld b, a
	ld a, c
	sub b
	ld [G_RX], a
	ld a, [G_BW]
	ld [G_RW], a

RPutRoute:
	ld a, [sZone + 1]
	call RRouteAddr
	ld a, [G_RX]
	ld [hli], a
	ld a, [G_RY]
	ld [hli], a
	ld a, [G_RW]
	ld [hli], a
	ld a, [G_RH]
	ld [hli], a
	ld a, [G_RB]
	ld [hl], a
	ld hl, sZone + 1
	inc [hl]
	ret

; kind: min width, width range, min height, height range, biome
RKinds:
	db 10, 8, 9, 6, 1   ; town
	db 12, 14, 11, 11, 2 ; forest
	db 12, 10, 11, 9, 6  ; cave
	db 14, 12, 12, 10, 1 ; lake
	db 12, 14, 11, 11, 3 ; desert
	db 12, 14, 11, 11, 4 ; snow
	db 12, 14, 11, 11, 5 ; swamp
	db 16, 12, 13, 8, 8  ; highland
RKindPick:
	db 0, 0, 1, 2, 3, 4, 5, 6, 7, 7
RRouteBiomes:
	db 1, 1, 2, 2, 3, 4, 5, 6

; biome: ground block, then two (limit, block) pairs; a random byte below the first
; limit gives the first block, below the second the second block, else the ground
RDecorTab:
	db PROC_GRASS, 30, PROC_TALL, 40, PROC_FLOWERS   ; meadow
	db PROC_GRASS, 90, PROC_TREE, 120, PROC_TALL     ; forest
	db PROC_SAND, 14, PROC_ROCK, 14, PROC_ROCK       ; desert
	db PROC_SNOW, 18, PROC_ROCK, 18, PROC_ROCK       ; snow
	db PROC_GRASS, 30, PROC_WATER, 100, PROC_TALL    ; swamp
	db PROC_SAND, 60, PROC_ROCK, 60, PROC_ROCK       ; mountain
	db PROC_WATER, 0, PROC_WATER, 0, PROC_WATER      ; sea
	db $71, 22, PROC_ROCK, 22, PROC_ROCK             ; highland (raised ground)

; ---------------------------------------------------------------------------
; drawing one chunk

RLoad:
; a = rectangle number (routes first, then places): G_RX..G_RH, G_RB (biome), G_RK (kind, $ff for routes)
	ld b, a
	ld a, [sZone + 1]
	ld c, a
	ld a, b
	cp c
	jr nc, .place
	call RRouteAddr
	call RLoad4
	ld a, [hl]
	ld [G_RB], a
	ld a, $ff
	ld [G_RK], a
	ret
.place
	sub c
	call RPlaceAddr
	call RLoad4
	ld a, [hli]
	ld [G_RK], a
	ld a, [hl]
	ld [G_RB], a
	ret

RLoad4:
	ld a, [hli]
	ld [G_RX], a
	ld a, [hli]
	ld [G_RY], a
	ld a, [hli]
	ld [G_RW], a
	ld a, [hli]
	ld [G_RH], a
	ret

RClip1:
; b = origin, c = start, d = length, e = window size: carry if outside the window,
; else c = offset in the window and d = the length inside it
	ld a, c
	add d
	ld h, a
	ld a, c
	cp b
	jr nc, .s_ok
	ld a, b
.s_ok
	ld c, a
	ld a, b
	add e
	cp h
	jr c, .e_win
	ld a, h
.e_win
	cp c
	jr z, .empty
	jr c, .empty
	sub c
	ld d, a
	ld a, c
	sub b
	ld c, a
	and a
	ret
.empty
	scf
	ret

RClipFill:
; fills the world rectangle G_RX, G_RY, G_RW, G_RH with block G_RBLK (the part inside the buffer)
	ld a, [wSaltScratch + PS_U0]
	ld b, a
	ld a, [G_RX]
	ld c, a
	ld a, [G_RW]
	ld d, a
	ld e, PROC_STRIDE
	call RClip1
	ret c
	ld a, c
	ld [G_FC], a
	ld a, d
	ld [G_FW], a
	ld a, [wSaltScratch + PS_V0]
	ld b, a
	ld a, [G_RY]
	ld c, a
	ld a, [G_RH]
	ld d, a
	ld e, PROC_ROWS
	call RClip1
	ret c
	ld e, d
	ld a, [G_FW]
	ld d, a
	ld a, [G_FC]
	ld b, a
	ld a, [G_RBLK]
	jp ProcFillRect

RPassWall:
; a wall three blocks thick around the rectangle, made of rock for dry, cold and rocky ground
; and of trees elsewhere
	ld a, [G_RB]
	dec a
	ld e, a
	ld d, 0
	ld hl, RWallTab
	add hl, de
	ld a, [hl]
	ld [G_RBLK], a
	ld a, [G_RX]
	sub 3
	ld [G_RX], a
	ld a, [G_RY]
	sub 3
	ld [G_RY], a
	ld a, [G_RW]
	add 6
	ld [G_RW], a
	ld a, [G_RH]
	add 6
	ld [G_RH], a
	jp RClipFill

; wall block for each biome: meadow, forest, desert, snow, swamp, mountain, sea, highland
RWallTab:
	db PROC_TREE, PROC_TREE, PROC_ROCK, PROC_ROCK, PROC_TREE, PROC_ROCK, PROC_TREE, PROC_ROCK

RPassGroundR:
; routes first, so that the places can sit on top of them
	ld a, [G_RK]
	inc a
	ret nz
	jr RPassGround

RPassGroundP:
	ld a, [G_RK]
	inc a
	ret z

RPassGround:
	ld a, [G_RB]
	add $e0
	ld [G_RBLK], a
	jp RClipFill

RPassWater:
; lakes: water in the middle of the place
	ld a, [G_RK]
	cp 3
	ret nz
	ld a, [G_RX]
	add 4
	ld [G_RX], a
	ld a, [G_RY]
	add 4
	ld [G_RY], a
	ld a, [G_RW]
	sub 8
	ld [G_RW], a
	ld a, [G_RH]
	sub 8
	ld [G_RH], a
	ld a, PROC_WATER
	ld [G_RBLK], a
	jp RClipFill

RPassRim:
; highlands: a rim of cliff blocks one block inside the rectangle (the cross of road opens it up)
	ld a, [G_RK]
	cp 7
	ret nz
	ld a, [G_RX]
	ld [G_QX], a
	ld a, [G_RY]
	ld [G_QY], a
	ld a, [G_RW]
	ld [G_QW], a
	ld a, [G_RH]
	ld [G_QH], a
; top and bottom edges
	ld a, [G_QW]
	sub 4
	ld d, a
	ld e, 1
	ld a, $70
	ld b, 2
	ld c, 1
	call RRimAt
	ld a, [G_QH]
	sub 2
	ld c, a
	ld a, $72
	ld b, 2
	call RRimAt
; hop-down ledges on both sides of the south gate (a one-way shortcut off the highland)
	ld a, [G_QW]
	srl a
	ld [G_DX], a
	sub 5
	ld d, a
	ld e, 1
	ld a, [G_QH]
	sub 2
	ld c, a
	ld b, 3
	ld a, $56
	call RRimAt
	ld a, [G_DX]
	add 3
	ld b, a
	ld a, [G_QW]
	ld hl, G_DX
	sub [hl]
	sub 6
	ld d, a
	ld e, 1
	ld a, [G_QH]
	sub 2
	ld c, a
	ld a, $56
	call RRimAt
; left and right edges
	ld a, [G_QH]
	sub 4
	ld e, a
	ld d, 1
	ld a, $68
	ld b, 1
	ld c, 2
	call RRimAt
	ld a, [G_QW]
	sub 2
	ld b, a
	ld a, $69
	ld c, 2
	call RRimAt
; corners
	ld d, 1
	ld e, 1
	ld a, $6a
	ld b, 1
	ld c, 1
	call RRimAt
	ld a, [G_QW]
	sub 2
	ld b, a
	ld a, $6b
	ld c, 1
	call RRimAt
	ld a, [G_QH]
	sub 2
	ld c, a
	ld a, $6d
	call RRimAt
	ld b, 1
	ld a, $6c
	call RRimAt
	ld a, [G_QX]
	ld [G_RX], a
	ld a, [G_QY]
	ld [G_RY], a
	ld a, [G_QW]
	ld [G_RW], a
	ld a, [G_QH]
	ld [G_RH], a
	ret

RRimAt:
; a = block, b/c = offset from the rectangle's corner, d/e = size
	ld [G_RBLK], a
	ld a, [G_QX]
	add b
	ld [G_RX], a
	ld a, [G_QY]
	add c
	ld [G_RY], a
	ld a, d
	ld [G_RW], a
	ld a, e
	ld [G_RH], a
	push bc
	push de
	call RClipFill
	pop de
	pop bc
	ret

RDecor:
; every ground block still marked ($e1-$e7) becomes the biome's ground or its scatter of trees, rocks, ...
	ld hl, wOverworldMapBlocks
	xor a
	ld [G_R], a
.row
	xor a
	ld [G_C], a
.col
	ld a, [hl]
	cp $e0
	jr c, .next
	sub $e1
	ld [G_BIO], a
	push hl
	ld a, [wSaltScratch + PS_U0]
	ld hl, G_C
	add [hl]
	ld b, a
	ld a, [wSaltScratch + PS_V0]
	ld hl, G_R
	add [hl]
	ld c, a
	call ProcNode
	ld b, a
	ld a, [G_BIO]
	ld e, a
	ld d, 0
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, de
	ld de, RDecorTab
	add hl, de
	ld d, [hl]
	inc hl
	ld a, b
	cp [hl]
	inc hl
	jr c, .o1
	inc hl
	ld a, b
	cp [hl]
	inc hl
	jr c, .o1
	ld a, d
	jr .put
.o1
	ld a, [hl]
.put
	pop hl
	ld [hl], a
.next
	inc hl
	ld a, [G_C]
	inc a
	ld [G_C], a
	cp PROC_STRIDE
	jr nz, .col
	ld a, [G_R]
	inc a
	ld [G_R], a
	cp PROC_ROWS
	jr nz, .row
	ret

RPassLaneR:
	ld a, [G_RK]
	inc a
	ret nz
	jr RPassLane

RPassLaneP:
	ld a, [G_RK]
	inc a
	ret z

RPassLane:
; a 3-wide cross of open ground through the middle of every rectangle (streets in towns)
	ld a, [G_RK]
	or a
	jr nz, .wild
	ld a, PROC_PATH
	jr .set
.wild
	ld a, [G_RB]
	dec a
	ld e, a
	ld d, 0
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, de
	ld de, RDecorTab
	add hl, de
	ld a, [hl]
.set
	ld [G_RBLK], a
	ld a, [G_RY]
	ld [G_SY], a
	ld a, [G_RH]
	ld [G_SH], a
	srl a
	ld b, a
	ld a, [G_RY]
	add b
	dec a
	ld [G_RY], a
	ld a, 3
	ld [G_RH], a
	call RClipFill
	ld a, [G_SY]
	ld [G_RY], a
	ld a, [G_SH]
	ld [G_RH], a
	ld a, [G_RK]
	cp 3
	ret z
	ld a, [G_RW]
	srl a
	ld b, a
	ld a, [G_RX]
	add b
	dec a
	ld [G_RX], a
	ld a, 3
	ld [G_RW], a
	jp RClipFill

RPassCave:
; caves have two mouths: A (north-east of the middle, open ground south of it, rock to its north)
; and B (south-west of the middle, open ground north of it, rock to its south)
	ld a, [G_RK]
	cp 2
	ret nz
	ld a, [G_RW]
	srl a
	ld b, a
	ld a, [G_RX]
	add b
	ld [G_RX], a
	ld a, [G_RH]
	srl a
	ld b, a
	ld a, [G_RY]
	add b
	ld [G_RY], a
	ld a, 1
	ld [G_RW], a
	ld [G_RH], a
; mouth A at (+3, -3)
	ld a, 3
	ld b, -3
	call RMouth
; mouth B at (-3, +3)
	ld a, -3
	ld b, 3
; falls through for B

RMouth:
; a = dx, b = dy from the middle (G_RX, G_RY): the mouth, a rock on each side, open ground on
; the side facing the road and a rock on the far side
	ld [G_DX], a
	ld a, b
	ld [G_DY], a
	ld a, [G_RX]
	ld [G_SX], a
	ld a, [G_RY]
	ld [G_SY], a
	ld a, [G_DX]
	ld b, a
	ld a, [G_RX]
	add b
	ld [G_RX], a
	ld a, [G_DY]
	ld b, a
	ld a, [G_RY]
	add b
	ld [G_RY], a
	ld a, $73
	ld [G_RBLK], a
	call RClipFill
	ld a, PROC_ROCK
	ld [G_RBLK], a
	ld a, [G_RX]
	dec a
	ld [G_RX], a
	call RClipFill
	ld a, [G_RX]
	add 2
	ld [G_RX], a
	call RClipFill
	ld a, [G_RX]
	dec a
	ld [G_RX], a
; the road side is the side facing the middle: dy < 0 means the road is south
	ld a, [G_DY]
	bit 7, a
	jr nz, .north_mouth
; mouth in the south: sand above, rock below
	ld a, [G_RY]
	dec a
	ld [G_RY], a
	ld a, PROC_SAND
	ld [G_RBLK], a
	call RClipFill
	ld a, [G_RY]
	add 2
	ld [G_RY], a
	ld a, PROC_ROCK
	ld [G_RBLK], a
	jr .done
.north_mouth
	ld a, [G_RY]
	inc a
	ld [G_RY], a
	ld a, PROC_SAND
	ld [G_RBLK], a
	call RClipFill
	ld a, [G_RY]
	sub 2
	ld [G_RY], a
	ld a, PROC_ROCK
	ld [G_RBLK], a
.done
	call RClipFill
	ld a, [G_SX]
	ld [G_RX], a
	ld a, [G_SY]
	ld [G_RY], a
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


; ---------------------------------------------------------------------------
; doors between the world and the caves

DEF CAVE_W EQU 20
DEF CAVE_H EQU 18
DEF CAVE_STRIDE EQU CAVE_W + 6
DEF CAVE_WALL EQU $2d
DEF CAVE_FLOOR EQU $02
DEF CAVE_LADDER EQU $07
DEF CAVE_LADDER_UP EQU $0b
DEF CAVE_DOOR EQU $73

ProcBlockAt:
; b = column, c = row in the buffer; returns a = that block
	ld a, [wMapWidth]
	add 6
	ld e, a
	ld d, 0
	ld hl, wOverworldMapBlocks
	ld a, c
	and a
	jr z, .col
.row
	add hl, de
	dec a
	jr nz, .row
.col
	ld e, b
	ld d, 0
	add hl, de
	ld a, [hl]
	ret

ProcBlockUnderPlayer:
; a = the block the player stands on; b = its column, c = its row
	ld a, [wXCoord]
	srl a
	add 3
	ld b, a
	ld a, [wYCoord]
	srl a
	add 3
	ld c, a
	jr ProcBlockAt

ProcDoorKind:
; 1 on a cave mouth in the world, 2 on the lower ladder of a cave, 3 on its upper ladder, else 0
	ld a, [wMapGroup]
	cp GROUP_PROC_TEST
	jr nz, .none
	ld a, [wMapNumber]
	cp MAP_PROC_TEST
	jr z, .world
	cp MAP_PROC_CAVE
	jr nz, .none
	call ProcBlockUnderPlayer
	cp CAVE_LADDER
	jr nz, .not_low
	ld a, 2
	ret
.not_low
	cp CAVE_LADDER_UP
	jr nz, .none
	ld a, 3
	ret
.world
	call ProcBlockUnderPlayer
	cp CAVE_DOOR
	jr nz, .none
	ld a, 1
	ret
.none
	xor a
	ret

ProcDoorCheck::
; carry when the player has stepped on a door
	call ProcDoorKind
	and a
	ret z
	scf
	ret

ProcPlayerWorld:
; the world block the player stands on: b = u, c = v
	ld a, [wProcChunkX]
	call ProcChunkBase30
	ld b, a
	ld a, [wXCoord]
	srl a
	add 3
	add b
	ld b, a
	ld a, [wProcChunkY]
	call ProcChunkBase27
	ld c, a
	ld a, [wYCoord]
	srl a
	add 3
	add c
	ld c, a
	ret

ProcDoorGo::
; the warp itself
	call ProcDoorKind
	cp 2
	jr z, .low
	cp 3
	jr z, .high
; into the cave. Which mouth? Mouth A has rock to its north.
	call ProcBlockUnderPlayer
	ld a, c
	dec a
	ld c, a
	call ProcBlockAt
	cp PROC_ROCK
	push af
	call ProcPlayerWorld
	pop af
	jr z, .from_a
; mouth B: A is 6 to the north-east
	ld a, b
	add 6
	ld b, a
	ld a, c
	sub 6
	ld c, a
	ld a, b
	ld [wProcRetU], a
	ld a, c
	ld [wProcRetV], a
	ld a, 20
	ld [wXCoord], a
	ld a, 4
	ld [wYCoord], a
	jr .cave
.from_a
	ld a, b
	ld [wProcRetU], a
	ld a, c
	ld [wProcRetV], a
	ld a, 20
	ld [wXCoord], a
	ld a, 30
	ld [wYCoord], a
.cave
	ld a, MAP_PROC_CAVE
	ld [wMapNumber], a
	jr .go
.low
; out of mouth A: one block south of it
	ld a, [wProcRetU]
	ld b, a
	ld a, [wProcRetV]
	inc a
	ld c, a
	jr .leave
.high
; out of mouth B: 6 west and 6 south of A, one block north of it
	ld a, [wProcRetU]
	sub 6
	ld b, a
	ld a, [wProcRetV]
	add 5
	ld c, a
.leave
; b = u, c = v of the block to appear on
	ld a, b
	sub 4
	ld b, a
	ld a, c
	sub 4
	ld c, a
	ld a, c
	ld [G_SY], a
	ld a, b
	ld b, 30
	call ProcDivMod
	ld a, c
	ld [wProcChunkX], a
	ld a, d
	add a
	ld [wXCoord], a
	ld a, [G_SY]
	ld b, 27
	call ProcDivMod
	ld a, c
	ld [wProcChunkY], a
	ld a, d
	add a
	ld [wYCoord], a
	ld a, MAP_PROC_TEST
	ld [wMapNumber], a
.go
	ld a, GROUP_PROC_TEST
	ld [wMapGroup], a
	ld a, SPAWN_N_A
	ld [wDefaultSpawnpoint], a
	ld a, MAPSETUP_WARP
	ldh [hMapEntryMethod], a
	ld a, MAPSTATUS_ENTER
	call LoadMapStatus
	ret

ProcDivMod:
; a / b: c = quotient, d = remainder
	ld c, 0
.loop
	cp b
	jr c, .done
	sub b
	inc c
	jr .loop
.done
	ld d, a
	ret

ProcChunkBase30:
; a = chunk * 30 + 1
	ld c, a
	ld a, 1
	inc c
	jr .start
.add
	add 30
.start
	dec c
	jr nz, .add
	ret

ProcChunkBase27:
	ld c, a
	ld a, 1
	inc c
	jr .start
.add
	add 27
.start
	dec c
	jr nz, .add
	ret

ProcGenCave::
; a little cave from a drunkard's walk, seeded by the mouth it was entered from
	ld hl, wOverworldMapBlocks
	ld bc, CAVE_STRIDE * (CAVE_H + 6)
	ld a, CAVE_WALL
	call ByteFill
	ld a, [wProcRetU]
	ld b, a
	ld a, [wProcRetV]
	ld c, a
	ld d, $c4
	call ProcSeed
	ld a, 10
	ld [G_X], a
	ld a, 15
	ld [G_Y], a
	ld a, 220
	ld [G_I], a
.step
	call ProcCaveCarve
	ld b, 4
	call ProcRandMod
	ld e, a
	ld a, [G_X]
	ld b, a
	ld a, [G_Y]
	ld c, a
	ld a, e
	and a
	jr z, .left
	dec a
	jr z, .right
	dec a
	jr z, .up
; down
	ld a, c
	cp 14
	jr nc, .moved
	inc c
	jr .moved
.left
	ld a, b
	cp 3
	jr c, .moved
	dec b
	jr .moved
.right
	ld a, b
	cp 16
	jr nc, .moved
	inc b
	jr .moved
.up
	ld a, c
	cp 3
	jr c, .moved
	dec c
.moved
	ld a, b
	ld [G_X], a
	ld a, c
	ld [G_Y], a
	ld a, [G_I]
	dec a
	ld [G_I], a
	jr nz, .step
; join the end of the walk to the top ladder
	ld a, [G_X]
	ld b, a
	ld a, [G_Y]
	ld c, a
.hj
	ld a, b
	cp 10
	jr z, .vj
	jr c, .hr
	dec b
	jr .hc
.hr
	inc b
.hc
	push bc
	ld a, b
	ld b, c
	ld e, CAVE_FLOOR
	call ProcCaveSet
	pop bc
	jr .hj
.vj
	ld a, c
	cp 2
	jr c, .vdone
	jr z, .vdone
	dec c
	push bc
	ld a, b
	ld b, c
	ld e, CAVE_FLOOR
	call ProcCaveSet
	pop bc
	jr .vj
.vdone
	ld a, 10
	ld b, 3
	ld e, CAVE_FLOOR
	call ProcCaveSet
	ld a, 10
	ld b, 2
	ld e, CAVE_FLOOR
	call ProcCaveSet
	ld a, 10
	ld b, 1
	ld e, CAVE_LADDER_UP
	call ProcCaveSet
; the ladder out, with floor in front of it
	ld a, 10
	ld b, 16
	ld e, CAVE_LADDER
	call ProcCaveSet
	ld a, 10
	ld b, 15
	ld e, CAVE_FLOOR
	call ProcCaveSet
	ld a, 10
	ld b, 14
	ld e, CAVE_FLOOR
	jp ProcCaveSet

ProcCaveCarve:
; floor on the walker's block and on a neighbour
	ld a, [G_X]
	ld b, a
	ld a, [G_Y]
	ld e, CAVE_FLOOR
	push af
	ld a, b
	ld c, a
	pop af
	ld b, a
	ld a, c
	call ProcCaveSet
	ld b, 2
	call ProcRandMod
	and a
	ret z
	ld a, [G_X]
	inc a
	ld b, a
	ld a, [G_Y]
	ld c, a
	ld a, b
	ld b, c
	ld e, CAVE_FLOOR
	cp 18
	ret nc
	jp ProcCaveSet

ProcCaveSet:
; a = column, b = row (0-based inside the cave), e = block
	push de
	ld c, b
	ld b, a
	ld hl, wOverworldMapBlocks
	ld a, c
	add 3
	ld d, 0
	push bc
	ld c, CAVE_STRIDE
	ld b, a
	and a
	jr z, .col
.row
	ld a, l
	add c
	ld l, a
	jr nc, .nc
	inc h
.nc
	dec b
	jr nz, .row
.col
	pop bc
	ld a, b
	add 3
	add l
	ld l, a
	jr nc, .nc2
	inc h
.nc2
	pop de
	ld [hl], e
	ret
