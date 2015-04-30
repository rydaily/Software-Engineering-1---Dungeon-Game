local path = system.pathForFile( "saves.lua")

local file = io.open( path, "r" )
savedData = file:read( "*l" )
print(savedData)
io.close( file )
file = nil


lime = require("lime.lime")
local physis = require("physics")

physics.start()



map = lime.loadMap(savedData)

local visual = lime.createVisual(map)


local physical = lime.buildPhysical(map)




local onTouch = function(event)
    
map:drag(event)

end

Runtime:addEventListener("touch", onTouch)

-- Creates and returns a new character

function update_image(image)
	local sheetData = { width = 64*2, height = 64*2, numFrames = 268, sheetContentWidth = 832*2, sheetContentHeight = 1344*2 }
	
	local mySheet = graphics.newImageSheet( "images/" .. image, sheetData )
 
	-- Length of one row of image sheet = 13
	-- There are 21 rows of images this size

  	local sequenceData = {
	-- Idle animations
	{ name = "stand", frames = {27}, time = 0, loopCount = 1},
	{ name = "meditate", frames = {29}, time = 0, loopCount = 1},
	{ name = "bow", frames = {237}, time = 0, loopCount = 1},
	{ name = "wand", frames = {188}, time = 0, loopCount = 1},
	-- Heal animations
	{ name = "forward_heal", frames = {1,2,3,4,5,6,7}, time = 600, loopCount = 1},
	{ name = "left_heal", frames = {118,14,15,16,17,18,19,20,118}, time = 900, loopCount = 1},
    	{ name = "back_heal", frames = {27,28,29,30,31,32,33}, time = 600, loopCount = 1},
	{ name = "right_heal", frames = {144,40,41,42,43,44,45,46,144}, time = 600, loopCount = 1},
	-- Walk animations
	{ name = "forward_walk", frames = {106,107,108,109,110,111,112,113}, time = 800},
	{ name = "left_walk", frames = {118,119,120,121,122,123,124,125,126}, time = 800},
	{ name = "back_walk", frames = {132,133,134,135,136,137,138,139}, time = 800},
	{ name = "right_walk", frames = {144,145,146,147,148,149,150,151}, time = 800},
	-- Attack animations
	{ name = "left_wand", frames = {170,171,172,173,174,175,171}, time = 800, loopCount = 1},
	{ name = "right_dagger", frames = {144,196,197,198,199,200,201,144}, time = 475, loopCount = 1},
	{ name = "left_bow", frames = {234,222,223,224,225,226,227,228,229,230,231,232,233,234}, time = 1500, loopCount = 1},
	-- Defeat animations
	{ name = "hurt", frames = {261,262,263,264,265,266}, time = 2000, loopCount = 1},
	{ name = "dead", frames = {266}, time = 0},
	}

	local animation = display.newSprite( mySheet, sequenceData )

	return animation
end

physics.setGravity(0,0)

--Create the player
function add_hero_object(image)
	char = update_image("hero_sheet.png", "dungeon")
	char.x = display.contentWidth/2   -- center the sprite horizontally
	char.y = display.contentHeight/2  -- center the sprite vertically

	physics.addBody( char, { density = 1, friction = 0.2, bounce = 0.8 } )


	map:addObject( char )
	map:setFocus( char )
	local onUpdate = function( event )
 	
	map:update( event )

	end



end

gameActive = true

function add_map_object( object )
	map:addObject( object )
	map:setPosition( object.x, object.y );
end

--Create the control arrows
local left = display.newImageRect( "images/Left.png", 30, 30 )
left:translate(20, display.viewableContentHeight-50)
left:setFillColor( 0, 1, 0)

local up = display.newImageRect("images/Up.png", 30, 30)
up:translate(50, display.viewableContentHeight-80)
up:setFillColor( 0, 1, 0)

local right = display.newImageRect("images/Right.png", 30, 30)
right:translate(80, display.viewableContentHeight-50)
right:setFillColor( 0, 1, 0)

local down = display.newImageRect("images/Down.png", 30, 30)
down:translate(50, display.viewableContentHeight-20)
down:setFillColor( 0, 1, 0)

