PiePRO widget for EdgeTX
========================

This widget provides a simple yet powerfull display of any value as pie chart. Features:
 - uses theme colors
 - display in full screen
 - can display a warning if the value is over/under a given value
 - optionally display a custom label
 - responsive (adapts to different widget sizes)
 - configurable
 - minimal & optimized memory footprint

Installation
============
Copy all contents of this folder to your transmitters SD card to WIDGETS/PiePRO

Configuration
=============
Source: where to get the value to display from. This can be a telemetry value, a variable, a stick or anything else
Label: usefull to see what the displayed value is. Leave empty do not show a label at all
Warn: displays a warning if the value is in a critical range (always in percent)
	0 will disable the warnings
	1 to 100 will trigger the warning if the value is above this value. Example for 80: the warning will show if the value is >= 80% of the max value
	-100 to -1 will trigger the warning if the value is bellow this value as total. Example for -20: the warning will show if the value is <= 20% of the max value
Min/Max: the minimum/maximum expected value. This is used to calculate the percentage for the pie