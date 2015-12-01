dyinclude("baseobject.lua");
dyinclude("meta-settings/camara.settings.lua");
--- A module that allow to manipulate the camera
-- @module camera
CAbstractCamera = class(CBaseObject,
	function(self, ptr)
		self.Address = ptr;
		self.XUVec = 0.0;
		self.YUVec = 0.0;
		self.ZUVec = 0.0;

		self.X = 0;
		self.Y = 0;
		self.Z = 0;

		if( self.Address ) then
			self:update();
		end
	end
);

function CAbstractCamera:update()

	self.XUVec = InputOutput:CameraDirection("x", self );
	self.YUVec = InputOutput:CameraDirection("y", self );
	self.ZUVec = InputOutput:CameraDirection("z", self );

	self.X = InputOutput:CameraPosition("x", self );
	self.Y = InputOutput:CameraPosition("y", self );
	self.Z = InputOutput:CameraPosition("z", self );

	camera.funcs["camera_update_check"](self);

end

function CAbstractCamera:setPosition(x, y, z)
	local proc = getProc();

	self.XUVec = x;
	self.YUVec = y;
	if z then
		self.ZUVec = z;
	end
	-- something is wrong
	InputOutput:WriteCameraDirection(x,"x",self);
	InputOutput:WriteCameraDirection(y,"y",self);
	--memoryWriteFloat(proc, self.Address + camZUVec_offset, z);
	--I don't know why Rock5 undone it
	if z then
		InputOutput:WriteCameraDirection(z,"z",self);
	end
end

function CAbstractCamera:setRotation(angle, yangle)

	local maxViewDistance = camera.settings["max_view"]; -- Hard value set by the game
	local px, py, pz = player:getPos();

	local nx = px + math.cos(angle + math.pi) * maxViewDistance;
	local nz = pz + math.sin(angle + math.pi) * maxViewDistance;
	local ny;
	if yangle then
		ny = py +  math.cos(yangle + math.pi) * maxViewDistance;
	end
	InputOutput:WriteCameraPosition(nx,"x",self);
	InputOutput:WriteCameraPosition(nz,"z",self);
	if yangle then
		InputOutput:WriteCameraPosition(ny,"y",self);
	end
end
