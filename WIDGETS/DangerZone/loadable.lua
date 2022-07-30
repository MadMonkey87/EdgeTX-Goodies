---------------------------------------------------------------------------
-- The dynamically loadable part of the Lua widget.                      --
--                                                                       --
-- Author:  Philippe Wechsler                                            --
-- Date:    2022-05-23                                                   --
-- Version: 1.0.0                                                        --
--                                                                       --
-- Copyright (C) EdgeTX                                                  --
--                                                                       --
-- License GPLv2: http://www.gnu.org/licenses/gpl-2.0.html               --
--                                                                       --
-- This program is free software; you can redistribute it and/or modify  --
-- it under the terms of the GNU General Public License version 2 as     --
-- published by the Free Software Foundation.                            --
--                                                                       --
-- This program is distributed in the hope that it will be useful        --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of        --
-- MERCHANTABILITY or FITNESS FOR borderON PARTICULAR PURPOSE. See the   --
-- GNU General Public License for more details.                          --
---------------------------------------------------------------------------

-- Setting up arming:
--  * ensure the throttle source is named 'thr'
--  * choose a switch as throttle cut
--  * choose a logical switch (sticky switch) as pre-arm switch
--  * choose a logical switch (sticky switch) as arm switch which is enabled
--    when throttle cut and the pre-arm switch are on
--  * enable throttle only when the arm switch is on
-- 
-- Arming procedure:
--  * throttle cut & throttle off
--  * go to widget in fullscreen click on pre-arm
--  * use the throttle cut to arm

-- Setting up SxR self check:
--  * choose a logical switch (sticky switch) as self check switch
--  * bind this switch to channel 12

-- Self check procedure:
--  * pre-arm off
--  * go to widget in fullscreen click on self-check

-- Failsafe
--  * setup logical switch (sticky switch)
--  * setup a special function that enables failsafe if the logical switch above is active

local zone, options = ...

local HEADER = 40
local WIDTH  = 100
local COL1   = 10
local TOP    = 44
local ROW    = 28
local HEIGHT = 24
local throttleSource = 'thr'

local widget = { }

local libGUI = loadGUI()

local gui = libGUI.newGUI()
local custom = gui.custom({ }, LCD_W - 34, 6, 28, 28)

function custom.draw(focused)
  lcd.drawRectangle(LCD_W - 34, 6, 28, 28, libGUI.colors.primary2)
  lcd.drawFilledRectangle(LCD_W - 30, 19, 20, 3, libGUI.colors.primary2)
  if focused then
    custom.drawFocus()
  end
end

function custom.onEvent(event, touchState)
  if event == EVT_VIRTUAL_ENTER then
    lcd.exitFullScreen()
  end
end

local function getls(switch)
	if getValue("ls"..switch)== 1024 then
		return true 
	else
		return false
	end
end

local preArmButton
local selfCheckButton
local failsafeButton

local function preArmButtonChanged(button)
  if button.value and getValue(throttleSource) == -1024 and getValue(options.ThrottleCut) < 1000 then
    setStickySwitch(options.PreArmLS-1, button.value)
  else
    setStickySwitch(options.PreArmLS-1, false)
  end
end

local function selfCheckButtonChanged(button)
  setStickySwitch(options.SelfCheckLS-1, button.value)
end

local function failsafeButtonChanged(button)
  setStickySwitch(options.Failsafe-1, button.value)
end

preArmButton = gui.toggleButton(30, TOP + ROW, WIDTH * 2, HEIGHT * 2, "Pre-Arm", false, preArmButtonChanged, nil)
selfCheckButton = gui.toggleButton(480 - 200 - 30, TOP + ROW, WIDTH * 2, HEIGHT * 2, "S8R Self-Check", false, selfCheckButtonChanged, nil)
failsafeButton = gui.toggleButton(480 - 200 - 30, TOP + ROW * 6, WIDTH * 2, HEIGHT * 2, "Failsafe", false, failsafeButtonChanged, nil)

local preArmLabel = gui.label(30, TOP + ROW * 3, WIDTH, HEIGHT, "Pre-Arm: -", nil)
local throttleCutLabel =  gui.label(30, TOP + ROW * 4, WIDTH, HEIGHT, "Throttle Cut: -", nil)
local throttleLabel =  gui.label(30, TOP + ROW * 5, WIDTH, HEIGHT, "Throttle: -", nil)
local armStatusLabel = gui.label(30, TOP + ROW * 6, WIDTH, HEIGHT, "Status: -", BOLD)

local selfCheckStatusLabel = gui.label(480 - 200 - 30, TOP + ROW * 3, WIDTH, HEIGHT, "Status: -", BOLD)
local selfCheckInfoLabel =  gui.label(480 - 200 - 30, TOP + ROW * 4, WIDTH, HEIGHT, "Manually toggle SD Stick", nil)

