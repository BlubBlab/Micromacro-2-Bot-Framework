CInputOutput = class(
	function (self, procHandle))
		self.procHandle = procHandle	
	end
);

-- objects
function CInputOutput:ObjectId(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnId_offset ) or 0;
end

function CInputOutput:ObjectType(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnType_offset ) or -1;
end

function CInputOutput:ObjectNamePtr(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnName_offset )
end

function CInputOutput:ObjectName(Address)
	return process.read(self.procHandle, "string", Address )
end

function CInputOutput:ObjectPosition(which, Address)
	
	if(string.lower(which) == "x" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnX_offset ) or 0;
	elseif string.lower(which) == "y" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnY_offset ) or 0;
	elseif string.lower(which) == "z" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnZ_offset ) or 0;
	end
	error("not specific coordinate type");
end

-- object lists
function CInputOutput:ObjectListSize(Address)
	return process.read(self.procHandle, "int", addresses.staticTableSize );
end

function CInputOutput:ObjectListPtr(mult)
	-- 4 = 4 byte
	return process.readPtr((self.procHandle, "uint", addresses.staticTableSize,mult * 4 );
end