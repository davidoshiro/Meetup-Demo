-- require("debugger")()
-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- show default status bar (iOS)
display.setStatusBar( display.DefaultStatusBar )

-- include Corona's "widget" library
local widget = require "widget"
local storyboard = require "storyboard"

local Meetup = require("Meetup")
storyboard.meetup_cli = Meetup.new({
	apiKey = '7f1181a70671e242e191b27f1f2e3f',
	consumerKey = 'js66kpq4b2c19ej3qnjrbrhj68',
	consumerSecret = 'n4vi5vjmapfuagu6u38lvoaf15'
})

local function onLoginView(event)
	storyboard.gotoScene("login")
end

-- event listeners for tab buttons:
local function onFirstView( event )
	storyboard.gotoScene( "members" )
end

local function onSecondView( event )
	storyboard.gotoScene( "topics" )
end

local function onThirdView( event )
	storyboard.gotoScene( "messages" )
end

-- create a tabBar widget with two buttons at the bottom of the screen

-- table to setup buttons
local tabButtons = {
	{ label="Members", up="icon1.png", down="icon1-down.png", width = 32, height = 32, onPress=onFirstView },
	{ label="Topics", up="icon2.png", down="icon2-down.png", width = 32, height = 32, onPress=onSecondView },
	{ label="Messages", up="icon2.png", down="icon2-down.png", width = 32, height = 32, onPress=onThirdView }
}

-- create the actual tabBar widget
storyboard.tabBar = widget.newTabBar{
	top = display.contentHeight - 50,	-- 50 is default height for tabBar widget
	buttons = tabButtons
}

onLoginView()	-- invoke first tab button's onPress event manually
