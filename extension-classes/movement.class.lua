dyinclude("classes/abstract.movement.class.lua",true);
CMovement = class(CAbstractMovement,
	function (self, copyfrom)
		self.type = "defualt"
		if( type(copyfrom) == "table" ) then
			self.type = copyfrom.type;
		end
	end

);
