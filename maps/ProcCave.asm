; A small procedurally generated cave (see ProcGenCave in engine/overworld/proc_map.asm).
; The way out is a ladder block, handled by ProcDoorCheck.

ProcCave_MapScripts:
	def_scene_scripts

	def_callbacks

ProcCave_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events

	def_object_events
