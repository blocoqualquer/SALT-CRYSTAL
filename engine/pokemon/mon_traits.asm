; Salt Crystal: per-Pokemon traits and the three new stats pages
; (body, mind, traits) plus the hunger bar on the first page.
;
; Nothing here is stored in the save file. Every trait is derived from
; a CRC of the Pokemon's DVs and ID, so it never changes, works for box
; Pokemon and survives trades. Only hunger will need real storage later.

DEF SALT_ATTR_HEIGHT    EQU 0
DEF SALT_ATTR_WEIGHT    EQU 1
DEF SALT_ATTR_POTENTIAL EQU 2
DEF SALT_ATTR_DRIVE     EQU 3
DEF SALT_ATTR_EGO       EQU 4
DEF SALT_ATTR_SUPEREGO  EQU 5
DEF SALT_ATTR_ALIGNMENT EQU 6
DEF SALT_ATTR_TRAIT     EQU 7
DEF SALT_ATTR_SIGN      EQU 8
DEF SALT_ATTR_TRAITTYPE EQU 9

; wSaltScratch layout
DEF SALT_DEX_HEIGHT EQU 0 ; 2 bytes, little endian (feet * 100 + inches)
DEF SALT_DEX_WEIGHT EQU 2 ; 2 bytes, little endian (tenths of a pound)
DEF SALT_CM         EQU 4 ; 2 bytes, big endian
DEF SALT_KG         EQU 6 ; 2 bytes, big endian (whole kg)
DEF SALT_KG_TENTH   EQU 8
DEF SALT_POTENTIAL  EQU 9
DEF SALT_HUNGER     EQU 10
DEF SALT_HUNGER_MAX EQU 11
DEF SALT_PCT        EQU 12

MACRO fixed_str
; a string padded with zeros to exactly \2 bytes (including the '@')
.start\@
	db \1, "@"
	ds \2 - (@ - .start\@)
ENDM

MACRO trait
; name (12 chars max), two description lines (13 chars max each)
	fixed_str \1, 13
	fixed_str \2, 14
	fixed_str \3, 14
ENDM

SaltHashAttr:
; Hash wTempMon's DVs and ID together with the attribute id in a.
; Returns the 16-bit CRC in de. Preserves hl.
	push bc
	ld c, a
	ld de, $ffff
	ld a, [wTempMonDVs]
	call .byte
	ld a, [wTempMonDVs + 1]
	call .byte
	ld a, [wTempMonID]
	call .byte
	ld a, [wTempMonID + 1]
	call .byte
	ld a, c
	call .byte
	pop bc
	ret

.byte
	xor d
	ld d, a
	ld b, 8
.bit
	sla e
	rl d
	jr nc, .no_poly
	ld a, d
	xor $10
	ld d, a
	ld a, e
	xor $21
	ld e, a
.no_poly
	dec b
	jr nz, .bit
	ret

SaltMod:
; a = a mod b
	cp b
	ret c
	sub b
	jr SaltMod

SaltGetAttr:
; Return in a the attribute (id in a) reduced mod b.
	call SaltHashAttr
	ld a, d
	jr SaltMod

SaltPlaceDivider:
; Vertical divider at x = 6, rows 8-17.
	hlcoord 6, 8
	ld de, SCREEN_WIDTH
	ld b, 10
	ld a, $31 ; vertical divider
.loop
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop
	ret

SaltComputeBody:
; Work out height (cm), weight (kg) and potential for wTempMon.
; All the math is done before anything is printed, since PrintNum
; shares its scratch space with the multiply and divide routines.
	ld a, [wCurSpecies]
	ld b, a
	farcall GetDexEntryPointer ; b:de = entry
	ld h, d
	ld l, e
	ld c, b
.skip_category
	ld a, c
	call GetFarByte
	inc hl
	cp '@'
	jr nz, .skip_category
	ld a, c
	call GetFarByte
	ld [wSaltScratch + SALT_DEX_HEIGHT], a
	inc hl
	ld a, c
	call GetFarByte
	ld [wSaltScratch + SALT_DEX_HEIGHT + 1], a
	inc hl
	ld a, c
	call GetFarByte
	ld [wSaltScratch + SALT_DEX_WEIGHT], a
	inc hl
	ld a, c
	call GetFarByte
	ld [wSaltScratch + SALT_DEX_WEIGHT + 1], a

; height: 85-115% of the species average
	ld a, SALT_ATTR_HEIGHT
	ld b, 31
	call SaltGetAttr
	add 85
	ld [wSaltScratch + SALT_PCT], a

	ld a, [wSaltScratch + SALT_DEX_HEIGHT + 1]
	ld h, a
	ld a, [wSaltScratch + SALT_DEX_HEIGHT]
	ld l, a
	ld b, 0 ; feet
