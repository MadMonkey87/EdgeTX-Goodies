---------------------------------------------------------------------------
-- The dynamically loadable part of the Lua widget.                      --
--                                                                       --
-- Author:  Philippe Wechsler                                            --
-- Date:    2022-07-23                                                   --
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

local function getTotalizedValue(value)
  return math.floor(100 / (widget.options.Max *2) * (value + widget.options.Max + 0.5)) --only works if Min is negative and same total as Max
end

function widget.create(zone, options)
  widget = { zone=zone, options=options, textFlags = MIDSIZE, labelFlags = SMLSIZE + SHADOWED + CENTER, gaugeFlags = COLOR_THEME_SECONDARY1, lyo = 0, lyo2 = 0, yo = 0, margin = 0, border = 0}
   
  if widget.zone.w  > 240 and widget.zone.h > 56 then
    widget.textFlags = XXLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.labelFlags = MIDSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.gaugeFlags = COLOR_THEME_FOCUS
    widget.yo = widget.zone.h / 2 - 38
    widget.lyo = 25
    widget.lyo2 = 35
    widget.margin = 3
    widget.border = 3
  elseif 	widget.zone.w  > 70 and widget.zone.h > 56 then
    widget.textFlags = DBLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.labelFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.gaugeFlags = COLOR_THEME_FOCUS
    widget.yo = widget.zone.h / 2 - 20
    widget.lyo = 10
    widget.lyo2 = 20
    widget.margin = 3
    widget.border = 3
  elseif widget.zone.h >= 56 then
    widget.textFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.labelFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.gaugeFlags = COLOR_THEME_FOCUS
    widget.yo = widget.zone.h / 2 - 8
    widget.lyo = 8
    widget.lyo2 = 18
    widget.margin = 1
    widget.border = 3
  else
    widget.textFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.labelFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.gaugeFlags = COLOR_THEME_ACTIVE
    widget.yo = widget.zone.h / 2 - 8
    widget.lyo = 8
    widget.lyo2 = 18
    widget.margin = 0
    widget.border = 0
  end
  
  return widget
end

function gui.fullScreenRefresh()
  lcd.drawFilledRectangle(0, 0, LCD_W, HEADER, COLOR_THEME_SECONDARY1)
  if(hasLabel()) then
    lcd.drawText(COL1, HEADER / 2 - 2, widget.options.Label,VCENTER + DBLSIZE + COLOR_THEME_PRIMARY2)
  else
    lcd.drawText(COL1, HEADER / 2 - 2, "Gauge PRO",VCENTER + DBLSIZE + COLOR_THEME_PRIMARY2)
  end

	local textValue
	value = getValue(widget.options.Source)
  if(value == nil) then
      return
  end

  local margin = 20
	local xo = LCD_W / 2 
	local yo = (LCD_H - HEADER) / 2

  percentValue = getPercentValue(value)
  totalizedValue = getTotalizedValue(value)
  textValue = percentValue.."%"
  if (widget.options.Totalize == 1) then
    textValue = totalizedValue.."%"
  end
  lcd.drawGauge(margin, HEADER+margin, LCD_W-2*margin, LCD_H - HEADER - 2*margin, totalizedValue, 100, COLOR_THEME_FOCUS)
  lcd.drawRectangle(margin, HEADER+margin, LCD_W-2*margin, LCD_H - HEADER - 2*margin, COLOR_THEME_ACTIVE, 3)
	lcd.drawText(xo, yo, textValue, XXLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE)
end

function libGUI.widgetRefresh()
	local textValue
	value = getValue(widget.options.Source)
  if(value == nil) then
      return
  end

  local hasLabel = hasLabel();

	local xo = widget.zone.x + (widget.zone.w / 2)
	local yo = widget.zone.y + widget.yo

  if (hasLabel) then
    yo = yo + widget.lyo
  end

  percentValue = getPercentValue(value)
  totalizedValue = getTotalizedValue(value)
  textValue = percentValue.."%"
  if (widget.options.Totalize == 1) then
    textValue = totalizedValue.."%"
  end
  lcd.drawGauge(widget.zone.x + widget.margin, widget.zone.y + widget.margin, widget.zone.w-2*widget.margin, widget.zone.h-2*widget.margin, totalizedValue, 100, widget.gaugeFlags)

  if widget.border>0 then
    lcd.drawRectangle(widget.zone.x + widget.margin, widget.zone.y + widget.margin, widget.zone.w-2*widget.margin, widget.zone.h-2*widget.margin, COLOR_THEME_ACTIVE, widget.border)
  end

	lcd.drawText(xo, yo, textValue, widget.textFlags)

  if (hasLabel) then
    lcd.drawText(xo, yo - widget.lyo2, widget.options.Label, widget.labelFlags)
  end
end

function widget.background()

end

function widget.update(options)
  widget.options = options
end

function widget.refresh(event, touchState)
  gui.run(event, touchState)
end

return widget
