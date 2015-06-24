objects = {};
objects.settings = {};
-- values for object types
objects.settings["PT_NONE"] = -1;
objects.settings["PT_PLAYER"] = 1;
objects.settings["PT_MONSTER"] = 2;
objects.settings["PT_NPC"] = 4;
objects.settings["PT_NODE"] = 4;

objects.funcs ={};

-- eval funcs for object:update()

objects.funcs["objecte_eval_id_and_type"] = function( id ,type )
	
	if( 1 > id or id > 999999 or type == objects.settings["PT_NONE"] )then
		return true;
	else
		return false;
	end
end

objects.funcs["objecte_eval_nameptr"] = function( nameptr )

	if(namePtr == nil or namePtr == 0)then
		return true;
	else
		return false;
	end
end

objects.funcs["objecte_eval_name"] = function( name )

	if(name == nil )then
		return true;
	else
		return false;
	end
end