.feet
	ld a, h
	and a
	jr nz, .minus_100
	ld a, l
	cp 100
	jr c, .got_feet
.minus_100
	ld de, -100
	add hl, de
	inc b
	jr .feet
.got_feet
	ld c, l ; leftover inches
	ld hl, 0
	ld de, 12
	ld a, b
	and a
	jr z, .no_feet
.twelve
	add hl, de
	dec a
	jr nz, .twelve
.no_feet
	ld e, c
	ld d, 0
	add hl, de ; hl = total inches

	xor a
	ldh [hMultiplicand + 0], a
	ld a, h
	ldh [hMultiplicand + 1], a
	ld a, l
	ldh [hMultiplicand + 2], a
	ld a, 254 ; 2.54 cm per inch, times 100
	ldh [hMultiplier], a
	call Multiply
	ld a, [wSaltScratch + SALT_PCT]
	ldh [hMultiplier], a
	call Multiply
	ld a, 100
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ld a, 100
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hQuotient + 2]
	ld [wSaltScratch + SALT_CM], a
	ldh a, [hQuotient + 3]
	ld [wSaltScratch + SALT_CM + 1], a

; weight: 80-120% of the species average
	ld a, SALT_ATTR_WEIGHT
	ld b, 41
	call SaltGetAttr
	add 80
	ld [wSaltScratch + SALT_PCT], a

	xor a
	ldh [hMultiplicand + 0], a
	ld a, [wSaltScratch + SALT_DEX_WEIGHT + 1]
	ldh [hMultiplicand + 1], a
	ld a, [wSaltScratch + SALT_DEX_WEIGHT]
	ldh [hMultiplicand + 2], a
	ld a, [wSaltScratch + SALT_PCT]
	ldh [hMultiplier], a
	call Multiply
	ld a, 100
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ld a, 116 ; about 0.4536 kg per pound, as 116 / 256
	ldh [hMultiplier], a
	call Multiply
	ldh a, [hProduct + 1]
	ld d, a
	ldh a, [hProduct + 2]
	ld e, a ; de = tenths of a kg
	xor a
	ldh [hDividend + 0], a
	ldh [hDividend + 1], a
	ld a, d
	ldh [hDividend + 2], a
	ld a, e
	ldh [hDividend + 3], a
	ld a, 10
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hQuotient + 2]
	ld [wSaltScratch + SALT_KG], a
	ldh a, [hQuotient + 3]
	ld [wSaltScratch + SALT_KG + 1], a
	ldh a, [hRemainder]
	ld [wSaltScratch + SALT_KG_TENTH], a

; potential
	ld a, SALT_ATTR_POTENTIAL
	ld b, 3
	call SaltGetAttr
	ld [wSaltScratch + SALT_POTENTIAL], a
	ret

SaltLoadBodyPage::
	call SaltComputeBody
	call SaltPlaceDivider

	ld de, .BodyStatsString
	hlcoord 0, 9
	call PlaceString
	ld de, .HeightString
	hlcoord 7, 9
	call PlaceString
	ld de, .WeightString
	hlcoord 7, 11
	call PlaceString
	ld de, .PotentialString
	hlcoord 7, 16
	call PlaceString

	hlcoord 14, 9
	ld de, wSaltScratch + SALT_CM
	lb bc, PRINTNUM_LEFTALIGN | 2, 4
	call PrintNum
	ld de, .CmString
	call PlaceString

	hlcoord 14, 11
	ld de, wSaltScratch + SALT_KG
	lb bc, PRINTNUM_LEFTALIGN | 2, 3
	call PrintNum
; from 100 kg up the decimal would run off the screen, so drop it
	ld a, [wSaltScratch + SALT_KG]
	and a
	jr nz, .no_tenth
	ld a, [wSaltScratch + SALT_KG + 1]
	cp 100
	jr nc, .no_tenth
	ld [hl], '.'
	inc hl
	ld a, [wSaltScratch + SALT_KG_TENTH]
	add '0'
	ld [hli], a
.no_tenth
	ld de, .KgString
	call PlaceString

	ld a, [wSaltScratch + SALT_POTENTIAL]
	ld hl, .PotentialNames
	ld bc, 7
	call AddNTimes
	ld d, h
	ld e, l
	hlcoord 14, 16
	call PlaceString
	ret

.BodyStatsString:
	db   "BODY"
	next "STATS@"
.HeightString:
	db "HEIGHT@"
.WeightString:
	db "WEIGHT@"
.PotentialString:
	db "PTC@"
.CmString:
	db "cm@"
.KgString:
	db "kg@"

.PotentialNames:
	fixed_str "Speedy", 7
	fixed_str "Brute", 7
	fixed_str "Tanky", 7

