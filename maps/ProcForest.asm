; A small procedurally generated forest (see ProcGenForest in engine/overworld/proc_map.asm).
; The ways out are cave-mouth blocks, handled by ProcDoorCheck.

ProcForest_MapScripts:
	def_scene_scripts

	def_callbacks

ProcForest_MapEvents:
	db 0, 0 ; filler

	def_warp_events

	def_coord_events

	def_bg_events

	def_object_events
