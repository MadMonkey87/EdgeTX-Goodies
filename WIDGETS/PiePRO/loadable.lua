---------------------------------------------------------------------------
-- The dynamically loadable part of the Lua widget.                      --
--                                                                       --
-- Author:  Philippe Wechsler                                            --
-- Date:    2022-07-25                                                   --
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

local function HasWarning(totalizedValue)
  if (widget.options.Warn == 0) then
    return false
  elseif (widget.options.Warn > 0) then
    return widget.options.Warn<= totalizedValue
  elseif (widget.options.Warn < 0) then
    return widget.options.Warn * -1 >= totalizedValue
  end
end

local function render(x,y,w,h,totalizedValue, margin, border)
  local borderColor = COLOR_THEME_SECONDARY1
  local backgroundColor = COLOR_THEME_PRIMARY3
  local color = COLOR_THEME_FOCUS
  if (HasWarning(totalizedValue)) then
    color = COLOR_THEME_WARNING
  end
  local radius = math.min(w, h) / 2 - margin
  local x0 = x + (w / 2)
  local y0 = y + (h / 2)
  lcd.drawFilledCircle(x0, y0, radius, borderColor)
  lcd.drawFilledCircle(x0, y0, radius-border -1, color)
  if (totalizedValue~=100) then
    lcd.drawPie(x0, y0, radius-border, 0, 360-totalizedValue*3.6, backgroundColor)
  end
end

function widget.create(zone, options)
  widget = { zone=zone, options=options, textFlags = MIDSIZE, labelFlags = SMLSIZE + SHADOWED + CENTER, pieFlags = COLOR_THEME_SECONDARY1, lyo = 0, lyo2 = 0, yo = 0, margin = 0, border = 0}
   
  if widget.zone.w  > 240 then
    widget.textFlags = XXLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.labelFlags = MIDSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.pieFlags = COLOR_THEME_FOCUS
    widget.yo = widget.zone.h / 2 - 38
    widget.lyo = 25
    widget.lyo2 = 35
    widget.margin = 3
    widget.border = 3
  elseif 	widget.zone.w  > 70 then
    widget.textFlags = DBLSIZE + SHADOWED + CENTER + COLOR_THEME_ACTIVE
    widget.labelFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.pieFlags = COLOR_THEME_FOCUS
    widget.yo = widget.zone.h / 2 - 20
    widget.lyo = 10
    widget.lyo2 = 20
    widget.margin = 3
    widget.border = 3
  else
    widget.textFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.labelFlags = SMLSIZE + SHADOWED + CENTER + COLOR_THEME_PRIMARY2
    widget.pieFlags = RED
    widget.yo = widget.zone.h / 2 - 8
    widget.lyo = 8
    widget.lyo2 = 18
    widget.margin = 0
    widget.border = 1
  end
  
  return widget
end

function gui.fullScreenRefresh()
  local value = getValue(widget.options.Source)
  lcd.drawFilledRectangle(0, 0, LCD_W, HEADER, COLOR_THEME_SECONDARY1)
  local warn = HasWarning(getTotalizedValue(value))
  local text = "Pie PRO"
  if(hasLabel()) then
    text = widget.options.Label
  end

  if warn then
    lcd.drawText(COL1, HEADER / 2 - 2, text, BLINK + VCENTER + DBLSIZE + INVERS + COLOR_THEME_WARNING)
    lcd.drawRectangle(0, HEADER, LCD_W, LCD_H - HEADER, BLINK + COLOR_THEME_WARNING, 5)
  else
    lcd.drawText(COL1, HEADER / 2 - 2, text,VCENTER + DBLSIZE + COLOR_THEME_PRIMARY2)
  end

  if(value == nil) then
	  lcd.drawText(LCD_W / 2, (LCD_H - HEADER) / 2 + HEADER, "NO VALUE", widget.textFlags + BLINK + INVERS + VCENTER)
  else
    totalizedValue = getTotalizedValue(value)
    render(0, HEADER, LCD_W, LCD_H - HEADER, totalizedValue, 20, 5)
    lcd.drawText(LCD_W / 2, (LCD_H - HEADER) / 2 + HEADER, totalizedValue.."%", widget.textFlags + VCENTER)
  end

  if (widget.options.Warn < 0) then
    lcd.drawText(20, LCD_H - 20, "warn when <="..math.max(widget.options.Warn).."%", SHADOWED + VCENTER + COLOR_THEME_PRIMARY3)
  elseif (widget.options.Warn > 0) then
    lcd.drawText(20, LCD_H - 20, "warn when >="..math.max(widget.options.Warn).."%", SHADOWED + VCENTER + COLOR_THEME_PRIMARY3)
  end

end

function libGUI.widgetRefresh()
  local xo = widget.zone.x + (widget.zone.w / 2)
	local yo = widget.zone.y + widget.yo
  local hasLabel = hasLabel()
  if (hasLabel) then
    yo = yo + widget.lyo
  end

	local value = getValue(widget.options.Source)
  if(value == nil) then
	  lcd.drawText(xo, yo, "NO VALUE", widget.textFlags + BLINK + INVERS)
  else
    totalizedValue = getTotalizedValue(value)
    render(widget.zone.x, widget.zone.y, widget.zone.w, widget.zone.h, totalizedValue, widget.margin, widget.border)
    if (hasLabel) then
      lcd.drawText(xo, yo - widget.lyo *2, widget.options.Label, widget.labelFlags)
    end
    lcd.drawText(xo, yo, totalizedValue.."%", widget.textFlags)
  end
end

function widget.background(widget)

end

function widget.update(widget, options)
  widget.options = options
end

function widget.refresh(event, touchState)
  gui.run(event, touchState)
end

function widget.update(opt)
	options = opt
end

return widget
