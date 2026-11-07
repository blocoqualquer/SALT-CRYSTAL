; A procedurally generated town (see ProcGenCity in engine/overworld/proc_map.asm).
; The way out is a red-mat block, handled by ProcDoorCheck.

ProcCity_MapScripts:
	def_scene_scripts

	def_callbacks

ProcCity_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events

	def_object_events
