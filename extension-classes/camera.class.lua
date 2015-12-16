dyinclude("classes/abstract.camera.class.lua",true);

CCamera = class(CAbstractCamera,
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




