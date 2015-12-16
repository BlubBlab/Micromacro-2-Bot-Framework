camera = {}
camera.settings = {}
camera.funcs = {}

camera.settings["max_view"]= 125;

camera.funcs["camera_update_check"] = function(self)
	if( self.XUVec == nil or self.YUVec == nil or self.ZUVec == nil or
		self.X == nil or self.Y == nil or self.Z == nil ) then
		error("Error reading memory in CCamera:update()");
	end

end