--Create a variable for continuous action

pressingButton=false



--Check if the button is being press all the time, calling the function moving as long as it is still pressed

function pressing(event)
   
	if ( pressingButton == true ) then
	
		moving(num);
   
	end

end


Runtime:addEventListener( "enterFrame", pressing )


--Handles every time one button is pressed, accesing that button key to assign it to number, so the method moving knows which button has called

function handling(event)
	
   if(gameActive == true) and (char ~= nil) then
	if ( event.phase == "began" ) then
	
		pressingButton=true;
	
	end
	
	
	if(event.target.x==left.x and event.target.y==left.y) then

		char:setSequence("left_walk")
		num=1;
	
	end

	
	if(event.target.x==up.x and event.target.y==up.y) then
		char:setSequence("forward_walk")
		num=2;
	
	end

	
	if(event.target.x==right.x and event.target.y==right.y) then
		char:setSequence("right_walk")
		num=3;
	
	end

	
	if(event.target.x==down.x and event.target.y==down.y) then

		char:setSequence("back_walk")
		num=4;

	end

	char:play()
	if(event.phase=="ended") then
	
		pressingButton=false;

		char:pause()
	end

   end
	return true

end



--Pause Menu
------------------------------------------------
--Functions of the buttons
continueGame = function()
		continuePaused:removeSelf()
		continuePaused = nil
		exitPaused:removeSelf()
		exitPaused = nil
		pausedBackground:removeSelf()
		pausedBackground = nil
		gameActive = true
	
end


exitGame = function()

		print("Exiting the game")
		native.requestExit()
		os.exit()
end


function combat_pause()
	gameActive = false
end

function combat_restart()
	gameActive = true
end

local function btnTap(event)
	if(gameActive == true) then
	 	widget = require( "widget" )
		-- Disable player interaction with game
		gameActive = false

		-- Background
		pausedBackground = display.newImageRect("images/carbonfiber.jpg",320,150)
		pausedBackground.x = display.viewableContentWidth/2 + 10
		pausedBackground.y = display.viewableContentHeight/2 + 15
		pausedBackground:scale(1,1)

		-- Buttons
		continuePaused = widget.newButton
{

				left = display.viewableContentWidth/5 + 5, 
				top = 120,
				defaultFile = "buttonOrange.png",

				overFile = "buttonOrangeOver.png",
				label = "Continue Game",
				labelColor = { default={1,1,0}, over={0,0,0,1} },
				onPress = continueGame



				}

		exitPaused = widget.newButton
{

				left = display.viewableContentWidth/5 +5, 
				top = 180,
				defaultFile = "buttonOrange.png",

				overFile = "buttonOrangeOver.png",
				label = "Exit Game",
				labelColor = { default={1,1,0}, over={0,0,0,1} },
				onPress=exitGame
				


}
	end
end

local pauseBtn = display.newImageRect ("images/pause.png", 30, 30)
pauseBtn:setFillColor(0,1,0)
pauseBtn.y = 30
pauseBtn.x = display.viewableContentWidth
pauseBtn:addEventListener("tap", btnTap)
-------------------------------------------------

--We produce the movement of the player

function moving(number)
	
	if(number == 1) then

		char.x = char.x-5;
        	
	end
	
	
	if(number == 2) then
     
		char.y = char.y-5;
        
	end

	
	if(number == 3) then

		char.x = char.x+5;

	end

	
	if(number == 4) then

		char.y = char.y+5;

	end
	map:setPosition(char.x, char.y);


end



left:addEventListener( "touch", handling )

up:addEventListener( "touch", handling )

right:addEventListener( "touch", handling )

down:addEventListener( "touch", handling )

-- The following list allows you to call functions in this file from another file
-- There are several conditions:
	-- Only the functions listed can be called
	-- You still have to pass parameters in the new file

local FnList = {
		update_image = update_image,

		add_map_object = add_map_object,
		add_hero_object = add_hero_object,

		combat_pause = combat_pause,
		combat_restart = combat_restart
		}

return FnList
