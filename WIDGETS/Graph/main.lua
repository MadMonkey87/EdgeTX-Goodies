local options = {
	{ "Source", SOURCE, 1 },
	{ "Interval", VALUE, 8, 1, 35 }, 
	{ "Percent", BOOL , 0 },
	{ "Min", VALUE, -1024, -1024, 1024 },
	{ "Max", VALUE, 1024, -1024, 1024 }
}

local _maxPoints = 100

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

function create(zone, options)
	local context = { zone=zone, options=options, points={}, lastTime=0, index=0, unit="" }

	fieldInfo = getFieldInfo(context.options.Source)
	if(not fieldInfo == nil and fieldInfo.unit > 0) then
		context.unit = (UnitsTable[fieldInfo.unit])
	end

	return context
end

function update(context, options)
	context.options = options
	context.index = 0

	fieldInfo = getFieldInfo(context.options.Source)
	if(not fieldInfo == nil and fieldInfo.unit > 0) then
		context.unit = (UnitsTable[fieldInfo.unit])
	end

end

function refresh(context)
	updatePoints(context)
	drawGrap(context)
end

function background(context)
	updatePoints(context)
end

function updatePoints(context)
	time = getTime()

	delay = context.options.Interval * context.options.Interval 
	
	if time > context.lastTime + delay then
		value = getValue(context.options.Source)

		if(value == nil) then
			return 0
		end

		context.lastTime = time

		if(context.index < _maxPoints) then
			context.points[context.index] = value
			context.index = context.index + 1
		else
			for i=1,_maxPoints - 1,1 do
				context.points[i - 1] = context.points[i]
			end
			context.points[_maxPoints - 1] = value
		end
	end
end

function drawGrap(context)
	x = context.zone.x
	y = context.zone.y
	width = context.zone.w
	height = context.zone.h
	fordergroundColor = COLOR_THEME_ACTIVE

	if (width  > 70) then
		fordergroundColor = COLOR_THEME_SECONDARY1
		lcd.drawRectangle(x, y, width, height, fordergroundColor)
	end

	if context.index == 0 then
		return
	end

	dataMin = 9999
	dataMax = -9999

	for i=0,context.index - 1,1 do
		if( context.points[i] > dataMax) then
			dataMax = context.points[i]
		end
	end

	for i=0,context.index - 1,1 do
		if( context.points[i] < dataMin) then
			dataMin = context.points[i]
		end
	end

	maxValue = context.options.Max
	minValue = context.options.Min

	if context.zone.w > 100 then
		if(dataMin < minValue) then minValue = dataMin end
		if(dataMax > maxValue) then maxValue = dataMax end
	end

	zeroPos = height
	range = maxValue - minValue
	
	zeroPos = height - (height / (range / (range + minValue)))

	if minValue < 0 and maxValue > 0 then
		lcd.drawLine(x, y + height - zeroPos, x + width, y + height - zeroPos, DOTTED, fordergroundColor)
	end

	if range == 0 then
		range = 1
	end
	
	previous_xPos = x
	previous_yPos = y + height
	
	for i=0,context.index - 1,1 do

		value = context.points[i]

		if value > maxValue then value = maxValue end
		if value < minValue then value = minValue end

		xPos = x + (i * (context.zone.w / _maxPoints))
		yPos = y + (maxValue - value) * (height / range)

		lcd.drawLine(previous_xPos, previous_yPos, xPos, yPos, SOLID, fordergroundColor)
		
		previous_xPos = xPos
		previous_yPos = yPos
	end

	if (context.options.Percent == 1) then
		percentValue = math.floor(100 / (context.options.Max - context.options.Min) * value + 0.5)
	end

	if context.zone.w > 100 then
		if range >= 100 then
			if (context.options.Percent == 1) then
				lcd.drawText(x + width -2, y + 1, percentValue.." %", TEXT_COLOR + RIGHT)
			else
				--lcd.drawNumber(x + width -2, y + 1, value, TEXT_COLOR + RIGHT)
				lcd.drawText(x + width -2, y + 1, value.." "..context.unit, TEXT_COLOR + RIGHT)
			end

			lcd.drawNumber(x + 3, y + 1, maxValue, TEXT_COLOR)
			lcd.drawNumber(x + 3, y + height - 19, minValue, TEXT_COLOR)
		else 
			if range >= 10 then
				if (context.options.Percent == 1) then
					lcd.drawText(x + width -2, y + 1, percentValue.." %", TEXT_COLOR + RIGHT + PREC1)
				else
					--lcd.drawNumber(x + width, y + 1, value * 10, TEXT_COLOR + RIGHT + PREC1)
					lcd.drawText(x + width -2, y + 1, (value * 10).." "..context.unit, TEXT_COLOR + RIGHT + PREC1)
				end

				lcd.drawNumber(x + 3, y + 1, maxValue * 10, TEXT_COLOR + PREC1)
				lcd.drawNumber(x + 3, y + height - 19, minValue * 10, TEXT_COLOR + PREC1)
			else
				if (context.options.Percent == 1) then
					lcd.drawText(x + width -2, y + 1, (value * 100).." "..context.unit, TEXT_COLOR + RIGHT + PREC2)
				else
					--lcd.drawNumber(x + width, y + 1, value * 100, TEXT_COLOR + RIGHT + PREC2)
					lcd.drawText(x + width -2, y + 1, percentValue.." %", TEXT_COLOR + RIGHT + PREC2)
				end

				lcd.drawNumber(x + 3, y + 1, maxValue * 100, TEXT_COLOR + PREC2)
				lcd.drawNumber(x + 3, y + height - 19, minValue * 100, TEXT_COLOR + PREC2)
			end
		end

		lcd.drawSource(x + (width / 2) - 20, y + 1, context.options.Source, fordergroundColor)
	end
end

return { name="Graph", options=options, create=create, update=update, refresh=refresh, background=background }
