dyinclude("classes/abstract.database.class.lua",true);

CDatabase = class(CAbstractDatabase,
	function (self, copyfrom)
		self.Skills = {}
		self.Nodes = {}
		self.Utf8_ascii = {}
		self.Consumables = {}
		self.Giftbags = {}

		if( type(copyfrom) == "table" ) then
			self.Name = copyfrom.Name;
			self.Id = copyfrom.Id;
			self.Type = copyfrom.Type;
		end
	end

);
