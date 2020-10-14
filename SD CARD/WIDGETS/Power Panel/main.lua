-- Heli flight pack battery widget V0.2
--[[ To do:
      get display to conform to widget size
      maybe add some more info or graphics or bitmaps to make it look better
      ]]
      
  -- Many thanks to DanielGA on Helifreak, who is immensely helpful!
	-- Many thanks to IShems and everyone else at RCGroups who answered my questions.
	-- Thanks to all the other coders before me who's code I studied, egregiously pilfered, and changed to make this work.

local options = {
  { "Sensor", SOURCE }, -- get a sensor
  { "BattSize", VALUE, 35 }, -- set battery size to 3500 default
  { "Color", COLOR, WHITE }
}
-- Create zone with options and variables passed on to other functions 
local function create(zone, options)
  local myZone = {
    zone=zone,
    options=options,
    trip = 0,
    capUsed = capUsed,
    capTotal = capTotal,
    capRem = capRem
    }
  return myZone
end
-- update options if necessary
local function update(myZone, options)
  myZone.options = options
end

---------------------------------------------------------------------------
--             this section contains auxillary functions                 --
---------------------------------------------------------------------------

--Function to calculate remaining percentage.
--Funky math is to allow BattSize reported in actual mAh
local function calc(zone)
  zone.capUsed = getValue(zone.options.Sensor)
  zone.capTotal = zone.options.BattSize * 100
  zone.capRem = math.floor( 100 -( zone.capUsed * 100 / zone.capTotal )) -- remaining capacity normalized to pectentage
  return zone
end

-- This function returns green red below 10%, yellow in between, and green above 25%
local function getPercentColor(zone,cpercent)
  if cpercent < 5 then
    return lcd.RGB(0xff, 0x33, 0x33)
  elseif cpercent < 10 then
    return lcd.RGB(0xff, 0xff, 0)
  else
    return zone.options.Color --lcd.RGB(0,0xff,0)
  end
end
-- Play percent remaining voice calls
-- Plays percent at intervals of 10 above 10% and each 5% at intervals below 10%
local function bitchAboutIt(zone)
	local pct
  
-- set up interval
	if zone.capRem < 10 then
		pct = zone.capRem % 5
	else
		pct = zone.capRem % 10
	end
  
-- bitch about it.
	if 
    pct == 0
    and zone.capRem >= 1 --play only if positive capacity, avoids voice call for negative values.
    and zone.capRem < 100 -- play only if less than 100, avoids voice call on startup
    and zone.trip ~= zone.capRem -- only play if trip is not the same as remaining capacity.
  then
		playNumber(zone.capRem, 13)
    zone.trip = zone.capRem	-- don't keep bitching about it.
    print(zone.trip, type(zone.trip))
    print(zone.capRem, type(zone.capRem))
  end
	return zone.trip
end
---------------------------------------------------------------------------
--             this section contains zone draw functions                 --
---------------------------------------------------------------------------
-- Top bar, Size: 70x39 (Tiny)
local function zoneTiny(zone)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color)
  lcd.drawText(zone.zone.x+0, zone.zone.y+0, zone.capUsed .. "mAh", TEXT_INVERTED_COLOR + SMLSIZE)
  --lcd.drawText(zone.zone.x+0, zone.zone.y+12, capTotal .. "mAh", TEXT_INVERTED_COLOR + SMLSIZE)
  lcd.setColor(CUSTOM_COLOR, getPercentColor(zone, zone.capRem))
  lcd.drawGauge(zone.zone.x+0, zone.zone.y+28, 68, 12, zone.capRem, 100, CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+20, zone.zone.y+25, zone.capRem.."%", TEXT_INVERTED_COLOR + SHADOWED + SMLSIZE)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color) -- return color to custom to prevent other widgets from being the wrong color.
end

-- Small, Size: 160x32 (1/8)
local function zoneSmall(zone)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color)
  lcd.drawText(zone.zone.x+0, zone.zone.y+0, zone.capUsed .. " mAh / " .. zone.capTotal .. " total", TEXT_INVERTED_COLOR + SMLSIZE) --report capacity 
  lcd.setColor(CUSTOM_COLOR, getPercentColor(zone, zone.capRem))
  lcd.drawGauge(zone.zone.x+0, zone.zone.y+20, 160, 12, zone.capRem, 100, CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+60, zone.zone.y+16, zone.capRem.."%", TEXT_INVERTED_COLOR + SHADOWED + SMLSIZE)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color) -- return color to custom to prevent other widgets from being the wrong color.
