---------------------------------------------------------------------------
-- Shared Lua utilities library, and a widget showing how to use it.     --
-- NOTE: It is not necessary to load the widget to use the library;      --
-- as long as the files are present on the SD card it works.             --
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         --
-- GNU General Public License for more details.                          --
---------------------------------------------------------------------------

local name = "DangerZone"
local libGUI

function loadGUI()
  if not libGUI then
  	libGUI = loadScript("/WIDGETS/" .. name .. "/libgui.lua")
  end
  return libGUI()
end

local function create(zone, options)
  return loadScript("/WIDGETS/" .. name .. "/loadable.lua")(zone, options)
end

local function refresh(widget, event, touchState)
  widget.refresh(event, touchState)
end

local function background()
  widget.background()
end

local options = {
	{ "PreArmLS", VALUE, 19, 1, 64 },
  { "ThrottleCut", SOURCE },
  { "ArmLS", VALUE, 20, 1, 64 },
  { "SelfCheckLS", VALUE, 21, 1, 64 },
  { "Failsafe", VALUE, 27, 1, 64 },
}

local function update(options)
	widget.update(options)
end

return {
  name = name,
  create = create,
  refresh = refresh,
  background = background,
  options = options,
  update = update
}