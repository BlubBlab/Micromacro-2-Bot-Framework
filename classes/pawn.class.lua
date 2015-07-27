CPawn = class(CAbstractPawn,
	function (self, ptr)
		self.Address = ptr;
		self.Name = "<UNKNOWN>";
		self.Id = -1;
		self.GUID  = 0;
		self.Type = PT_NONE;
		self.Classes = pawns.funcs["init_all_classes"]();
		self.Guild = "<UNKNOWN>";
		self.Levels =  pawns.funcs["init_all_levels"]();
		self.HP = 1000;
		self.LastHP = 0;
		self.MaxHP = 1000;
		self.ActivEnergys = pawns.funcs["init_all_activ_energys"]()
		self.Energys = pawns.funcs["init_all_energys"]()
		self.Race = pawns.settings["races_default"];
		self.X = 0.0;
		self.Y = 0.0;
		--make it optional take a look at update
		self.Z = 0.0;
		--end
		self.TargetPtr = 0;
		self.Direction = 0.0;
		self.Attackable = false;
		self.Alive = true;
		self.Mounted = false;
		self.Lootable = false;
		self.Aggressive = false;
		self.Harvesting = false; -- Whether or not we are currently harvesting
		self.Casting = false;
		self.TargetIcon = true
		self.InParty = false
		self.Swimming = false
		self.Speed = 50
		self.IsPet = nil
		self.Buffs = {};

		if( self.Address ~= 0 and self.Address ~= nil ) then self:update(); end
	end
);


function CPawn.new(address)
	local np = CPawn()
	np.Address = address
	return np
end

function CPawn:update()
	local proc = getProc();
	local memerrmsg = "Failed to read memory";
	local tmp;

	if not self:exists() then -- Updates and checks pawn.Id
		return
	end
	local updatelist = pawns.settings["update_flags"];
	-- update list
	if pawns.settings["update_flags"]["updateName"]then self:updateName() end;
	if pawns.settings["update_flags"]["updateAlive"]then self:updateAlive(); end;
	if pawns.settings["update_flags"]["updateHP"] then self:updateHP() end; -- Also updates MaxHP
	if pawns.settings["update_flags"]["updateClass"] then self:updateClass() end;
	if pawns.settings["update_flags"]["updateMP"] then self:updateMP() end; -- Also updates MP2, MaxMP, MaxMP2, Rage, Focus, Energy
	if pawns.settings["update_flags"]["updateLastHP"]then self:updateLastHP() end;
	if pawns.settings["update_flags"]["updateRace"] then self:updateRace(); end;
	if pawns.settings["update_flags"]["updateLevel"] then self:updateLevel(); end;
	if pawns.settings["update_flags"]["updateGUID"] then self:updateGUID() end;
	if pawns.settings["update_flags"]["updateType"] then self:updateType() end;
	if pawns.settings["update_flags"]["updateHarvesting"] then self:updateHarvesting() end;
	if pawns.settings["update_flags"]["updateCasting"] then self:updateCasting()end;
	if pawns.settings["update_flags"]["updateBuffs"] then self:updateBuffs() end;
	if pawns.settings["update_flags"]["updateLootable"] then self:updateLootable() end;
	if pawns.settings["update_flags"]["updateTargetPtr"] then self:updateTargetPtr() end;
	if pawns.settings["update_flags"]["updateXYZ"] then self:updateXYZ() end;
	if pawns.settings["update_flags"]["updateDirection"] then self:updateDirection() end;-- Also updates DirectionY
	if pawns.settings["update_flags"]["updateAttackable"] then self:updateAttackable() end;
	if pawns.settings["update_flags"]["updateMounted"] then self:updateMounted() end;
	if pawns.settings["update_flags"]["updateTargetIcon"] then self:updateTargetIcon() end;
	if pawns.settings["update_flags"]["updateInParty"] then self:updateInParty(); end;
	if pawns.settings["update_flags"]["updateSpeed"] then self:updateSpeed() end;
	if pawns.settings["update_flags"]["updateSwimming"] then self:updateSwimming() end;
	if pawns.settings["update_flags"]["updateIsPet"] then self:updateIsPet() end;

	if( pawns.funcs["pawn_eval_updates"](self)) then

		error("Error reading memory in CAbstractPawn:update()");
	end

end
--implement your own stuff or overwrite existing functions