local WIDGET={}

WIDGET.name = "MovingCntr"

WIDGET.options = ... or 
  {{"hoogte",VALUE,10,0,30}
}

WIDGET.create = function(zone, options)
  return {zone=zone, options=options, i=0}
end

WIDGET.update = function(widgetToUpdate, newOptions)
  widgetToUpdate.options = newOptions
end

WIDGET.background = function(widgetToProcessInBackground)
end

WIDGET.refresh = function(widgetToRefresh)
  lcd.drawText(widgetToRefresh.zone.x+widgetToRefresh.i,widgetToRefresh.zone.y+widgetToRefresh.options.hoogte,widgetToRefresh.i,MIDSIZE)
  widgetToRefresh.i=widgetToRefresh.i+1
  if widgetToRefresh.i>widgetToRefresh.zone.w then
    widgetToRefresh.i=0
  end
end

return WIDGET