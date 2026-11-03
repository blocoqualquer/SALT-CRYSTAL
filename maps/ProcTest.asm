; Prototype of a procedurally generated route: the terrain is built from
; a seed every time the map loads (see engine/overworld/proc_map.asm).

ProcTest_MapScripts:
	def_scene_scripts

	def_callbacks

ProcTestLeaveScript:
; only the first chunk has the way home
	readmem wProcChunkX
	iftrue .stay
	readmem wProcChunkY
	iftrue .stay
	warp NEW_BARK_TOWN, 8, 9
.stay
	end

ProcTest_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events
	coord_event 28, 50, -1, ProcTestLeaveScript
	coord_event 29, 50, -1, ProcTestLeaveScript

	def_bg_events

	def_object_events
