---------------------------------------------------------------------------
-- The dynamically loadable part of the Lua widget.                      --
--                                                                       --
-- Author:  Philippe Wechsler                                            --
-- Date:    2022-07-11                                                   --
-- Version: 1.0.0                                                        --
-- Source: https://github.com/MadMonkey87/EdgeTX-Goodies                 --
--                                                                       --
-- Copyright (C) Philippe Wechsler                                       --
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
local COL1   = 10
local HEIGHT = 24
local trafficLightMargin = 8
local trafficLightPadding = 10

local widget = { }

local libGUI = loadGUI()

local gui = libGUI.newGUI()
local custom = gui.custom({ }, LCD_W - 34, 6, 28, 28)

local currentColor = WHITE
local activeWarnings = {}
local highestLevel = 0
local warningCount = 0
local errorCount = 0

-- level 2 = red,  1 = yellow
local warnings = {
  { name = "Battery Critical", switch = 4, level = 2 },
  { name = "Failsafe", switch = 27, level = 2 },
  { name = "Flaps Warning", switch = 5, level = 1 },
  { name = "Gear Warning", switch = 6, level = 1 },
  { name = "Low Battery", switch = 2, level = 1 },
  { name = "High Consumption", switch = 7, level = 1 },
  { name = "Low Rates", switch = 8, level = 1 }
}	

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

local function calculate()
  highestLevel = 0
  activeWarnings = {}

  for key, value in pairs(warnings) do
    if getls(value.switch) then
      highestLevel = math.max(highestLevel, value.level)
      table.insert(activeWarnings, { name = value.name, level = value.level })
    end
  end

  if (highestLevel >= 2) then
    currentColor = RED
    errorCount = errorCount + 1
  elseif (highestLevel == 1) then
    currentColor = YELLOW
    warningCount = warningCount + 1
  else
    currentColor = GREEN
  end
end

local function render(x, y, w, h, textSize, textOffset, textMargin)
  local radius = (h -(2*trafficLightMargin) -(3*trafficLightPadding)) / 3 / 2

  if (highestLevel >= 2) then
    lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius, 0, radius, 0,360, options.Red)
  else
    lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius, 0, radius, 0,360, COLOR_THEME_PRIMARY3)
  end
  lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius, radius, radius + 3, 0,360, COLOR_THEME_FOCUS)


  if (highestLevel == 1) then
    lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius*3+trafficLightPadding, 0, radius, 0,360, options.Yellow)
  else
    lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius*3+trafficLightPadding, 0, radius, 0,360, COLOR_THEME_PRIMARY3)
  end
  lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius*3+trafficLightPadding, radius, radius + 3, 0,360, COLOR_THEME_FOCUS)


  if (highestLevel <=0 ) then
    lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius*5+trafficLightPadding*2, 0, radius, 0,360, options.Green)
  else
    lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius*5+trafficLightPadding*2, 0, radius, 0,360, COLOR_THEME_PRIMARY3)
  end
  lcd.drawAnnulus(x + w - trafficLightMargin - radius - trafficLightPadding/2, y + trafficLightPadding/2 + trafficLightMargin+radius*5+trafficLightPadding*2, radius, radius + 3, 0,360, COLOR_THEME_FOCUS)

  if (highestLevel <= 0) then
    lcd.drawText((x + w - trafficLightMargin - 2*radius)/2, y + h / 2, "No Warnings", VCENTER + CENTER + BOLD + SHADOWED + COLOR_THEME_ACTIVE + textSize)
  else
    for index, value in pairs(activeWarnings) do
      if value.level >=2 then
        lcd.drawText((x + w - trafficLightMargin - 2*radius)/2, y + textMargin + (index-1)*textOffset, value.name, VCENTER + CENTER + BOLD + SHADOWED + COLOR_THEME_WARNING + BLINK + INVERS + textSize)
      else
        lcd.drawText((x + w - trafficLightMargin - 2*radius)/2, y + textMargin + (index-1)*textOffset, value.name, VCENTER + CENTER + BOLD + SHADOWED + COLOR_THEME_ACTIVE + BLINK + INVERS +  textSize)
      end
    end
  end
end

function gui.fullScreenRefresh()

  calculate()

  render(0, HEADER, LCD_W, LCD_H-HEADER, MIDSIZE, 45, HEADER)

  lcd.drawFilledRectangle(0, 0, LCD_W, HEADER, COLOR_THEME_SECONDARY1)
  if highestLevel >=2  then
    lcd.drawText(COL1, HEADER / 2 - 2, "WARNINGS", BLINK + VCENTER + DBLSIZE + INVERS + COLOR_THEME_WARNING)
    lcd.drawRectangle(0, HEADER, LCD_W, LCD_H - HEADER, BLINK + COLOR_THEME_WARNING, 5)
  elseif highestLevel == 1 then
    lcd.drawText(COL1, HEADER / 2 - 2, "Warnings", BLINK + VCENTER + DBLSIZE + INVERS + COLOR_THEME_ACTIVE)
    lcd.drawRectangle(0, HEADER, LCD_W, LCD_H - HEADER, BLINK + COLOR_THEME_ACTIVE, 5)
  else
    lcd.drawText(COL1, HEADER / 2 - 2, "Warnings",VCENTER + DBLSIZE + libGUI.colors.primary2)
  end

end

function libGUI.widgetRefresh()

  calculate()

  render(zone.x, zone.y, zone.w, zone.h, 0, 22, 25)

  if highestLevel >=2  then
    lcd.drawRectangle(zone.x, zone.y, zone.w, zone.h, COLOR_THEME_WARNING, 3)
  elseif highestLevel == 1 then
    lcd.drawRectangle(zone.x, zone.y, zone.w, zone.h, COLOR_THEME_ACTIVE, 3)
  else
    --lcd.drawRectangle(zone.x, zone.y, zone.w, zone.h, COLOR_THEME_SECONDARY1, 1)
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
