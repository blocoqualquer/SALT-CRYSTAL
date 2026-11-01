; Boolean checks
DEF FALSE EQU 0
DEF TRUE  EQU 1

; genders
DEF MALE   EQU 0
DEF FEMALE EQU 1

; input
DEF NO_INPUT EQU %00000000

; FlagAction arguments (see home/flag.asm)
	const_def
	const RESET_FLAG
	const SET_FLAG
	const CHECK_FLAG

; G/S version ID: 0 = Gold, 1 = Silver (used by checkver)
; Mystery Gift uses incremented values 1 and 2
DEF GS_VERSION EQU 0
; Pokémon Pikachu 2, a step counter / virtual pet device (used by Mystery Gift)
DEF POKEMON_PIKACHU_2_VERSION EQU 3
DEF RESERVED_GAME_VERSION EQU 4

; save file corruption check values
DEF SAVE_CHECK_VALUE_1 EQU 99
DEF SAVE_CHECK_VALUE_2 EQU 127

; RTC halted check value
DEF RTC_HALT_VALUE EQU $1234

; the RTC day count wraps after 20 weeks, preserving the day of the week
DEF RTC_DAY_CYCLE EQU 20 * 7

; Salt Crystal: the in-game clock replaces the cartridge RTC.
; 50 frames = 1 game minute, so 1 game day is about 20 real minutes.
DEF FRAMES_PER_GAME_MINUTE EQU 50

; Salt Crystal: calendar (12 months x 28 days = 336 days = 48 weeks)
DEF DAYS_PER_MONTH   EQU 28
DEF MONTHS_PER_YEAR  EQU 12
DEF MONTHS_PER_SEASON EQU 3

	const_def
	const SEASON_SPRING ; Jan-Mar
	const SEASON_SUMMER ; Apr-Jun
	const SEASON_AUTUMN ; Jul-Sep
	const SEASON_WINTER ; Oct-Dec
DEF NUM_SEASONS EQU const_value

	const_def
	const OW_WEATHER_SUNNY
	const OW_WEATHER_CLOUDY
	const OW_WEATHER_RAINY
DEF NUM_OW_WEATHERS EQU const_value

; weather is re-rolled every this many game hours
DEF WEATHER_ROLL_HOURS EQU 3

; time of day boundaries
DEF MORN_HOUR EQU 4  ; 4 AM
DEF DAY_HOUR  EQU 10 ; 10 AM
DEF NITE_HOUR EQU 18 ; 6 PM
DEF NOON_HOUR EQU 12 ; 12 PM
DEF MAX_HOUR  EQU 24 ; 12 AM

; significant money values
DEF START_MONEY EQU 3000
DEF MOM_MONEY   EQU 2300
DEF MAX_MONEY   EQU 999999
DEF MAX_COINS   EQU 9999

; link record
DEF MAX_LINK_RECORD EQU 9999

; day-care
DEF MAX_DAY_CARE_EXP EQU $500000

; hall of fame
DEF HOF_MASTER_COUNT EQU 200

; card flip
DEF CARDFLIP_DECK_SIZE EQU 4 * 6

; SGB command MLT_REQ can be used to detect SGB hardware
DEF JOYP_SGB_MLT_REQ EQU %00000011