SaltLoadMindPage::
	ld de, .DriveString
	hlcoord 0, 9
	call PlaceString
	ld de, .EgoString
	hlcoord 0, 11
	call PlaceString
	ld de, .SuperegoString
	hlcoord 0, 13
	call PlaceString
	ld de, .AlignmentString
	hlcoord 0, 16
	call PlaceString

	ld a, SALT_ATTR_DRIVE
	hlcoord 9, 9
	call .PlaceLevel
	ld a, SALT_ATTR_EGO
	hlcoord 9, 11
	call .PlaceLevel
	ld a, SALT_ATTR_SUPEREGO
	hlcoord 9, 13
	call .PlaceLevel

	ld a, SALT_ATTR_ALIGNMENT
	ld b, 9
	call SaltGetAttr
	ld hl, .AlignmentNames
	ld bc, 3
	call AddNTimes
	ld d, h
	ld e, l
	hlcoord 17, 16
	call PlaceString
	ret

.PlaceLevel:
	push hl
	ld b, 3
	call SaltGetAttr
	ld hl, .LevelNames
	ld bc, 7
	call AddNTimes
	ld d, h
	ld e, l
	pop hl
	call PlaceString
	ret

.DriveString:
	db "DRIVE@"
.EgoString:
	db "EGO@"
.SuperegoString:
	db "SUPEREGO@"
.AlignmentString:
	db "ALIGNMENT@"

.LevelNames:
	fixed_str "Low", 7
	fixed_str "Medium", 7
	fixed_str "High", 7

.AlignmentNames:
; law (L, N, C) by good (G, N, E)
	fixed_str "LG", 3
	fixed_str "LN", 3
	fixed_str "LE", 3
	fixed_str "NG", 3
	fixed_str "TN", 3
	fixed_str "NE", 3
	fixed_str "CG", 3
	fixed_str "CN", 3
	fixed_str "CE", 3

SaltLoadTraitsPage::
	call SaltPlaceDivider
	ld de, .TraitsString
	hlcoord 0, 9
	call PlaceString
	ld de, .SignString
	hlcoord 0, 16
	call PlaceString

; Traits come from the Pokemon's type: a hash bit picks which of its
; two types, another bit picks which of that type's two traits.
	ld a, [wCurSpecies]
	ld [wCurSpecies], a
	call GetBaseData
	ld a, SALT_ATTR_TRAITTYPE
	call SaltHashAttr
	ld a, [wBaseType1]
	bit 0, d
	jr z, .got_type
	ld a, [wBaseType2]
.got_type
	call SaltTypeToGroup
	add a ; two traits per group
	ld [wSaltScratch + SALT_PCT], a
	ld a, SALT_ATTR_TRAIT
	ld b, 2
	call SaltGetAttr
	ld b, a
	ld a, [wSaltScratch + SALT_PCT]
	add b
	ld hl, SaltTraitTable
	ld bc, 13 + 14 + 14
	call AddNTimes
; PlaceString leaves de on the terminator, so keep the entry base in hl
	push hl
	ld d, h
	ld e, l
	hlcoord 7, 9
	call PlaceString
	pop hl
	ld de, 13
	add hl, de
	push hl
	ld d, h
	ld e, l
	hlcoord 7, 11
	call PlaceString
	pop hl
	ld de, 14
	add hl, de
	ld d, h
	ld e, l
	hlcoord 7, 13
	call PlaceString

	ld a, SALT_ATTR_SIGN
	ld b, 12
	call SaltGetAttr
	ld hl, SaltSignNames
	ld bc, 12
	call AddNTimes
	ld d, h
	ld e, l
	hlcoord 7, 16
	call PlaceString
	ret

.TraitsString:
	db "TRAITS@"
.SignString:
	db "SIGN@"

SaltTypeToGroup:
; a = type constant, returns a = 0-17 (see SaltTraitTable)
	cp 10
	ret c ; NORMAL to STEEL
	cp FIRE
	jr c, .none ; unused types
	sub FIRE - 10 ; FIRE to DARK
	cp 18
	ret c
.none
	xor a
	ret

SaltSignNames:
	fixed_str "ARIES", 12
	fixed_str "TAURUS", 12
	fixed_str "GEMINI", 12
	fixed_str "CANCER", 12
	fixed_str "LEO", 12
	fixed_str "VIRGO", 12
	fixed_str "LIBRA", 12
	fixed_str "SCORPIO", 12
	fixed_str "SAGITTARIUS", 12
	fixed_str "CAPRICORN", 12
	fixed_str "AQUARIUS", 12
	fixed_str "PISCES", 12

