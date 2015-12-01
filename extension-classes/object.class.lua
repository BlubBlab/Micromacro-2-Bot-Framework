dyinclude("classes/abstract.object.class.lua",true);
CObject = class(CAbstractObject,
	function (self, ptr)
		self.Address = ptr;
	--if( self ~= 0 and self ~= nil ) then self:update(); end
	end
);

function CObject:update()

	self:updateType()
	self:updateId()
	self:updateName()
	self:updateXYZ()

	if( self.Type == PT_MONSTER ) then
		self.Attackable = true;
	else
		self.Attackable = false;
	end

	if( self:getAddress() == nil ) then
		error("Error reading memory in CObject:update()");
	end
end


--implment your own stuff or overwrite existing functions
