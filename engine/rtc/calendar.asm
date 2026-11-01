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
