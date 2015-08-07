CKeys = class(CAbstractKeys,
	function (self, copyfrom)
		self.funcs = {};
		if( type(copyfrom) == "table" ) then
			self.funcs = copyfrom.funcs;
		end
	end
	
);
function CKeys:loadKeys()
	local filename = seekDir("settings.xml");

	self:loadSettings(filename, bot.Gamedirectory, bot.Keybindfile); 
end