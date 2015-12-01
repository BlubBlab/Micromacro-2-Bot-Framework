skills = {}
skills.settings = {}
skills.funcs = {}


skills.funcs["skills_noskill_zone"] = function(self)
	if getZoneId() == 400 then
		return true
	end
	return false;
end
skills.funcs["skills_ammo_slot"] = function(self)
	equipment.BagSlot[9]:update();
	local ammo = equipment.BagSlot[9];
	return ammo;
end
skills.funcs["skills_need_buff_1"] = function(self)
	-- Needs Willpower state. Willpower Blade, Willpower Construct
	if self.Psi > 0 and (not player:hasBuff(501571)) and (not player:hasBuff(501572)) then

		return true
	end
	return false
end
skills.funcs["skills_need_buff_2"] = function(self)
	-- Main buffs that require 6 psi but don't consume psi.
	if (GetIdName(self.Id) == GetIdName(497955) or -- Willpower Blade
		GetIdName(self.Id) == GetIdName(497956)) and -- Willpower Construct
		player.Psi < 6 then

		return true
	end
	return false
end
skills.funcs["skills_pet_summon"] = function(self)
	petupdate()
	if player.Class1 == CLASS_WARDEN and pet.Name ~= "<UNKNOWN>" then -- have a pet out already
		for k,v in pairs(pettable) do
			if pet.Name == v.name and self.Id == v.skillid then
				PetWaitTimer = 0
				return true;
			end
	end
	end

	if PetWaitTimer == nil or PetWaitTimer == 0 then -- Start timer
		PetWaitTimer = os.time()
		return true
	elseif os.time() - PetWaitTimer < 15 then -- Wait longer
		return true
	end
	return false;
end
skills.funcs["skills_pet_heal"] = function(self)
	-- warden pet heal
	if self.Name == "WARDEN_ELVEN_PRAYER" then
		petupdate()
		if pet.Name == "<UNKNOWN>" or ( pet.HP / pet.MaxHP * 100) > 70 then
			return true
		end
	end
	return false;
end
skills.funcs["skills_use_summon"] = function(self)
	if player.Class1 == CLASS_WARDEN and self.Type == STYPE_SUMMON then
		player:updateBattling()
		if not player.Battling then
			local skillName = GetIdName(self.Id)
			petupdate()		-- code in classes/pet.lua
			-- dont summon warden pet if already summoned.
			if (skillName == GetIdName(493333) and pet.Name ~= GetIdName(102297)) or
				(skillName == GetIdName(493344) and pet.Name ~= GetIdName(102325)) or
				(skillName == GetIdName(493343) and pet.Name ~= GetIdName(102324)) or
				(skillName == GetIdName(494212) and pet.Name ~= GetIdName(102803)) then
				RoMCode("CastSpellByName(\""..skillName.."\");");
				repeat
					yrest(1000)
					player:updateCasting()
				until not player.Casting
				setpetautoattacks()
			end
		end
		return true
	end
end
-- Skill types
STYPE_DAMAGE = 0
STYPE_HEAL = 1
STYPE_BUFF = 2
STYPE_DOT = 3
STYPE_HOT = 4
STYPE_SUMMON = 5

-- Target types
STARGET_ENEMY = 0
STARGET_SELF = 1
STARGET_FRIENDLY = 2
STARGET_PET = 3
STARGET_PARTY = 4

-- AOE target
SAOE_PLAYER = 0
SAOE_TARGET = 1