end
-- Medium, Size: 180x70 (1/4)
local function zoneMedium(zone)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color)
  lcd.drawText(zone.zone.x+0, zone.zone.y+0, "Remaining:", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+100, zone.zone.y+0, zone.capRem .. "%", CUSTOM_COLOR) --report percent
  lcd.drawText(zone.zone.x+0, zone.zone.y+16, "Used: " .. zone.capUsed .. "mAh", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+0, zone.zone.y+32, "Total: " .. zone.capTotal .. "mAh", CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR, getPercentColor(zone, zone.capRem))
  lcd.drawGauge(zone.zone.x+0, zone.zone.y+50, 180, 20, zone.capRem, 100, CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+75, zone.zone.y+50, zone.capRem.."%", TEXT_INVERTED_COLOR + SHADOWED)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color) -- return color to custom to prevent other widgets from being the wrong color.
end

-- Large, Size: 192x152 (half)
local function zoneLarge(zone)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color)
  lcd.drawText(zone.zone.x+0, zone.zone.y+0, "Battery", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+0, zone.zone.y+16, "Remaining:", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+100, zone.zone.y+0, zone.capRem .. "%", CUSTOM_COLOR + DBLSIZE) --report percent
  lcd.drawText(zone.zone.x+0, zone.zone.y+40, "Capacity Used:" , CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+0, zone.zone.y+56, zone.capUsed .. "mAh", CUSTOM_COLOR) --report capacity used
  lcd.drawText(zone.zone.x+0, zone.zone.y+80, "Usable Battery:", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+0, zone.zone.y+96, zone.capTotal .. "mAh", CUSTOM_COLOR) -- report usable size set in options
  lcd.setColor(CUSTOM_COLOR, getPercentColor(zone, zone.capRem))
  lcd.drawGauge(zone.zone.x+0, zone.zone.y+130, 190, 20, zone.capRem, 100, CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+75, zone.zone.y+130, zone.capRem.."%", TEXT_INVERTED_COLOR + SHADOWED)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color) -- return color to custom to prevent other widgets from being the wrong color.
end
-- XLarge, Size: 390x172 (full)
local function zoneXLarge(zone)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color)
  lcd.drawText(zone.zone.x+0, zone.zone.y+0, "Battery", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+0, zone.zone.y+16, "Remaining:", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+100, zone.zone.y+0, zone.capRem .. "%", CUSTOM_COLOR + DBLSIZE) --report percent
  lcd.drawText(zone.zone.x+0, zone.zone.y+40, "Capacity Used:" , CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+0, zone.zone.y+56, zone.capUsed .. "mAh", CUSTOM_COLOR) --report capacity used
  lcd.drawText(zone.zone.x+0, zone.zone.y+80, "Usable Battery:", CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+0, zone.zone.y+96, zone.capTotal .. "mAh", CUSTOM_COLOR) -- report usable size set in options
  lcd.setColor(CUSTOM_COLOR, getPercentColor(zone, zone.capRem))
  lcd.drawGauge(zone.zone.x+0, zone.zone.y+150, 190, 20, zone.capRem, 100, CUSTOM_COLOR)
  lcd.drawText(zone.zone.x+75, zone.zone.y+150, zone.capRem.."%", TEXT_INVERTED_COLOR + SHADOWED)
  lcd.setColor(CUSTOM_COLOR, zone.options.Color) -- return color to custom to prevent other widgets from being the wrong color.
end
-- Background tasks. Calculations and voice calls.
local function background(myZone)
  calc(myZone) -- calculate commonly used values
  
  if getRSSI() > 0 then -- play percent if telemetry is linked up
    myZone.trip = bitchAboutIt(myZone)
  end
end
-- Draw the values and stuff while the screen is visible.
function refresh(myZone)
  background(myZone) --isn't called from radio when widget is visible!!! do it yourself
  
  if        myZone.zone.w  > 380 and myZone.zone.h > 165 then zoneXLarge(myZone)
    elseif  myZone.zone.w  > 180 and myZone.zone.h > 145 then zoneLarge(myZone)
    elseif  myZone.zone.w  > 170 and myZone.zone.h > 65  then zoneMedium(myZone)
    elseif  myZone.zone.w  > 150 and myZone.zone.h > 28  then zoneSmall(myZone)
    elseif  myZone.zone.w  >  65 and myZone.zone.h > 35  then zoneTiny(myZone)
  end
end

return { name="PwrPanel", options=options, create=create, update=update, refresh=refresh, background=background }