function gui.fullScreenRefresh()
  local prearm = getls(options.PreArmLS)
  local arm = getls(options.ArmLS)
  local throttleCut = getValue(options.ThrottleCut) == 1024
  local selfcheck = getls(options.SelfCheckLS)
  local throttle = getValue(throttleSource)
  local failsafe = getls(options.Failsafe)

  preArmButton.value = prearm
  preArmButton.disabled = selfcheck or throttle ~=-1024 or throttleCut

  selfCheckButton.value = selfcheck
  selfCheckButton.disabled = prearm or failsafe

  failsafeButton.value = failsafe
  failsafeButton.disabled = selfcheck

  throttleLabel.title = "Throttle: "..tostring(throttle)

  if prearm then
    preArmLabel.title = "Pre-Arm: active"
  else
    preArmLabel.title = "Pre-Arm: inactive"
  end

  if throttleCut then
    throttleCutLabel.title = "Throttle Cut: active"
  else
    throttleCutLabel.title = "Throttle Cut: inactive"
  end

  if arm then
    armStatusLabel.title = "Status: armed"
  else
    armStatusLabel.title = "Status: unarmed"
  end

  if selfcheck then
    selfCheckStatusLabel.title = "Status: active"
  else
    selfCheckStatusLabel.title = "Status: inactive"
  end

  lcd.drawFilledRectangle(0, 0, LCD_W, HEADER, COLOR_THEME_SECONDARY1)
  
  if selfcheck or failsafe then
    lcd.drawText(COL1, HEADER / 2 - 2, "DANGER ZONE", BLINK + VCENTER + DBLSIZE + INVERS + COLOR_THEME_WARNING)
    lcd.drawRectangle(0, HEADER, LCD_W, LCD_H - HEADER, BLINK + COLOR_THEME_WARNING, 5)
  elseif arm then
    lcd.drawText(COL1, HEADER / 2 - 2, "Danger Zone", BLINK + VCENTER + DBLSIZE + INVERS + COLOR_THEME_ACTIVE)
    lcd.drawRectangle(0, HEADER, LCD_W, LCD_H - HEADER, BLINK + COLOR_THEME_ACTIVE, 5)
  else
    lcd.drawText(COL1, HEADER / 2 - 2, "Danger Zone",VCENTER + DBLSIZE + libGUI.colors.primary2)
  end

  lcd.drawRectangle(25, TOP + ROW - 5, WIDTH * 2 + 10, ROW * 6 + 10 + HEIGHT / 2 + 5, COLOR_THEME_SECONDARY1, 1)
  lcd.drawRectangle(480 - 200 - 30 - 5, TOP + ROW - 5, WIDTH * 2 + 10, ROW * 4 + 10, COLOR_THEME_SECONDARY1, 1)

end

function libGUI.widgetRefresh()

  local prearm = getls(options.PreArmLS)
  local arm = getls(options.ArmLS)
  local throttleCut = getValue(options.ThrottleCut) == 1024
  local selfcheck = getls(options.SelfCheckLS)
  local throttle = getValue(throttleSource)
  local failsafe = getls(options.Failsafe)

  if selfcheck then
    lcd.drawText(zone.w / 2, zone.h / 2, "S8R SELF CHECK", BLINK + CENTER + VCENTER + BOLD + COLOR_THEME_WARNING + SHADOWED)
    lcd.drawRectangle(0, 0, zone.w, zone.h, BLINK + COLOR_THEME_WARNING, 10)
  elseif failsafe then
    lcd.drawText(zone.w / 2, zone.h / 2, "FAILSAFE", BLINK + CENTER + VCENTER + BOLD + COLOR_THEME_WARNING + SHADOWED)
    lcd.drawRectangle(0, 0, zone.w, zone.h, BLINK + COLOR_THEME_WARNING, 10)
  elseif arm then
    lcd.drawText(zone.w / 2, zone.h / 2, "ARMED", BLINK + CENTER + VCENTER + BOLD + COLOR_THEME_WARNING + SHADOWED)
    lcd.drawRectangle(0, 0, zone.w, zone.h, BLINK + COLOR_THEME_SECONDARY1, 5)
  elseif prearm then
    lcd.drawText(zone.w / 2, zone.h / 2, "PRE-ARMED", CENTER + VCENTER + BOLD + COLOR_THEME_ACTIVE + SHADOWED)
    lcd.drawRectangle(0, 0, zone.w, zone.h, COLOR_THEME_SECONDARY1, 1)
  else
    lcd.drawText(zone.w / 2, zone.h / 2, "UNARMED", CENTER + VCENTER + BOLD + COLOR_THEME_ACTIVE + SHADOWED)
    --lcd.drawRectangle(0, 0, zone.w, zone.h, COLOR_THEME_SECONDARY1, 1)
  end
end

function widget.background(widget)

end

function widget.refresh(event, touchState)
  gui.run(event, touchState)
end

function widget.update(opt)
	options = opt
end

return widget
