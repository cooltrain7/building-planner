extends Node

signal on_build_data_ready(buildables: Array[Buildable])

## Building events
signal on_build_place(build: Buildable, tier: int)
signal on_build_remove(build: Buildable, tier: int)
signal on_build_overlap_change(overlap: bool)

## UI events
## Fires when a buildable is changed via the UI
signal on_build_change(build: Buildable, ui_element: StructPanelItem)
