Warnings widget for EdgeTX
===========================

This widget renders a status indicator and shows current warnings and errors. Features:
 - uses theme colors
 - display in full screen
 - responsive (adapts to different widget sizes)
 - configurable

Note: this widget currently might not be for everyone as you need to adapt it manually for your own warnings (see below).

Installation & configuration
============================
1) Copy all contents of this folder to your transmitters SD card to WIDGETS/Warnings
2) Adapt the script "loadable.lua" for your own warnings (at line 45):
	 - the table "warnings" defines what warnings there are, what severity they have and when they are active
	 - name: the text to be displayed
	 - switch: the logic switch that indicates if the warning is currently active or not
	 - level: the severity of the entry. 2 = error, 1 = warning
3) Create the appropriate logic switches