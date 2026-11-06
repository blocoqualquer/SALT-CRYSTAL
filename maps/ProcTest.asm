; Prototype of a procedurally generated route: the terrain is built from
; a seed every time the map loads (see engine/overworld/proc_map.asm).

ProcTest_MapScripts:
	def_scene_scripts

	def_callbacks

ProcTestLeaveScript:
; only the start chunk has the way home
	readmem wProcChunkX
	ifnotequal 4, .stay
	readmem wProcChunkY
	ifnotequal 4, .stay
	warp NEW_BARK_TOWN, 8, 9
.stay
	end

ProcDoorScript::
	callasm ProcDoorGo
	end

ProcTest_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events
	coord_event 20, 45, -1, ProcTestLeaveScript
	coord_event 21, 45, -1, ProcTestLeaveScript

	def_bg_events

	def_object_events
