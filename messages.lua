-----------------------------------------------------------------------------------------
--
-- messages.lua
--
-----------------------------------------------------------------------------------------

local widget = require("widget")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local steps = {false, false, false}
local m_message, m_submit

local function onMessageField(e)
	if e.phase == "began" then
		m_message.text = ""
	elseif e.phase == "ended" then
		m_message.message = tostring(e.text)
		if m_message.text == "" then
			m_message.text = "Enter Message"
		end
	elseif e.phase == "submitted" then
		native.setKeyboardFocus(nil)
		if m_message.text == "" then
			m_message.text = "Enter Message"
		end
	end
end

local function onSend(e)
	if e.phase == "release" then
		storyboard.meetup_cli:sendData('event_comment', 
			{event_id = tostring(storyboard.upcoming_event_id), comment = tostring(m_message.text)}
		)
		steps[1] = true
	end
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

	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )	-- white

	group:insert(bg)

end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	steps = {false, false, false}
	
	-- create some text
	local title = display.newRetinaText( "Post Message to", 0,0, native.systemFont, 32 )
	title:setTextColor( 0 )	-- black
	title:setReferencePoint( display.CenterReferencePoint )
	title.x = display.contentWidth * 0.5
	title.y = 60

	local title2 = display.newRetinaText(storyboard.upcoming_event_name, 0,0, native.systemFont, 18 )
	title2:setTextColor( 0 )	-- black
	title2:setReferencePoint( display.CenterReferencePoint )
	title2.x = display.contentWidth * 0.5
	title2.y = title.y + 40

	local title3 = display.newRetinaText(storyboard.upcoming_event_time, 0,0, native.systemFont, 18 )
	title3:setTextColor( 0 )	-- black
	title3:setReferencePoint( display.CenterReferencePoint )
	title3.x = display.contentWidth * 0.5
	title3.y = title2.y + 22

	m_message = native.newTextField(20, 150, display.contentWidth-40, 28)
	m_message.text = "Enter Message"
	m_message.size = 18
	m_message:addEventListener('userInput', onMessageField)

	m_submit = widget.newButton{
		label = "Send",
		width = 60,
		height = 30,
		left = (display.contentWidth/2) - 30,
		top = (display.contentHeight) - 100,
		onEvent = onSend
	}
	
	-- Screen listener
	local function messagesSceneHandler(e) 
		if steps[1] and not steps[2] and not steps[3] then
			if storyboard.meetup_cli.dataSent then
				native.showAlert("Post Comment", "Your comment has been posted.", {"OK"})
				storyboard.meetup_cli.dataSent = false
				steps[1] = false
			end
		end
	end
	Runtime:addEventListener("enterFrame", messagesSceneHandler )

end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	m_message:removeSelf()
	m_submit:removeSelf()
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view

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