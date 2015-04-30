--Main Menu
local widget = require( "widget" )

--Background
local background=display.newImage("images/dungeon1.jpg",display.contentWidth/2, display.contentHeight/2

, true)
background:scale(.5, .5)

--Title

local title = display.newText( "DCG: Underworld", 0, 0, "Calibri", 38 )
	title.x = display.contentWidth/2
	title.y = display.contentHeight/16
	title:setFillColor(1,1,0)


--Functions of the buttons
newGame = function()

	killScreen()
	local game = require("game_manager")
end


continueGame = function()

	-- Not currently implemented
	print("Loading the game")
end


exitGame = function()

	print("Exiting the game")
	killScreen()
	native.requestExit()
	os.exit()
end

--Buttons
local new = widget.newButton
{
left=display.contentWidth/5, top=display.contentHeight/2 - 100,defaultFile = "buttonOrange.png",
overFile = "buttonOrangeOver.png", label = "New Game",labelColor = { default={1,1,0}, over={0,0,0,1} }, onPress=newGame


}

local continue = widget.newButton
{
left=display.contentWidth/5, top=display.contentHeight/2,defaultFile = "buttonOrange.png",
overFile = "buttonOrangeOver.png", label = "Continue Game",labelColor = { default={1,1,0}, over={0,0,0,1} }, onPress=continueGame


}

local exit = widget.newButton
{
left=display.contentWidth/5, top=display.contentHeight/2 + 100,defaultFile = "buttonOrange.png",
overFile = "buttonOrangeOver.png", label = "Exit Game",labelColor = { default={1,1,0}, over={0,0,0,1} }, onPress=exitGame


}

 -- Clear Screen
function killScreen()
	background:removeSelf()
	background = nil
	title:removeSelf()
	title = nil
	new:removeSelf()
	new = nil
	continue:removeSelf()
	continue = nil
	exit:removeSelf()
	exit = nil
end