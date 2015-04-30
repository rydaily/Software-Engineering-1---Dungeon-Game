
--------------- Character Class ---------------

Character = {}
Character.__index = Character

function Character.create(level)

   	local ch = {}             	-- new object

   	setmetatable(ch,Character)   	-- make Character handle lookup
   
   	ch.level = level		-- initialize object attributes (data)
   	ch.max_health = 0
   	ch.cur_health = 0
   	ch.attack = 0      	
   	ch.defense = 0

   	return ch

end

----------- Character Set Methods -----------

 -- Initializes character's max health

function Character:set_max_health()
   	self.max_health = self.level * self.level + 50
end

 -- Initializes character's starting health

function Character:set_cur_health()
   	self.cur_health = self.max_health
end

 -- Sets character attack based on base stats 
 -- and values on equipped items

function Character:set_attack(items)
   	self.attack = math.ceil(self.level * 1.6 + items)
end

 -- Sets character defense based on base stats 
 -- and values on equipped items

function Character:set_defense(items)
   	self.defense = math.ceil(self.level * 1.2 + items)
end

------------- Character Update Method -------------

function Character:update_char(atk, def)
   	self:set_max_health()
   	self:set_attack(atk)
   	self:set_defense(def)
end

------------------ Combat Methods ------------------

 -- Called by the character taking damage with 
 -- the damage value of the enemy attack

function Character:health_attack(attack)
   	local damage = attack - self.defense
   	if damage > 0 then
		if (self.cur_health - damage < 0) then
			self.cur_health = 0
		else
   			self.cur_health = self.cur_health - damage
		end
	end
end

function attack(char, atk)
	char:health_attack(atk)
end

function Character:health_heal(heal)
	if heal > 0 then
		if self.cur_health + heal < self.max_health then
   			self.cur_health = self.cur_health + heal
		else
			self.cur_health = self.max_health
		end
	end
end

function heal(char, amount)
	char:health_heal(amount)
end

----------- Hero Class *inherits from character -----------

Hero = {}
Hero.__index = Hero

function Hero.create()

   	local hr = {}
   	setmetatable(hr,Hero)
   	hr.ch = Character.create(1)

	hr.max_mana = 0
   	hr.cur_mana = 0
	hr.max_exp = 0
   	hr.cur_exp = 0

	hr.image = nil

	hr:update_hero(10, 5)		-- initialize Hero's character attributes
	hr.ch:set_cur_health()
	hr:set_cur_mana()

   	return hr

end

function hero()
	hero = Hero.create()
	return hero
end

---------------- Hero Set Functions ----------------

 -- Initializes total mana reserve

function Hero:set_max_mana()
	self.max_mana = self.ch.level + math.ceil(self.ch.max_health/2)
end

 -- Initializes current mana value

function Hero:set_cur_mana()
	self.cur_mana = self.max_mana
end

 -- Initializes total exp reserve

function Hero:set_max_exp()
	self.max_exp = self.ch.level * 3 + math.ceil(self.ch.level/2)
end

---------------- Hero Update Functions ----------------

function Hero:update_hero(atk, def)
	self.ch:update_char(atk, def)
	self:set_max_mana()
	self:set_max_exp()
end

 -- Updates current exp value and levels up if needed

function Hero:update_cur_exp(gain)
	self.cur_exp = self.cur_exp + gain
	while self.cur_exp >= self.max_exp do
		self.cur_exp = self.cur_exp - self.max_exp
		self:level_up()
		if self.ch.level == 50 then
			self.cur_exp = 0
			self.max_exp = 0
			gain = 0
			break
		end
	end
end

 -- Uses other update functions to set the base stats of the hero
 -- based on the new level.

function Hero:level_up()
	if self.ch.level < 50 then
		self.ch.level = self.ch.level + 1
		self:update_hero(self.ch.attack, self.ch.defense)
	end
end

 -- Updates current mana value
 -- change must be negative for spell usage calls

function Hero:update_cur_mana(change)
	if self.cur_mana + change < self.max_mana and self.cur_mana + change >= 0 then
		self.cur_mana = self.cur_mana + change
	elseif self.cur_mana + change >= self.max_mana then
		self.cur_mana = self.max_mana
	else
		return false
	end
	return true
end

----------- Monster Class *inherits from character -----------

Monster = {}
Monster.__index = Monster

function Monster.create(level)

   	local mr = {}

   	setmetatable(mr,Monster)
   	mr.ch = Character.create(level)

   	mr.exp_drop = 0
 
	mr.type = nil
	mr.image = nil

	mr:update_monster(level,0)

   	return mr

end

function monster(level)
	local monster = Monster.create(level)
	return monster
end

-------------------- Monster Set Functions --------------------

function Monster:set_exp_given()
	self.exp_drop = self.ch.level - 1
end

------------------ Monster Update Functions -------------------

function Monster:update_monster(atk, def)
	self.ch:update_char(atk,def)
	self.ch:set_cur_health()
	self:set_exp_given()
end

----------- Level Boss Class *inherits from monster -----------

LevelBoss = {}
LevelBoss.__index = LevelBoss

function LevelBoss.create(level)

   	local lb = {}

   	setmetatable(lb,LevelBoss)

   	lb.mr = Monster.create(level)
	lb.mr.type = "Level Boss"

   	lb.name = nil

   	return lb

end

function levelBoss(level)
	levelBoss = LevelBoss.create(level)
	return levelBoss
end


-- The following list allows you to call functions in this file from another file
-- There are several conditions:
	-- Only the functions listed can be called
	-- You still have to pass parameters in the new file
	-- Functions can only be used by the correct type of objects in the new file
	-- ex: Character:update_char must still be called by a character object.

local FnList = {

hero = hero,
monster = monster,
levelBoss = levelBoss,

attack = attack,
heal = heal,

update_cur_exp = update_cur_exp,
update_cur_mana = update_cur_mana
}

return FnList