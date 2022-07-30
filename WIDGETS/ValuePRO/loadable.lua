---------------------------------------------------------------------------
-- The dynamically loadable part of the Lua widget.                      --
--                                                                       --
-- Author:  Philippe Wechsler                                            --
-- Date:    2022-07-24                                                   --
-- Version: 1.0.0                                                        --
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

local UnitsTable = {
  [1] = "V",
  [2] = "A",
  [3] = "mA",
  [4] = "kts",
  [5] = "m/s",
  [6] = "f/s",
  [7] = "km/h",
  [8] = "mph",
  [9] = "m",
  [10] = "f",
  [11] = "C°",
  [12] = "F°",
  [13] = "%",
  [14] = "mAh",
  [15] = "W",
  [16] = "mW",
  [17] = "dB",
  [18] = "RPM",
  [19] = "G",
  [20] = "deg",
  [21] = "rad",
  [22] = "mm",
  [23] = "floz",
  [24] = "ml/m",
  [35] = "h",
  [36] = "m",
  [37] = "s",
  [38] = "",
  [39] = "",
  [40] = "",
  [41] = "",
  [42] = ""
}

local zone, options = ...

local HEADER = 40
local COL1   = 10
local HEIGHT = 24

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

local function hasLabel()
  return widget.options.Label ~= ""
end

local function getPercentValue(value)
  return math.floor(100 / (widget.options.Max - widget.options.Min) * value + 0.5)
end

local function updateUnit()
  fieldInfo = getFieldInfo(widget.options.Source)
  if(fieldInfo.unit~=nil and fieldInfo.unit > 0) then
    widget.unit = (UnitsTable[fieldInfo.unit])
  else
    widget.unit = ""
  end

  if(fieldInfo.desc~=nil) then
    widget.desc = fieldInfo.desc
  else
    widget.desc = ""
  end
end

function widget.create(zone, options)
  widget = { zone=zone, options=options, ts = MIDSIZE, yo = 0, ls = SMLSIZE + SHADOWED + CENTER, lyo = 0, lyo2 = 0, unit = "", desc = "" }

  if widget.zone.w  > 240 then
    widget.ts = XXLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.ls = MIDSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY3
    widget.yo = widget.zone.h / 2 - 38
    widget.lyo = 25
    widget.lyo2 = 35
  elseif 	widget.zone.w  > 70 then
    widget.ts = DBLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.ls = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY3
    widget.yo = widget.zone.h / 2 - 20
    widget.lyo = 10
    widget.lyo2 = 20
  else
    widget.ts = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.ls = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.yo = widget.zone.h / 2 - 8
    widget.lyo = 8
    widget.lyo2 = 18
  end
  
  updateUnit()

  return widget
end

function gui.fullScreenRefresh()
  lcd.drawFilledRectangle(0, 0, LCD_W, HEADER, COLOR_THEME_SECONDARY1)
  if(hasLabel()) then
    lcd.drawText(COL1, HEADER / 2 - 2, widget.options.Label,VCENTER + DBLSIZE + COLOR_THEME_PRIMARY2)
  else
    lcd.drawText(COL1, HEADER / 2 - 2, "Value PRO",VCENTER + DBLSIZE + COLOR_THEME_PRIMARY2)
  end

	local value = getValue(widget.options.Source)

	local xo = LCD_W / 2
	local yo = LCD_H / 2 - (HEADER / 2)

  lcd.drawText(xo, LCD_H - 40, widget.desc, SHADOWED + CENTER + COLOR_THEME_PRIMARY3)

  if(value == nil) then
    lcd.drawText(xo, yo, "NO VALUE", XXLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE + BLINK + INVERS)
  elseif (widget.options.Percent == 1) then
    percentValue = getPercentValue(value)
    local textValue = percentValue.."%"
	  lcd.drawText(xo, yo, textValue, XXLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE)
  else
    --lcd.drawNumber(xo, yo, value, widget.ts)
    lcd.drawText(xo, yo, string.format("%2.1f", value).." "..widget.unit, XXLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE)
  end
end

function libGUI.widgetRefresh()
	local value = getValue(widget.options.Source)
  local hasLabel = hasLabel()
	local xo = widget.zone.x + (widget.zone.w / 2)
	local yo = widget.zone.y + widget.yo

  if (hasLabel) then
    yo = yo + widget.lyo
  end

  if(value == nil) then
    lcd.drawText(xo, yo, "NO VALUE", widget.ts + BLINK + INVERS)
  elseif (widget.options.Percent == 1) then
    percentValue = getPercentValue(value)
    local textValue = percentValue.."%"
	  lcd.drawText(xo, yo, textValue, widget.ts)
  else
    --lcd.drawNumber(xo, yo, value, widget.ts)
    lcd.drawText(xo, yo, string.format("%2.1f", value)..widget.unit, widget.ts)
  end

  if (hasLabel) then
    --lcd.drawSource(xo, yo - widget.lyo2, widget.options.Source, widget.ls)
    lcd.drawText(xo, yo - widget.lyo2, widget.options.Label, widget.ls)
  end
end

function widget.background(widget)

end

function widget.update(widget, options)
  widget.options = options

  updateUnit()
end

function widget.refresh(event, touchState)
  gui.run(event, touchState)
end

function widget.update(opt)
	options = opt
end

return widget
