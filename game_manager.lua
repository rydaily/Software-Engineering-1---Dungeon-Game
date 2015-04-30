local level = require("mapFile")
local chars = require("characterFile")

local physis = require("physics")
local widget= require("widget")

physics.start()

hero_image = "hero_sheet.png"

-- Displays Hero's info and stats

function hero_screen_display()
	
	local HeroText = display.newText("Hero " .. hero.ch.level, 50, 25, "Arial", 20)
			
	local health = display.newText("HP: " .. hero.ch.cur_health .. " / " .. hero.ch.max_health, 49,50, "Arial", 20)
			
	local mana = display.newText("MP: " .. hero.cur_mana .. " / " .. hero.max_mana, 50,75, "Arial", 20)
 			
	local exp = display.newText("EXP: " .. hero.cur_exp .. " / " .. hero.max_exp, 43,100, "Arial", 20)

	local statistics = { HeroText, health, mana, exp }

	return statistics
end

-- Clears old stats and calls to display new ones on a level, health, or mana update

function update_hero_stats()
	for i = 1, #stats do
		display.remove( stats[i] )
		stats[i] = nil
	end
	local statistics = hero_screen_display()
	return statistics
end

-- Creates a new Monster image and adds it to the map

function new_monster(type, x, y, difficulty, sequence)
	local Nmonster = chars.monster(hero.ch.level + difficulty)
	Nmonster.type = type

	Nmonster.image = level.update_image(type .. ".png")
	Nmonster.image.x = x
	Nmonster.image.y = y

	add_map_object( Nmonster.image )

	Nmonster.image:setSequence(sequence)
	Nmonster.image:play()

	physics.addBody( Nmonster.image, { density = 500, friction = 0, bounce = 0.8 } )

	return Nmonster
end

-- Creates a new Level Boss image and adds it to the map

function new_level_boss( image, x, y, sequence)
	levelBoss = chars.levelBoss(hero.ch.level + 5)

	levelBoss.image = level.update_image(image .. ".png")
	levelBoss.image.x = x
	levelBoss.image.y = y

	add_map_object( levelBoss.image )

	levelBoss.image:setSequence(sequence)
	levelBoss.image:play()

	physics.addBody( levelBoss.image, { density = 500, friction = 0, bounce = 0.8 } )

	return levelBoss

end

function quit(event)
	os.exit()
end

function combat_over(event)
	background:removeSelf()
	display.remove(title)
	display.remove(vicText)
	
	hero:update_cur_exp(monster.exp_drop)

	stats = update_hero_stats()
	display.remove( player )
	display.remove( mImage )
	continue:removeSelf()
end

function game_over()
	display.remove( title )	
	title = display.newText("Game Over", display.contentWidth/2, 25, "Arial", 30)
	player = level.update_image(hero_image)
	player.x = display.contentWidth/2 - 3
	player.y = display.contentHeight/2 + 30
	player:setSequence("hurt")
	player:play()
	defText = display.newText("Defeat", display.contentWidth/2, display.contentHeight/2 - 50, "Arial", 20)
	exitBtn = widget.newButton{left = display.contentWidth/2 - 93,top = display.contentHeight/2 - 50, label = "Quit",labelColor = { default={1,1,1}, over={0,0,0,1} }, onPress = quit}
end

hero = hero()

stats = hero_screen_display()

monster1 = new_monster("Orc", 200, 400, 2, "bow")

monster2 = new_monster("Ghost", 400, 450, 3, "meditate")

monster3 = new_monster("Skeleton", 800, 200, 2, "bow")

LB = new_level_boss("Monk", 800, 450, "wand")

hero.image = add_hero_object("hero_sheet.png")

-- Clears old monster stats and calls to display new ones

function update_monst_stats(list)
	for i = 1, #list do
		display.remove( list[i] )
		list[i] = nil
	end
	local statistics = monster_screen_display()
	return statistics
end

function health_attack(char, attack)
	local damage = attack - char.defense
	if damage > 0 then
		if (char.cur_health - damage < 0) then
			char.cur_health = 0
		else
			char.cur_health = char.cur_health - damage
		end
	end
end

function combat_buttons(mstats)
	local normalAtk = nil
	local spellAtk = nil
	local active = nil

	local function Ndamage(event)
		player:setSequence("right_dagger")
		combat_turn(hero.ch.attack, mstats)
		normalAtk:removeSelf()
		spellAtk:removeSelf()
	end
	local function Sdamage(event)
		active = hero:update_cur_mana(-9)
		-- If you have the mana, cast spell for 30 damage
		if active == true then
			player:setSequence("right_heal")
			combat_turn( 30, mstats )
		-- If you are out of mana, uses basic attack instead
		else
			Ndamage(event)
		end
		normalAtk:removeSelf()
		spellAtk:removeSelf()
	end

	normalAtk = widget.newButton{left = -75,top = display.contentHeight - 50, label = "Sword",labelColor = { default={1,1,1}, over={0,0,0,1} }, onPress = Ndamage}
	spellAtk = widget.newButton{left = 75,top = display.contentHeight - 50, label = "Spell",labelColor = { default={1,1,1}, over={0,0,0,1} }, onPress = Sdamage}
