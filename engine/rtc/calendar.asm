; Salt Crystal: calendar, seasons, weather and the start menu clock.
; The clock itself is ticked in home/time.asm.

InitGameClock::
; New game: it is 6:00 AM on Monday, Jan 1, and the sun is out.
	xor a
	ld [wClockFrames], a
	ld [wClockMinutes], a
	ld [wCalDay], a
	ld [wCalMonth], a
	ld a, 6
	ld [wClockHours], a
	ld a, MONDAY
	ld [wClockDays], a
	ld a, OW_WEATHER_SUNNY
	ld [wWeather], a
	ldh a, [hVBlankCounter]
	ldh [hClockLastVBlank], a
	ld a, LOW(HUNGER_FRAMES)
	ld [wHungerFrames], a
	ld a, HIGH(HUNGER_FRAMES)
	ld [wHungerFrames + 1], a
	xor a
	ld [wHungerWarning], a
	ret

AdvanceGameHour::
; Called each time wClockHours was just incremented.
	ld a, [wClockHours]
	cp MAX_HOUR
	jr c, .same_day
	xor a
	ld [wClockHours], a
	call AdvanceGameDay
.same_day
	ld a, [wClockHours]
.mod
	sub WEATHER_ROLL_HOURS
	jr nc, .mod
	add WEATHER_ROLL_HOURS
	ret nz
	jr RollWeather

AdvanceGameDay:
; The weekday comes from wClockDays, the date from wCalDay/wCalMonth.
	ld a, [wClockDays]
	inc a
	cp RTC_DAY_CYCLE
	jr c, .got_days
	xor a
.got_days
	ld [wClockDays], a

	ld a, [wCalDay]
	inc a
	cp DAYS_PER_MONTH
	jr c, .same_month
	ld a, [wCalMonth]
	inc a
	cp MONTHS_PER_YEAR
	jr c, .got_month
	xor a
.got_month
	ld [wCalMonth], a
	xor a
.same_month
	ld [wCalDay], a
	ret

GetSeason::
; Returns the current season (SEASON_*) in a.
	ld a, [wCalMonth]
	ld b, 0
.loop
	sub MONTHS_PER_SEASON
	jr c, .done
	inc b
	jr .loop
.done
	ld a, b
	ret

RollWeather:
	call GetSeason
	add a ; two threshold bytes per season
	ld e, a
	ld d, 0
	ld hl, WeatherChances
	add hl, de
	call Random
	cp [hl]
	jr c, .sunny
	inc hl
	cp [hl]
	jr c, .cloudy
	ld a, OW_WEATHER_RAINY
	jr .done
.sunny
	ld a, OW_WEATHER_SUNNY
	jr .done
.cloudy
	ld a, OW_WEATHER_CLOUDY
.done
	ld [wWeather], a
	ret

WeatherChances:
; cumulative chance out of 256: sunny below the first value,
; cloudy below the second, rainy otherwise
	db 110, 200 ; spring
	db 170, 235 ; summer
	db  90, 190 ; autumn
	db  80, 210 ; winter

StartMenu_DrawClockBox:
	hlcoord 0, 0
	ld b, 5
	ld c, 7
	call Textbox
	ret

StartMenu_PrintClock:
	ld hl, wOptions
	ld a, [hl]
	push af
	set NO_TEXT_SCROLL, [hl]
	call StartMenu_DrawClockBox

; time, 12-hour clock: 06:00AM
	ldh a, [hHours]
	cp NOON_HOUR
	push af ; carry set = AM
	jr c, .got_hour
	sub NOON_HOUR
.got_hour
	and a
	jr nz, .hour_ok
	ld a, 12
.hour_ok
	ld [wStringBuffer2], a
	hlcoord 1, 1
	ld de, wStringBuffer2
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	ld [hl], ':'
	inc hl
	ld de, hMinutes
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum
	pop af
	ld de, .AMString
	jr c, .got_ampm
	ld de, .PMString
.got_ampm
	call PlaceString

; weekday
	call GetWeekday
	ld hl, .WeekdayStrings
	call GetNthString
	ld d, h
	ld e, l
	hlcoord 1, 3
	call PlaceString

; date: Jan 03
	ld a, [wCalMonth]
	ld hl, .MonthStrings
	call GetNthString
	ld d, h
	ld e, l
	hlcoord 1, 5
	call PlaceString
	ld a, [wCalDay]
	inc a
	ld [wStringBuffer2], a
	hlcoord 5, 5
	ld de, wStringBuffer2
	lb bc, PRINTNUM_LEADINGZEROS | 1, 2
	call PrintNum

	pop af
	ld [wOptions], a
	ret

.AMString: db "AM@"
.PMString: db "PM@"

.WeekdayStrings:
	db "SUN@"
	db "MON@"
	db "TUE@"
	db "WED@"
	db "THU@"
	db "FRI@"
	db "SAT@"

.MonthStrings:
	db "Jan@"
	db "Feb@"
	db "Mar@"
	db "Apr@"
	db "May@"
	db "Jun@"
	db "Jul@"
	db "Aug@"
	db "Sep@"
	db "Oct@"
	db "Nov@"
	db "Dec@"