SaltTraitTable:
; two traits per type group: NORMAL, FIGHTING, FLYING, POISON, GROUND,
; ROCK, BIRD (unused), BUG, GHOST, STEEL, FIRE, WATER, GRASS, ELECTRIC,
; PSYCHIC, ICE, DRAGON, DARK
	trait "BLANDPOWER", "Good at being", "average."
	trait "HOMESTEAD", "Loves a quiet", "night in."
	trait "KNUCKLEDUST", "Hits first,", "asks later."
	trait "BRAWLSONG", "Sings while", "swinging."
	trait "WINDRIDER", "Naps on", "updrafts."
	trait "HIGHSTRUNG", "Prefers high", "places."
	trait "SLOWBREW", "Gets nastier", "as it brews."
	trait "TOXICSCENT", "Smells worse", "when happy."
	trait "DIRTLOVER", "Hates being", "clean."
	trait "DEEPROOTS", "Hard to move", "if stubborn."
	trait "STONEWALL", "Never argues,", "just sits."
	trait "PEBBLEPRIDE", "Brags about", "its pebbles."
	trait "WINDRIDER", "Naps on", "updrafts."
	trait "HIGHSTRUNG", "Prefers high", "places."
	trait "HIVEMIND", "Hums when in", "a crowd."
	trait "SILKYWORRY", "Spins when", "nervous."
	trait "NIGHTCHAT", "Chats with", "no one."
	trait "COLDSPOT", "Makes rooms", "oddly chilly."
	trait "IRONNERVES", "Rusts if it", "worries."
	trait "CLANGHEART", "Rings when", "excited."
	trait "SOLARPOWER", "Goofs in", "the sun."
	trait "EMBERMOOD", "Warm when", "it is liked."
	trait "RAINSONG", "Hums when it", "drizzles."
	trait "TIDEWALKER", "Restless near", "the sea."
	trait "SUNBATHER", "Soaks up sun", "like gossip."
	trait "ROOTWHISPER", "Chats with", "old trees."
	trait "STATICHUG", "Shocks those", "it loves."
	trait "SPARKFEVER", "Twitchy on", "stormy days."
	trait "DAYDREAMER", "Stares at", "nothing."
	trait "MINDDRIFT", "Forgets why", "it came."
	trait "COLDSHOULDER", "Ignores you", "on purpose."
	trait "FROSTLACE", "Sparkles when", "proud."
	trait "TAILPRIDE", "Guards its", "tail."
	trait "ANCIENTSIGH", "Sighs like an", "old tale."
	trait "MOONLIT", "Brightens up", "after dark."
	trait "SHADYDEAL", "Trades favors", "for snacks."

; --- hunger -------------------------------------------------------------

SaltGetHunger:
; Hunger of the Pokemon being shown, 0-100.
; The party struct stores how much hunger was lost (0 = full).
	ld a, [wTempMon + MON_HUNGER_LOST]
	cp HUNGER_MAX
	jr c, .ok
	ld a, HUNGER_MAX
.ok
	ld b, a
	ld a, HUNGER_MAX
	sub b
	ret

SaltDrawHungerBar::
; Hunger bar at rows 10-11 of the first page.
	ld de, SaltHungerLabelGFX
	ld hl, vTiles2 tile $42
	lb bc, BANK(SaltHungerLabelGFX), 1
	call Get2bppViaHDMA

	call SaltGetHunger
	ld [wSaltScratch + SALT_HUNGER], a
	ld a, 100
	ld [wSaltScratch + SALT_HUNGER_MAX], a

; pixels = hunger * 48 / 100
	xor a
	ldh [hMultiplicand + 0], a
	ldh [hMultiplicand + 1], a
	ld a, [wSaltScratch + SALT_HUNGER]
	ldh [hMultiplicand + 2], a
	ld a, 48
	ldh [hMultiplier], a
	call Multiply
	ld a, 100
	ldh [hDivisor], a
	ld b, 4
	call Divide
	ldh a, [hQuotient + 3]
	ld e, a
	ld d, 6 ; bar length in tiles
	ld b, 0
	ld a, [wSaltScratch + SALT_HUNGER]
	ld c, a
	hlcoord 0, 10
	call DrawBattleHPBar
	hlcoord 1, 10
	ld [hl], $42 ; "G:" instead of "P:"

	hlcoord 1, 11
	ld de, wSaltScratch + SALT_HUNGER
	lb bc, 1, 3
	call PrintNum
	ld [hl], '/'
	inc hl
	ld de, wSaltScratch + SALT_HUNGER_MAX
	lb bc, 1, 3
	call PrintNum
	ret

SaltHungerLabelGFX:
; the "P:" half of the HP label, redrawn as "G:"
	db $00, $00, $ff, $ff, $ff, $1b, $ff, $7f
	db $ff, $5f, $ff, $1b, $ff, $ff, $00, $00
