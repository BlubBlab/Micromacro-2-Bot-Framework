dyinclude("classes/abstract.inputoutput.class.lua",true);
CInputOutput = class(CAbstractInputOutput,
	function (self, procHandle))
		self.procHandle = procHandle	
	end
);