SaltHungerTick::
; Every party Pokemon (eggs excepted) loses 1 hunger point. The first
; one to cross a warning threshold queues a message.
	ld a, [wPartyCount]
	and a
	ret z
	ld c, a
	ld b, 0
.loop
	push bc
	ld hl, wPartySpecies
	ld e, b
	ld d, 0
	add hl, de
	ld a, [hl]
	cp EGG
	jr z, .next
	ld hl, wPartyMon1 + MON_HUNGER_LOST
	ld a, b
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
; fainted Pokemon don't feel hunger
	push hl
	ld de, MON_HP - MON_HUNGER_LOST
	add hl, de
	ld a, [hli]
	or [hl]
	pop hl
	jr z, .next
	ld a, [hl]
	cp HUNGER_MAX
	jr nc, .starving
	inc a
	ld [hl], a
	ld d, a
	ld a, HUNGER_MAX
	sub d ; hunger left
	ld e, 1
	cp 50
	jr z, .warn
	inc e
	cp 25
	jr z, .warn
	inc e
	cp 10
	jr z, .warn
	inc e
	and a
	jr nz, .next
.warn
	ld a, [wHungerWarning]
	and a
	jr nz, .next
	ld a, e
	ld [wHungerWarning], a
	pop bc
	push bc
	ld a, b
	ld [wHungerWarnMon], a
.next
	pop bc
	inc b
	dec c
	jr nz, .loop
	ret

.starving
; Hunger is gone: lose 1/16 of max HP (at least 1) every tick. At 0 HP
; the Pokemon dies for good, unless it is the last one in the party.
	push hl ; hunger byte
	ld de, MON_HP - MON_HUNGER_LOST
	add hl, de
	ld d, [hl]
	inc hl
	ld e, [hl] ; de = HP
	inc hl
	ld b, [hl]
	inc hl
	ld c, [hl] ; bc = max HP
rept 4
	srl b
	rr c
endr
	ld a, b
	or c
	jr nz, .got_damage
	inc c
.got_damage
	ld a, e
	sub c
	ld e, a
	ld a, d
	sbc b
	ld d, a
	jr c, .die
	or e
	jr z, .die
.store_hp
	pop hl
	ld bc, MON_HP - MON_HUNGER_LOST
	add hl, bc
	ld [hl], d
	inc hl
	ld [hl], e
	jr .next

.die
	ld a, [wPartyCount]
	cp 1
	jr nz, .starved
	ld de, 1 ; the last Pokemon hangs on
	jr .store_hp

.starved
	pop hl
	pop bc ; b = party index
	push bc
	ld a, b
	ld hl, wPartyMonNicknames
	call GetNickname
	ld hl, wStringBuffer1
	ld de, wUnusedMapBuffer
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	pop bc
	push bc
	ld a, b
	ld [wCurPartyMon], a
	xor a ; REMOVE_PARTY
	ld [wPokemonWithdrawDepositParameter], a
	farcall RemoveMonFromPartyOrBox
	ld a, HUNGER_WARNING_DEATH
	ld [wHungerWarning], a
; the next Pokemon slid into this slot, so don't advance the index
	pop bc
	dec c
	jp nz, .loop
	ret

CheckHungerWarning::
; Called with the other overworld time events: starts the warning
; script if a Pokemon got hungry. Returns carry if it did.
	ld a, [wHungerWarning]
	and a
	ret z
	dec a
	ld e, a
	ld d, 0
	ld hl, .Scripts
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld a, [wHungerWarning]
	push af
	xor a
	ld [wHungerWarning], a
	pop af
	cp HUNGER_WARNING_DEATH
	ld hl, wUnusedMapBuffer
	jr z, .got_name
	ld a, [wHungerWarnMon]
	ld hl, wPartyMonNicknames
	call GetNickname
	ld hl, wStringBuffer1
.got_name
; the text engine reuses wStringBuffer1, so keep the name in buffer 3
	ld de, wStringBuffer3
	ld bc, MON_NAME_LENGTH
	call CopyBytes
	pop hl
	ld a, BANK(HungerGrowlScript)
	jp CallScript

.Scripts:
	dw HungerGrowlScript
	dw HungerRumbleScript
	dw HungerWeakScript
	dw HungerStarvingScript
	dw HungerDeathScript

HungerGrowlScript:
	opentext
	writetext HungerGrowlText
	waitbutton
	closetext
	end

HungerRumbleScript:
	opentext
	writetext HungerRumbleText
	waitbutton
	closetext
	end

HungerWeakScript:
	opentext
	writetext HungerWeakText
	waitbutton
	closetext
	end

HungerStarvingScript:
	opentext
	writetext HungerStarvingText
	waitbutton
	closetext
	end

HungerGrowlText:
	text_ram wStringBuffer3
	text "'s belly"
	line "is growling."
	done

HungerRumbleText:
	text_ram wStringBuffer3
	text "'s belly"
	line "rumbles loudly!"
	done

HungerWeakText:
	text_ram wStringBuffer3
	text " looks weak"
	line "from hunger!"
	done

HungerDeathScript:
	opentext
	writetext HungerDeathText
	waitbutton
	closetext
	end

HungerDeathText:
	text_ram wStringBuffer3
	text " starved"
	line "to death..."
	done

HungerStarvingText:
	text_ram wStringBuffer3
	text " is"
	line "starving!"
	done
