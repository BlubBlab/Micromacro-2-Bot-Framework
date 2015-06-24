include("object.class.lua");
include("objectlists.settings.lua");

CObjectQueue = class(
	function (self)
		self.Queue = {};
		self.Pointer = ;
	end
);

function CObjectQueue:update()
	self.Queue = {}; -- Flush all objects.
	local evalAddresse = objectslists.funcs["objectlists_eval_addresse"];
	local size = memoryReadInt(getProc(), addresses.staticTableSize);

	for i = 0,size do
		local addr = memoryReadUIntPtr(getProc(), addresses.staticTablePtr, i*4);
		if( evalAddresse( addr )) then
			self.Queue[i] = CObject(addr);
		end
	end
	self.Pointer = #self.Queue;
end

function CObjectQueue:peek()
	if self.Pointer == 0 then
		return nil;
	end
	
	if(self.Queue[self.Pointer] ~= nil)then
		--update object
		self.Queue[self.Pointer]:update();
		
		if(self.Queue[self.Pointer]~=nil)then
			return self.Queue[self.Pointer];
		else
			self.Queue[self.Pointer] = nil;
			self.Pointer = self.Pointer - self.Pointer;
			return self:peek();	
		end
	else
		self.Queue[self.Pointer] = nil;
		self.Pointer = self.Pointer - self.Pointer;
		return self:peek();	
	end

end

function CObjectQueue:poll()
	if self.Pointer == 0 then
		return nil;
	end
	
	if(self.Queue[self.Pointer] ~= nil)then
		--update object
		self.Queue[self.Pointer]:update();
		
		if(self.Queue[self.Pointer] ~= nil)then
			-- we remove the header;
			self.Queue[self.Pointer] = nil;
			self.Pointer = self.Pointer - self.Pointer;
			return self.Queue[self.Pointer];
		else
			self.Queue[self.Pointer] = nil;
			self.Pointer = self.Pointer - self.Pointer;
			return self:peek();	
		end
	else
		self.Queue[self.Pointer] = nil;
		self.Pointer = self.Pointer - self.Pointer;
		return self:peek();	
	end
end

function CObjectQueue:add(object)
	self.Pointer = self.Pointer + self.Pointer;
	self.Queue[self.Pointer] = object;
end

function CObjectQueue:size()
	return #self.Queue;
end