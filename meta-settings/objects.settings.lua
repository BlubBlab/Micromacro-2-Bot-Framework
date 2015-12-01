objects = {};
objects.settings = {};
-- remove later
objects.settings["PT_NONE"] = -1;
objects.settings["PT_PLAYER"] = 1;
objects.settings["PT_MONSTER"] = 2;
objects.settings["PT_NPC"] = 4;
objects.settings["PT_NODE"] = 4;

objects.funcs ={};

-- eval funcs for object:update()

objects.funcs["objects_eval_id_and_type"] = function( id ,type )

	if( 1 > id or id > 999999 or type == objects.settings["PT_NONE"] )then
		return true;
	else
		return false;
	end
end

objects.funcs["objects_eval_nameptr"] = function( nameptr )

	if(namePtr == nil or namePtr == 0)then
		return true;
	else
		return false;
	end
end

objects.funcs["objects_eval_name"] = function( name )

	if(name == nil )then
		return true;
	else
		return false;
	end
end
objects.funcs["objects_eval_id"] = function(tmp,self)
	if self.Id == -1 then -- First time. Get it.
		self.Id = tmp
		if self.Id > 999999 then self.Id = 0 end
	elseif self.Id >= PLAYERID_MIN and self.Id <= PLAYERID_MAX then -- player ids can change
		if tmp >= PLAYERID_MIN and tmp <= PLAYERID_MAX then
			self.Id = tmp
	end
	else -- see if it changed
		if tmp ~= self.Id then -- Id changed. Pawn no longer valid
			self.Id = 0
			self.Type = 0
			self.Name = "<UNKNOWN>"
	end
	end
end

PT_NONE = objects.settings["PT_NONE"] or -1;
PT_PLAYER = objects.settings["PT_PLAYER"] or 1;
PT_MONSTER = objects.settings["PT_MONSTER"] or 2;
PT_NPC = objects.settings["PT_NPC"] or 4;
PT_NODE = objects.settings["PT_NODE"] or 4;
