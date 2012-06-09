-----------------------------------------------------------------------------------------
--
-- login.lua
--
-----------------------------------------------------------------------------------------
local widget = require("widget")
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

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
	
	-- Move tabBar off screen
	storyboard.tabBar.x = display.contentWidth + 320

	-- create a white background to fill screen
	local bg = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	bg:setFillColor( 255 )	-- white

	-- create some text
	local title = display.newRetinaText( "Meetup API Log In", 0, 0, native.systemFont, 32 )
	title:setTextColor( 0 )	-- black
	title:setReferencePoint( display.CenterReferencePoint )
	title.x = display.contentWidth * 0.5
	title.y = 60

	local summary = display.newRetinaText( "Authorize access to Meetup.", 0, 0, 292, 292, native.systemFont, 14 )
	summary:setTextColor( 0 ) -- black
	summary:setReferencePoint( display.CenterReferencePoint )
	summary.x = display.contentWidth * 0.5 + 10
	summary.y = title.y + 180

	-- all objects must be added to group (e.g. self.view)
	group:insert( bg )
	group:insert( title )
	group:insert( summary )
	
	-- Login button
	submitBtn = widget.newButton{
		left = (display.contentWidth/2) - 75,
		top = display.contentHeight - 200,
		label = "Login",
		width = 150, height = 50,
		cornerRadius = 8,
		fontSize = 22,
		onEvent = function(e)
			if e.phase == "release" then
				print( "Attempt to login" )
				storyboard.meetup_cli:authorize()
			end
		end
	}
		
	-- Authorization listener
	local function loginSceneHandler(e) 
		if storyboard.meetup_cli.isAuthorized == 1 and storyboard.meetup_cli.consumerCode then
			print("sceneHandler", "Received consumer code")
			storyboard.meetup_cli.isAuthorized = 2
			storyboard.meetup_cli:access()
		elseif storyboard.meetup_cli.isAuthorized == 2 then
			print("sceneHandler", "Received access token")
			storyboard.meetup_cli.isAuthorized = 3
			storyboard.tabBar:pressButton(1, true)
		elseif storyboard.meetup_cli.isAuthorized == 3 then
			print("sceneHandler", "Remove sceneHandler")
			Runtime:removeEventListener("enterFrame", loginSceneHandler)
		end
	end
	Runtime:addEventListener( "enterFrame", loginSceneHandler )
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

	-- Do nothing
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

	-- INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
--	usernameField:removeSelf()
--	passwordField:removeSelf()
	submitBtn:removeSelf()
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
