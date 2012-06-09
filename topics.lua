-----------------------------------------------------------------------------------------
--
-- topics.lua
--
-----------------------------------------------------------------------------------------

local widget = require("widget")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local steps = {false, false, false}

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------

local function onAddTableRow(e)
	local row = e.target
	local rowGroup = e.view
	local data = storyboard.meetup_cli.data.results
	local name = display.newText( data[e.index].name, 0,0, "Helvetica-Bold", 18 )
	name:setReferencePoint(display.TopLeftReferencePoint)
	name.x = 20
	name.y = 5
	name:setTextColor(0)

	local id = display.newText( "Event ID: " .. data[e.index].id, 0,0, "Helvetica-Bold", 18 )
	id:setReferencePoint(display.TopLeftReferencePoint)
	id.x = 20
	id.y = name.y + 25
	id:setTextColor(0)

	local time_at = display.newText(os.date("%Y/%m/%d %I:%M %p", data[e.index].time/1000), 0,0, "Helvetica", 12 )
	time_at:setReferencePoint(display.TopLeftReferencePoint)
	time_at.x = 20
	time_at.y = id.y + 25
	time_at:setTextColor(0)

	local venue = display.newText(data[e.index].venue.name .. ", " .. data[e.index].venue.address_1 .. ", " .. data[e.index].venue.zip, 0,0, "Helvetica", 12 )
	venue:setReferencePoint(display.TopLeftReferencePoint)
	venue.x = 20
	venue.y = time_at.y + 16
	venue:setTextColor(0)

	rowGroup:insert(name)
	rowGroup:insert(id)
	rowGroup:insert(time_at)
	rowGroup:insert(venue)
end

-- Add a new row to TableView
local function addTableRow()
	-- Add rows to list
	rowHeight = 95
	list:insertRow{						-- add a new row to TableView
		onRender = onAddTableRow,
		height = rowHeight
	}
end

local function getData()
	print("getData")
	storyboard.meetup_cli:getData('events')
	steps[1] = true
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight-49 )
	bg:setFillColor( 255 )	-- white

	-- all objects must be added to group (e.g. self.view)
	group:insert( bg )

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	steps = {false, false, false}
	downloads = {total=0, completed=0}

	storyboard.meetup_cli.dataDownloaded = false

	-- Create tableView list
	local listOptions = {
		top = display.statusBarHeight,
		height = 360
		-- maskFile = "listItemBg.png"
	}
	list = widget.newTableView(listOptions)

	-- Get data
	getData()
	
	-- Screen listener
	local function topicsSceneHandler(e) 
		if steps[1] and not steps[2] and not steps[3] then
			if storyboard.meetup_cli.dataDownloaded then
				storyboard.meetup_cli.dataDownloaded = false
				storyboard.upcoming_event_id = storyboard.meetup_cli.data.results[#storyboard.meetup_cli.data.results].id
				storyboard.upcoming_event_name = storyboard.meetup_cli.data.results[#storyboard.meetup_cli.data.results].name
				storyboard.upcoming_event_time = os.date("%m/%d/%Y %I:%M %p", storyboard.meetup_cli.data.results[#storyboard.meetup_cli.data.results].time/1000)
				print("topicsSceneHandler", "Total number of records", #storyboard.meetup_cli.data.results)
				for i,v in ipairs(storyboard.meetup_cli.data.results) do
					print("topicsSceneHandler", "Add row " .. i .. " of " .. #storyboard.meetup_cli.data.results)
					addTableRow()
				end
				steps[2] = true
			end
		elseif steps[1] and steps[2] and not steps[3] then
			print("topicsSceneHandler", "Remove Runtime Event Listener")
			Runtime:removeEventListener("enterFrame", topicsSceneHandler)
		end
	end
	Runtime:addEventListener("enterFrame", topicsSceneHandler )

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	list:deleteAllRows()

end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view

	-- Clean up list
	list:removeSelf( )

	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc.)

end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------------

return scene