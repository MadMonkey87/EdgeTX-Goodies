ValuePRO widget for EdgeTX
==========================

This widget provides a simple way to display a value, i.e. a telemetry sensor reading. Features:
 - uses theme colors
 - display in full screen
 - optionally display a custom label
 - renders appropriate units if applicable
 - render raw value or display as percentage
 - responsive (adapts to different widget sizes)
 - configurable

Installation
============
Copy all contents of this folder to your transmitters SD card to WIDGETS/ValuePRO

Configuration
=============
Source: where to get the value to display from. This can be a telemetry value, a variable, a stick or anything else
Label: usefull to see what the displayed value is. Leave empty do not show a label at all
Percent: display the value as percentage instead of the raw reading. Needs Min/Max to be set correctly
Min/Max: the minimum/maximum expected value. This is used to calculate the percentage for the gauge