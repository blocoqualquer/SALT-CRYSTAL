; Functions relating to the timer interrupt and the real-time-clock.

Timer:: ; unreferenced
	push af
	ldh a, [hMobile]
	and a
	jr z, .not_mobile
	call MobileTimer

.not_mobile
	pop af
	reti

LatchClock::
; latch clock counter data
	ld a, 0
	ld [rRTCLATCH], a
	ld a, 1
	ld [rRTCLATCH], a
	ret

UpdateTime::
	call GetClock
	call FixDays
	call FixTime
	farcall GetTimeOfDay
	ret

GetClock::
; Salt Crystal: the cartridge RTC is no longer used.
; store the in-game clock in hRTCDayHi-hRTCSeconds
	xor a
	ldh [hRTCDayHi], a
	ld a, [wClockDays]
	ldh [hRTCDayLo], a
	ld a, [wClockHours]
	ldh [hRTCHours], a
	ld a, [wClockMinutes]
	ldh [hRTCMinutes], a

; seconds = frames * 6 / 5 (50 frames make 60 seconds)
	ld a, [wClockFrames]
	ld c, a
	ld b, 0
.div5
	sub 5
	jr c, .done
	inc b
	jr .div5
.done
	ld a, c
	add b
	ldh [hRTCSeconds], a
	ret

TickGameClock::
; Advance the in-game clock by the frames elapsed since the last call.
; This is only called from the overworld loop, so the clock stands
; still in menus, battles and text boxes.
	ldh a, [hVBlankCounter]
	ld b, a
	ldh a, [hClockLastVBlank]
	ld c, a
	ld a, b
	ldh [hClockLastVBlank], a
	sub c
	ret z
; after a long pause (menu, battle) only count one frame
	cp 5
	jr c, .count
	ld a, 1
.count
	ld b, a
.loop
	call AdvanceClockFrame
	call AdvanceHungerFrame
	dec b
	jr nz, .loop
	ret

AdvanceHungerFrame:
; Count down to the next hunger tick (bc is preserved).
	ld hl, wHungerFrames
	ld a, [hl]
	sub 1
	ld [hli], a
	ld a, [hl]
	sbc 0
	ld [hl], a
	ret nc
	ld hl, wHungerFrames
	ld a, LOW(HUNGER_FRAMES)
	ld [hli], a
	ld [hl], HIGH(HUNGER_FRAMES)
	farcall SaltHungerTick
	ret

AdvanceClockFrame:
	ld hl, wClockFrames
	inc [hl]
	ld a, [hl]
	cp FRAMES_PER_GAME_MINUTE
	ret c
	ld [hl], 0
	ld hl, wClockMinutes
	inc [hl]
	ld a, [hl]
	cp 60
	ret c
	ld [hl], 0
	ld hl, wClockHours
	inc [hl]
	push bc
	farcall AdvanceGameHour
	pop bc
	ret

FixDays::
; fix day count
; mod by 140

; check if day count > 255 (bit 8 set)
	ldh a, [hRTCDayHi] ; DH
	bit B_RTCREG_DH_HIGH, a
	jr z, .daylo
; reset dh (bit 8)
	res B_RTCREG_DH_HIGH, a
	ldh [hRTCDayHi], a

; mod 140
; mod twice since bit 8 (DH) was set
	ldh a, [hRTCDayLo]
.modh
	sub RTC_DAY_CYCLE
	jr nc, .modh
.modl
	sub RTC_DAY_CYCLE
	jr nc, .modl
	add RTC_DAY_CYCLE

; update dl
	ldh [hRTCDayLo], a

; flag for sRTCStatusFlags
	ld a, RTC_DAYS_EXCEED_255
	jr .set

.daylo
; quit if fewer than 140 days have passed
	ldh a, [hRTCDayLo]
	cp RTC_DAY_CYCLE
	jr c, .quit

; mod 140
.mod
	sub RTC_DAY_CYCLE
	jr nc, .mod
	add RTC_DAY_CYCLE

; update dl
	ldh [hRTCDayLo], a

; flag for sRTCStatusFlags
	ld a, RTC_DAYS_EXCEED_139

.set
; update clock with modded day value
	push af
	call SetClock
	pop af
	scf
	ret

.quit
	xor a
	ret

FixTime::
; add ingame time (set at newgame) to current time
; store time in wCurDay, hHours, hMinutes, hSeconds

; second
	ldh a, [hRTCSeconds]
	ld c, a
	ld a, [wStartSecond]
	add c
	sub 60
	jr nc, .updatesec
	add 60
.updatesec
	ldh [hSeconds], a

; minute
	ccf ; carry is set, so turn it off
	ldh a, [hRTCMinutes]
	ld c, a
	ld a, [wStartMinute]
	adc c
	sub 60
	jr nc, .updatemin
	add 60
.updatemin
	ldh [hMinutes], a

; hour
	ccf ; carry is set, so turn it off
	ldh a, [hRTCHours]
	ld c, a
	ld a, [wStartHour]
	adc c
	sub 24
	jr nc, .updatehr
	add 24
.updatehr
	ldh [hHours], a

; day
	ccf ; carry is set, so turn it off
	ldh a, [hRTCDayLo]
	ld c, a
	ld a, [wStartDay]
	adc c
	ld [wCurDay], a
	ret

InitTimeOfDay::
	xor a
	ld [wStringBuffer2], a
	ld a, 0 ; useless
	ld [wStringBuffer2 + 3], a
	jr InitTime

InitDayOfWeek::
	call UpdateTime
	ldh a, [hHours]
	ld [wStringBuffer2 + 1], a
	ldh a, [hMinutes]
	ld [wStringBuffer2 + 2], a
	ldh a, [hSeconds]
	ld [wStringBuffer2 + 3], a
	jr InitTime ; useless

InitTime::
	farcall _InitTime
	ret

ClearClock::
	call .ClearhRTC
	call SetClock
	ret

.ClearhRTC:
	xor a
	ldh [hRTCSeconds], a
	ldh [hRTCMinutes], a
	ldh [hRTCHours], a
	ldh [hRTCDayLo], a
	ldh [hRTCDayHi], a
	ret

SetClock::
; Salt Crystal: set the in-game clock from hram
	ldh a, [hRTCDayLo]
	ld [wClockDays], a
	ldh a, [hRTCHours]
	ld [wClockHours], a
	ldh a, [hRTCMinutes]
	ld [wClockMinutes], a
	xor a
	ld [wClockFrames], a
	ret

ClearRTCStatus:: ; unreferenced
; clear sRTCStatusFlags
	xor a
	push af
	ld a, BANK(sRTCStatusFlags)
	call OpenSRAM
	pop af
	ld [sRTCStatusFlags], a
	call CloseSRAM
	ret

RecordRTCStatus::
; append flags to sRTCStatusFlags
	ld hl, sRTCStatusFlags
	push af
	ld a, BANK(sRTCStatusFlags)
	call OpenSRAM
	pop af
	or [hl]
	ld [hl], a
	call CloseSRAM
	ret

CheckRTCStatus::
; check sRTCStatusFlags
	ld a, BANK(sRTCStatusFlags)
	call OpenSRAM
	ld a, [sRTCStatusFlags]
	call CloseSRAM
	ret
