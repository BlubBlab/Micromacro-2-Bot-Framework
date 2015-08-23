dyinclude("classes/abstract.skillset.class.lua",true);

CSkillSet = class(CAbstractSkillSet,
	function (self, copyfrom)
		self.funcs = {};
		if( type(copyfrom) == "table" ) then
			self.funcs = copyfrom.funcs;
		end
	end
	
);
