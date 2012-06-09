-----------------------------------------------------------------------------------------
--
-- members.lua
--
-----------------------------------------------------------------------------------------
local widget = require("widget")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local list = nil
local steps = {false, false, false}
local downloads = {total=0, completed=0}

-- Compile row
local function onAddTableRow(e)
	local row = e.target
	local rowGroup = e.view
	local text = display.newText(storyboard.meetup_cli.data.results[e.index].name, 100, 0, "Helvetica-Bold", 18)
	print("onAddTableRow", e.index)
	text:setReferencePoint(display.CenterLeftReferencePoint)
	text:setTextColor(0)
	text.y = row.height * 0.5
	rowGroup:insert(text)
	-- Check if image exists
	local path = system.pathForFile("member_" ..storyboard.meetup_cli.data.results[e.index].id .. ".jpg", system.TemporaryDirectory)
	print("onAddTableRow", path)
	local photo = io.open(path, "r")
	if photo then
		print("onAddTableRow", "Loading image " .. "member_" .. storyboard.meetup_cli.data.results[e.index].id .. ".jpg")
		local imageRect = display.newImageRect("member_" .. storyboard.meetup_cli.data.results[e.index].id .. ".jpg", system.TemporaryDirectory, 50, 50)
		imageRect:setReferencePoint(display.CenterLeftReferencePoint)
		imageRect.y = row.height * 0.5
		imageRect.x = 12
		rowGroup:insert(imageRect)
		io.close(photo)
	end
end

-- Add a new row to TableView
local function addTableRow()
	-- Add rows to list
	rowHeight = 54
	list:insertRow{						-- add a new row to TableView
		onRender = onAddTableRow,
		height = rowHeight
	}
end

-- Download member image listener
local function onDownloadImage(e)
	if (e.isError) then
		print("onDownloadImage", "Network error!", e.response)
		native.setActivityIndicator(false)
	else
		downloads.completed = downloads.completed + 1
		print("onDownloadImage", downloads.completed .. " of " .. downloads.total)

		if downloads.completed == downloads.total then
			native.setActivityIndicator(false)
			steps[2] = true
		end
	end
end

-- Download member avatars
local function downloadImages(data)
	print("downloadImages", "Images to download: " .. downloads.total)
	for i,v in ipairs(data.results) do
		if v.photo and v.photo.thumb_link then
			native.setActivityIndicator(true)
			photo = "member_" .. v.id .. ".jpg"
			network.download(v.photo.thumb_link, "GET", onDownloadImage, photo, system.TemporaryDirectory)
			print("downloadImages", "downloading ".. photo)
		end
	end
end

-- Request data from web service
local function getData()
	print("getData")
	storyboard.meetup_cli:getData('members')
	steps[1] = true
end

-----------------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
--
-- NOTE: Code outside of listener functions (below) will only be executed once,
--		 unless storyboard.removeScene() is called.
--
-----------------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
	-- Move tabBar back on screen
	storyboard.tabBar.x = display.contentWidth/2

	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight-49 )
	bg:setFillColor( 255 )	-- white
	
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	steps = {false, false, false}
	downloads = {total=0, completed=0}

	storyboard.meetup_cli.dataDownloaded = false
	
	-- Initialize tableView
	local listOptions = {
		top = display.statusBarHeight,
		height = 360
		-- maskFile = "listItemBg.png"
	}
	list = widget.newTableView(listOptions)
	
	-- Get data
	getData()
	
	-- Screen listener
	local function membersSceneHandler(e) 
		if steps[1] and not steps[2] and not steps[3] then
			if storyboard.meetup_cli.dataDownloaded then
				-- Get total number of downloads to perform
				for i,v in ipairs(storyboard.meetup_cli.data.results) do
					if v.photo and v.photo.thumb_link then
						downloads.total = downloads.total + 1
					end
				end
				storyboard.meetup_cli.dataDownloaded = false
				print("membersSceneHandler", "Total number of records", #storyboard.meetup_cli.data.results)
				downloadImages(storyboard.meetup_cli.data)
			end
		elseif steps[1] and steps[2] and not steps[3] then
			-- Add rows
			for i,v in ipairs(storyboard.meetup_cli.data.results) do
				print("membersSceneHandler", "Add row " .. i .. " of " .. #storyboard.meetup_cli.data.results)
				addTableRow()
			end
			steps[3] = true
		elseif steps[1] and steps[2] and steps[3] then
			print("membersSceneHandler", "Remove Runtime Event Listener")
			Runtime:removeEventListener("enterFrame", membersSceneHandler)
		end
	end
	Runtime:addEventListener("enterFrame", membersSceneHandler )
		
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	list:deleteAllRows()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view

	-- INSERT code here (e.g. remove listeners, remove widgets, save state variables, etc. )

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
