include("object.class.lua");
include("objectlists.settings.lua");

CObjectQueue = class(
	function (self)
		self.Queue = {};
		self.first = 0;
		self.last = -1;
	end
);

function CObjectQueue:update()
	self.Queue = {}; -- Flush all objects.
	local evalAddresse = objectslists.funcs["objectlists_eval_addresse"];
	local size = memoryReadInt(getProc(), addresses.staticTableSize);

	for i = 0,size do
		local addr = memoryReadUIntPtr(getProc(), addresses.staticTablePtr, i*4);
		if( evalAddresse( addr )) then
			object = CObject(addr);
			if(object ~= nil)then
				self:add(object);
			end
		end
	end
	
	--self.Pointer = #self.Queue;
end

function CObjectQueue:peek( type )
	local first = self.first:
	
	if first > self.last then 
		return nil;
	end	
	
	if(self.Queue[first] ~= nil)then
		--update object
		self.Queue[first]:update();
		
		if(self.Queue[first] ~= nil)then
			if(not type or self.Queue[first].Type == type)then
				local value = self.Queue[first]
				-- we peek only
				--self.Queue[first] = nil        -- to allow garbage collection
				--self.first = first + 1
				return value;
			else
				self.Queue[first] = nil        -- to allow garbage collection
				self.first = first + 1
				return self:peek();	
			end
		else
			self.Queue[first] = nil        -- to allow garbage collection
			self.first = first + 1
			return self:peek();	
		end
	else
		self.Queue[first] = nil        -- to allow garbage collection
		self.first = first + 1
		return self:peek();	
	end

end

function CObjectQueue:poll( type )
	local first = self.first:
	
	if first > self.last then 
		return nil;
	end	
	
	if(self.Queue[first] ~= nil)then
		--update object
		self.Queue[first]:update();
		
		if(self.Queue[first] ~= nil)then
			if(not type or self.Queue[first].Type == type)then
				local value = self.Queue[first]
				self.Queue[first] = nil        -- to allow garbage collection
				self.first = first + 1
				return value;
			else
				self.Queue[first] = nil        -- to allow garbage collection
				self.first = first + 1
				return self:poll();	
			
			end
		else
			self.Queue[first] = nil        -- to allow garbage collection
			self.first = first + 1
			return self:poll();	
		end
	else
		self.Queue[first] = nil        -- to allow garbage collection
		self.first = first + 1
		return self:poll();	
	end
end
-
function CObjectQueue:add(object)
	
	--pushright
	local last = self.last + 1
	self.last = last;
	self.Queue[last] = object;
end

function CObjectQueue:size()
	return #self.Queue;
end