end
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

-- Displays Monster's info and stats

function monster_screen_display()

	local mText = display.newText(monster.type , display.contentWidth - 30, 25, "Arial", 20)
	local mHealth = display.newText("HP: " .. monster.ch.cur_health .. " / " .. monster.ch.max_health,display.contentWidth - 30,50, "Arial", 20)

	local list = { mText, mHealth }

	return list	
end

function enter_combat( )

	-- Display the combat level
	background = display.newImage("images/dungeon.jpg",display.contentWidth/2, display.contentHeight/2, true)
	background:scale(2,2)
	title = display.newText("Combat", display.contentWidth/2, 15, "Arial", 20)
	local i = 0

	stats = update_hero_stats()
	mstats = monster_screen_display( )

	-- Pop up message
	local function begin(event)
		player = level.update_image(hero_image)
		player.x = 125
		player.y = (display.contentHeight/2) + 50
		player:setSequence("right_dagger")
		
		if (monster.type == "Level Boss") then
			mImage = level.update_image("Monk.png")
			mImage:setSequence( "left_wand" )
		else
			mImage = level.update_image(monster.type .. ".png")
			if (monster.type == "Ghost") then
				mImage:setSequence( "left_heal" )
			elseif (monster.type == "Skeleton" or monster.type == "Orc") then
				mImage:setSequence( "left_bow" )
			end
		end
		mImage.x = 335
		mImage.y = (display.contentHeight/2) + 50
		
		
		combat_buttons( mstats )
		beginBtn:removeSelf()
	end
	if (monster.ch.cur_health > 0) and (hero.ch.cur_health > 0) then
		beginBtn = widget.newButton{left = display.contentWidth/2 - 95,top = display.contentHeight/2 - 25, label = "Begin",labelColor = { default={1,1,1}, over={0,0,0,1} }, onPress = begin}
	end

end

function combat_turn( damage, mstats )
	-- Hero Turn
	player:play()
	health_attack(monster.ch, damage)
	mstats = update_monst_stats( mstats )

	-- Monster Turn
	local function monster_turn()
		mImage:play()
		health_attack(hero.ch, monster.ch.attack)
		stats = update_hero_stats()
	end
	if (monster.ch.cur_health > 0) and ( hero.ch.cur_health > 0 ) then
		timer.performWithDelay(750, monster_turn)
	end
	if( monster.ch.cur_health > 0) and ( hero.ch.cur_health > 0 ) then
		-- Combat Continues
		combat_buttons(mstats)
	elseif (monster.ch.cur_health == 0) then
		-- Monster is defeated and combat ends
		vicText = display.newText("Victory!", display.contentWidth/2 ,display.contentHeight/2 - 25, "Arial", 20)
		continue = widget.newButton{left = display.contentWidth/2 - 93, top = display.contentHeight/2 - 25, label = "Continue", labelColor = { default={1,1,1}, over = {0,0,0,1} }, onPress = combat_over}
		mImage.isVisible = false
		display.remove(mstats[1])
		display.remove(mstats[2])
	else
		-- Hero is defeated and combat ends
		display.remove( player )
		display.remove( mImage )
		game_over()
	end
	
end

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-- Following event listeners detect combat collisions

function O_1(event)
	if (event.phase == "began") then
		monster = monster1
		monster.ch = monster1.ch
		enter_combat()
		if(hero.ch.cur_health > 0) then
			display.remove(monster1.image)
		end
	end
end 

monster1.image:addEventListener("collision", O_1)

function O_2(event)
	if (event.phase == "began") then
		monster = monster2
		monster.ch = monster2.ch
		enter_combat()
		if(hero.ch.cur_health > 0) then
			display.remove(monster2.image)
		end
	end
end 

monster2.image:addEventListener("collision", O_2)

function O_3(event)
	if (event.phase == "began") then
		monster = monster3
		monster.ch = monster3.ch
		enter_combat()
		if(hero.ch.cur_health > 0) then
			display.remove(monster3.image)
		end
	end
end 

monster3.image:addEventListener("collision", O_3)

function O_LB(event)
	if (event.phase == "began") then
		monster = LB.mr
		monster.ch = LB.mr.ch
		enter_combat()
		if(hero.ch.cur_health>0) then
			display.remove(LB.image)
		end
	end
end 

LB.image:addEventListener("collision", O_LB)
