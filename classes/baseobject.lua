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
function CBaseObject:equals(obj)
	return self == obj
end
function CBaseObject:wait(timeout, msc)
	if (timeout < 0)then
		error("timeout value is negative");
	end
	if (msc < 0 or msc > 999999)then
		error( "millisecond timeout value out of range");
	end
     
	if (msc >= 500000 or (msc ~= 0 and timeout == 0))then
		timeout++;
	end
	system.rest(msc)
end
function CBaseObject:hashCode()
	return string.dump(self)
end
function CBaseObject:toString()
	local classname = getClass()
	local hash = self:hashCode()
	return classname + "@" + string.format("%x",""..hash.."");
end
