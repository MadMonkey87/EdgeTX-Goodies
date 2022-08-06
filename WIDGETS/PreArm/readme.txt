PreArm widget for EdgeTX
===========================

This widget provides a simple way to operate the engine of your model in a safe way. Usually there is either no or only a very simple throttle cut mechanism. This is basically a switch that enables/disables the controll over the engine. The idea behind is that the engine won't turn on unintendionally. 
This widget extends this simple throttle cut with a pre-arm switch for even better security.

Installation
============
1) Copy all contents of this folder to your transmitters SD card to WIDGETS/PreArm
2) Create a sticky switch (model settings -> logical switches, select an empty one and choose "STCKY" as function). This switch represents the "pre-arm" state
3) Create another logic switch. This one will represent the "arm" state of the engine and should be configured as follows: 
   - function: AND
   - V1: the logical switch you've created in the previous step
   - AND switch: the throttle cut switch in the off position
   the result: this switch is on if the model is pre-armed and if the throttle cut is off
4) Ensure your engine only can get activated if the second switch (the "arm" switch) is active. One way to do so would be using another entry to your "throttle" switch:
   - source: MAX
   - weight: -100%
   - switch: !02 (if the arm-switch you've created above is LS02)
   the result: if the model is not armed, the throttle will be overwritten with -100%

Configuration
=============
 - PreArmLS: the logic switch to control the pre-arm state (the first switch you created above)
 - ArmLS: the logic switch to control the arm state (the second switch you created)
 - ThrottleCut: the switch you want to use to arm/unarm the engine (only works if you've pre-armed the model!)
 - Throttle: the input source you've created to control the throttle of the engine

Usage
=====
1) double tap the widget to open it in fullscreen
2) enable the throttle cut switch and set the throttle to 0%
3) tap the "pre-arm" button
4) your model is now "pre-armed", that means you can use the throttle cut switch to arm/unarm the engine. Enjoy your flight!