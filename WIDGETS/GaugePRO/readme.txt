GaugePRO widget for EdgeTX
===========================

This widget provides a simple way to display the a value as gauge. Features:
 - uses theme colors
 - display in full screen
 - optionally display a custom label
 - responsive (adapts to different widget sizes)
 - configurable

Installation
============
Copy all contents of this folder to your transmitters SD card to WIDGETS/GaugePRO

Configuration
=============
Source: where to get the value to display from. This can be a telemetry value, a variable, a stick or anything else
Label: usefull to see what the displayed value is. Leave empty do not show a label at all
Totalize: many sources can have negative values, i.e. from -100% to 100%. If totalize is enabled this will be shifted to 0% - 100%
Min/Max: the minimum/maximum expected value. This is used to calculate the percentage for the gauge