local nilSelfErrorMessage = "XML object 'self' is nil. Did you use '.' instead of ':'?";

Node = { };
Node.__index = Node;

local function explicitCast(_value, _type)
	-- If no type is given, don't cast.
	if( _type == nil ) then return _value; end;

	if( _type == "string" ) then
		return global.tostring(_value);
	elseif( _type == "number" ) then
		return global.tonumber(_value);
	elseif( _type == "boolean" ) then
		if( _value == "true" ) then return true; end;
		if( _value == "false" ) then return false; end;
		return (global.tonumber(_value)) ~= 0;
	else
		return _value;
	end;
end

Node = class(
function (self, name, subtable)
	--- @list <CTask#task>
	self.name =	name;
	self.attributes ={};	
	self.nodes = {};
	self.value = nil;
	self.subtable = subtable;
end
);


function Node.new(name,attributes,subtable)
	return Node(name,attributes); 
end

-- get a single element by it's name or index
function Node:getElement(index, forcetype)
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	if( type(index) == "string" ) then
		for i,v in pairs(self.nodes) do
			if( v.name == index and i ~= "attributes" ) then
				return explicitCast(v, forcetype);
			end
		end
		return nil; -- not found
	end

	if( type(index) == "number" ) then
		if( index < 1 ) then return nil; end; -- invalid index
		if( index > #self ) then return nil; end; -- invalid index (not 100% accurate, but quick)

		local count = 0;
		for i,v in pairs(self.nodes) do
			if( type(v) == "table" and i ~= "attributes" ) then
				count = count + 1;
				if( count == index ) then
					return explicitCast(v, forcetype);
				end
			end
		end
		return nil; -- not found
	end

	return nil; -- invalid index type, return nil
end

-- get all elements as a table
function Node:getElements()
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	local tmp = {};
	for i,v in pairs(self.nodes) do
		if( type(v) == "table" and i ~= "attributes" ) then
			table.insert(tmp, v);
		end
	end

	return tmp;
end

-- get the number of elements that are a child of this node
function Node:getElementCount()
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	local count = 0;
	for i,v in pairs(self.attributes) do
		if( type(v) == "table" ) then
			count = count + 1;
		end
	end

	return count;
end

function Node:getAttribute(index, forcetype)
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	if( type(index) == "string" or type(index) == "number") then
		return explicitCast(self.attributes[index], forcetype);
	end

	return nil;
end


function Node:getAttributes()
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	return self.attributes;
end

function Node:getAttributeCount()
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	return #self.attributes;
end

-- return _NAME
function Node:getName()
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	return self.name;
end
-- return _VALUE
function Node:getValue(forceType)
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	return explicitCast(self.value, forcetype) or "";
end

-- print a debug string of the current node
function Node:debug()
	if( type(self) ~= "table" ) then error(nilSelfErrorMessage, 2) end;

	local str = string.format("Element \'%s\'", self.name);
	print(str);

	for i,v in pairs(self) do
		str = string.format("  %s:", i);
		print(str, v)
	end

	str = string.format("\n%s._ATTRIBUTES:", self.name);
	print(str);
	for i,v in pairs(self.attributes) do
		str = string.format("  %s:", i);
		print(str, v);
	end
end

function implicitCast(data)
	-- True or false
	if( data == "true" ) then
		return true; end;

	if( data == "false" ) then
		return false; end;

	-- Check if is a valid number
	--if( string.find(data, "^[%-%+]?[0-9]+%.?[0-9]+$") ~= nil ) then
	if( string.find(data, "^[%-%+]?%d+%.?%d+$") ~= nil ) then
		return tonumber(data);
	end

	if( string.find(data, "^%d+$") ~= nil ) then
		return tonumber(data);
	end

	-- Check if is a valid hexidecimal value
	if( string.find(data, "^(0x%x+)$") ~= nil) then
		return tonumber(data:sub(3), 16);
	end

	-- Assume it is a string
	local retstr = tostring(data);

	-- Check if it's an empty string, return nil if it is
	if( retstr == "" ) then
		return nil;
	end;

	return retstr;
end

function Node:setNodes(nodes)
	self.nodes = nodes;
end
function Node:setValue(value)
	self.value = value;
end
function Node:setAttributes(attributes)
	self.attributes = attributes;
end
function Node:prase()
	
	local tmp_nodes = {};
	local tmp_attributes = {};
	local tmp_value = nil;
	local xml_table = self.subtable;
	
	
	if(xml_table[0] == nil)then
		return nil;
	end
	for key,value in pairs(xml_table) do
		if( type(key)~= "number")then
			tmp_attributes[key] = implicitCast(value);
			--print("value N: "..value);
		end
	end
	--Name? 
	if(	xml_table[1] ~= nil and type(xml_table[1]) ~= "table" and type(implicitCast(xml_table[1])) == "string")then
		tmp_value = implicitCast(xml_table[1]);
		--print("value unknown: "..xml_table[1]);
	end
	
	for i = 1, #xml_table do
		if(xml_table[i]~= nil and type(xml_table[i] == "table"))then
			if(xml_table[i][0] ~= nil)then
			local node = Node(implicitCast(xml_table[i][0]),xml_table[i] );
			node:prase(); -- we going recursive;
			--local tablex = node:getAttributes()
			--print("Deep")
			--print_r(tablex);
			table.insert(tmp_nodes,node);
			end
		end
	end
	
	--local node_main = Node(implicitCast(xml_table[0],xml_table))
	
	self:setAttributes(tmp_attributes);
	self:setNodes(tmp_nodes);
	self:setValue(tmp_value);
	return self;
end

function parse_deep(xml_table)
	local tmp_nodes = {};
	local tmp_attributes = {};
	local tmp_value = nil;
	
	
	print_r(xml_table);
	if(xml_table[0] == nil)then
		return nil;
	end
	for key,value in pairs(xml_table) do
		if( type(key)~= "number")then
			tmp_attributes[key] = implicitCast(value);
			--print("attribute: "..value);
		end
	end
	if(	xml_table[1] ~= nil and type(xml_table[1]) == "string")then
		tmp_value = implicitCast(xml_table[1]);
		--print("value"..xml_table[1]);
	end
	for i = 1, #xml_table do
		if(xml_table[i]~= nil and type(xml_table[i]) == "table")then
			if(xml_table[i][0] ~= nil)then
			local node = Node(implicitCast(xml_table[i][0]),xml_table[i] );
			node:prase(); -- we going recursive;
			--local tablex = node:getAttributes()
			---print("not deep")
			--print_r(tablex);
			--local val = node:getValue();
			--print_r(val);
			table.insert(tmp_nodes,node);
			end
		end
	end
	local node_main = Node(implicitCast(xml_table[0]),xml_table);
	node_main:setAttributes(tmp_attributes);
	node_main:setNodes(tmp_nodes);
	node_main:setValue(tmp_value);
	return node_main;
end

