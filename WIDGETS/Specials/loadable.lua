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

local zone, options = ...

local HEADER = 40
local WIDTH  = 100
local COL1   = 10
local TOP    = 44
local ROW    = 28
local HEIGHT = 24

local widget = { }

local libGUI = loadGUI()

local gui = libGUI.newGUI()

local custom = gui.custom({ }, LCD_W - 34, 6, 28, 28)

local LandingLightActive = false
local NavigationLightActive = false

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

local landingLightButton
local navigationLightButton
local bombbayButton
local fireButton

local function landingLightButtonChanged(button)
  setStickySwitch(options.LandingLightLs-1, button.value)
end

local function navigationLightButtonChanged(button)
  setStickySwitch(options.NavigationLightLs-1, button.value)
end

local function bombbayButtonChanged(button)
  setStickySwitch(options.BombayLs-1, button.value)
end

local function fireButtonChanged(button)
  setStickySwitch(options.FireLs-1, button.value)
end

landingLightButton = gui.toggleButton(30, TOP + ROW - 20, WIDTH * 2, HEIGHT * 4, "Landing Lights", false, landingLightButtonChanged, nil)
navigationLightButton = gui.toggleButton(480 - 200 - 30, TOP + ROW -20, WIDTH * 2, HEIGHT * 4, "Navigation Lights", false, navigationLightButtonChanged, nil)
bombbayButton = gui.toggleButton(30, TOP + ROW * 5 - 20, WIDTH * 2, HEIGHT * 4, "Bomb Bay", false, bombbayButtonChanged, nil)
fireButton = gui.toggleButton(480 - 200 - 30, TOP + ROW * 5 -20, WIDTH * 2, HEIGHT * 4, "Fire", false, fireButtonChanged, nil)

function gui.fullScreenRefresh()

  landingLightButton.value = getls(options.LandingLightLs)
  navigationLightButton.value = getls(options.NavigationLightLs)
  bombbayButton.value = getls(options.BombayLs)
  fireButton.value = getls(options.FireLs)

  lcd.drawFilledRectangle(0, 0, LCD_W, HEADER, COLOR_THEME_SECONDARY1)
  lcd.drawText(COL1, HEADER / 2 - 2, "Specials",VCENTER + DBLSIZE + libGUI.colors.primary2)

end

-- Draw in widget mode
function libGUI.widgetRefresh()
	lcd.drawText(zone.w / 2, 2, "Specials", CENTER+BOLD)

	if getls(options.LandingLightLs) then
		lcd.drawFilledRectangle(  5, 25, zone.w - 10, 25, COLOR_THEME_ACTIVE)
    lcd.drawRectangle( 5, 25, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
  else
    lcd.drawFilledRectangle(5, 25, zone.w - 10, 25, libGUI.colors.primary3)
    lcd.drawRectangle(5, 25, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
	end

	if getls(options.NavigationLightLs) then  
		lcd.drawFilledRectangle(5, 55, zone.w - 10, 25, COLOR_THEME_ACTIVE)
    lcd.drawRectangle(5, 55, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
  else
    lcd.drawFilledRectangle(5, 55, zone.w - 10, 25, libGUI.colors.primary3)
    lcd.drawRectangle(5, 55, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
	end

  if getls(options.BombayLs) then  
		lcd.drawFilledRectangle(5, 85, zone.w - 10, 25, COLOR_THEME_ACTIVE)
    lcd.drawRectangle(5, 85, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
  else
    lcd.drawFilledRectangle(5, 85, zone.w - 10, 25, libGUI.colors.primary3)
    lcd.drawRectangle(5, 85, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
	end

  if getls(options.FireLs) then  
		lcd.drawFilledRectangle(5, 115, zone.w - 10, 25, COLOR_THEME_ACTIVE)
    lcd.drawRectangle(5, 115, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
  else
    lcd.drawFilledRectangle(5, 115, zone.w - 10, 25, libGUI.colors.primary3)
    lcd.drawRectangle(5, 115, zone.w - 10, 25, COLOR_THEME_SECONDARY1, 1)
	end

	lcd.drawText(zone.w / 2, 27, "Landing Lights", CENTER + COLOR_THEME_PRIMARY1)
	lcd.drawText(zone.w / 2, 57, "Navigation Lights", CENTER + COLOR_THEME_PRIMARY1)
  lcd.drawText(zone.w / 2, 87, "Bomb Bay", CENTER + COLOR_THEME_PRIMARY1)
  lcd.drawText(zone.w / 2, 117, "Fire", CENTER + COLOR_THEME_PRIMARY1)
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
