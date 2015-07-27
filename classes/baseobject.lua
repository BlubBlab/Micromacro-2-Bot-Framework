CBaseObject = class(
	function (self, ptr)
		self.Address = ptr;
		self.Attackable = false;
		self.Name = "<UNKNOWN>";
		self.Id = 0;
		self.Type = PT_NONE;
		self.X = 0.0;
		self.Y = 0.0;
		self.Z = 0.0;
	end
);