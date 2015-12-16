CRegister = class(
	function (self, copyfrom)
		self.EventList = {};
		if( type(copyfrom) == "table" ) then
			self.EventList = copyfrom.EventList;
		end
	end
);

function CRegister:getList()
	return self.EventList;
end
function CRegister:registerEvent( func, name)
	local foundflag = false;
	local list = getList()

	for key,value in pairs(list) do
		if(value == func or string.dump(value)== string.dump(func))then
			foundflag = true;
		end
	end
	-- table are by reference this should work
	if(foundflag == false)then
		if(name)then
			list[name] = func;
		else
			table.insert(list, func)
		end
	else
		print("Function has already registered,so it will be ignored ")
	end
end
--check if already registered
function CRegister:isEvent(func, name)
	local list = getList()
	if(name)then
		if(list[name]~=nil)then
			return true;
		else
			return false;
		end
	end
	local found = false;
	for key,value in pairs(list) do
		if(value == func or string.dump(value)== string.dump(func))then
			found = true;
		end
	end
	return found;
end
function CRegister:unregisterEvent( func_or_name )
	local list = getList()
	if(type(func_or_name) == "string" )then
		if list[name]~=nil then
			list[name] = nil;
			print("Function has been unregistered ")
			return true;
		end
	end
	for key,value in pairs(list) do
		if(value == func_or_name or string.dump(value)== string.dump(func_or_name))then
			value = nil;
			print("Function has been unregistered ")
			return true;
		end
	end
	return false;
end
