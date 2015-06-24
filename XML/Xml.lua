
xml = require("LuaXml");
include("Node.lua");
--local result = xml.load("ks-last-ks.xml");
---local stack = {};
function loadXML(file)
	return xml.load(file)
end

CXML = class(
function (self)
	-- <mylabel,</mylabel
	self.xml = require("LuaXml");
	self.stack = {};
	self.lastXML = {};
end
);

function CXML:pushS(symbol)
	table.insert(self.stack, symbol)
end

function CXML:popS()
	-- = stack[#stack];
	local entry = table.remove(self.stack,#self.stack);
	return entry;
end

function CXML:load(file)
	print(" load:"..file.."");
	self:validXML(file)
	self.lastXML = loadXML(file);
	
	return self.lastXML;
end
function CXML:open(file)
	print(" open:"..file.."");
	--TODO: add file checks
	local xml_load = self:load(file)
	
	local node = parse_deep(xml_load)
	return node;
end
function CXML:save(file)
	return xmlDLL.save(file);
end

function CXML.new()
	return CXML();
end
function CXML:getCore()
	return xmlDLL;
end
function CXML:validXML( file)
	
	file = assert(io.open(file, "r"))
	
	local last1 = 0, last1line, last1row; -- <? , ?>
	local last2 = 0, last2line, last2row; --<![CDATA[ , ]]>
	local last3 = 0, last3line, last3row; -- < , >
	local last4 = 0, last4line, last4row; --"
	local last5 = 0, last5line, last5row; --<! 

	local linecount = 1;
	
	for line in file:lines() do
		local i = 0;
		while(i < string.len(line)) do
			i = i +1;
			--print("what is i :"..i.."");
			local sub1 = nil;
			local sub2 = nil;
			local sub3 = nil;
			local sub9 = nil;
			local jump = false;
			if(i <= string.len(line))then
				sub1 = string.sub(line, i, i)
			end
			if( i + 1 <= string.len(line))then
				sub2 = string.sub(line, i, i+1)
			end
			if( i + 2 <= string.len(line))then
				sub3 = string.sub(line, i, i+2)
			end
			if( i + 8 <= string.len(line))then
				sub9 = string.sub(line, i, i+8)
			end
			-- find a tag between < and > or <? and ?>
			if(not jump and (last3 ~= 0 or last1 ~= 0 ) and string.find(sub1,"[%d-%a]+"))then
				local start, ende =  string.find(line,"[%d-%a]+=\"[^\"]+\"",i);
				if(start == nil)then
					error("Miss match string in: line: "..linecount.." row: "..i.."");
				end
				
				--last4 = last4 + 1;
				-- two matching "
				if(last4%2 == 0)then
					last4 = 0;
				end
				-- we included " one too much so we must exclude it again.
				i = ende-1;
				
				jump = true;
			end
			-- found a <? and we are not inside of <![CDATA[ or <!
			if(not jump and sub2 and sub2 == "<?" and last2 == 0 and last5 == 0)then
				-- ?> wasn't closed
				if(last1 ~= 0)then
					error("Missing ?> in: line: "..linecount.." row: "..i.."");
				end
				jump = true;
				-- increase <? counter
				last1 = last1 + 1;
				-- jump a char
				i = i + 1;
			end
			-- found a ?> and we are not inside of <![CDATA[ or <!
			if(not jump and sub2 and sub2 == "?>" and last2 == 0 and last5 == 0)then
				-- decrease <? counter
				last1 = last1 - 1;
				-- missing <?
				if(last1 ~= 0)then
					error("Missing <? in: line: "..linecount.." row: "..i.."");
				end
				-- the numbers of " are odd
				if(last4 ~=0)then
					error("Unexpected end because of missing \" in: line: "..linecount.." row: "..i.."");
				end
				-- jump a char
				i = i + 1;
				jump = true;
			end
			-- we found a <![CDATA[
			if(not jump and sub9 and sub9 == "<![CDATA[")then
				-- previous <![CDATA[ wasn't closed
				if(last2 ~= 0)then
					error("Missing ]]> before <![CDATA[ in: line: "..linecount.." row: "..i.."");
				end
				-- increase <![CDATA[ counter
				last2 = last2 + 1;
				-- jump a few chars
				i = i + 8;
				jump = true;
			end
			-- found <! for comments 
			if(not jump and sub2 and sub2 == "<!")then
				-- increase <! counter
				last5 = last5 + 1;
				-- jump  char
				i = i + 1;
				jump = true;
			end
			-- we found a ]]> and we are not inside of <!
			if(not jump and sub3 and sub3 == "]]>" and last5 == 0)then
				-- decrease <![CDATA[ counter
				last2 = last2 - 1;
				-- too many closing tags for ]]>
				if(last2 ~= 0)then
					error("Too much ]]> in: line: "..linecount.." row: "..i.."");
				end
				jump = true
				-- skip some chars
				i = i + 2;
			end
			-- we found a </ and we are not inside of <![CDATA[ or <!
			if(not jump and sub2 and sub2 == "</" and last5 == 0 and last2 == 0)then
				-- too many <
				if(last3 ~= 0) then
					error("Too much < in: line: "..linecount.." row: "..i.."");
				end
				-- we missed a " ?
				if(last4 ~=0)then
					error("Unexpected end because of missing \" in: line: "..linecount.." row: "..i.."");
				end
				-- increase < counter
				last3 = last3 + 1;
				-- get </Label
				local start, ende = string.find(line,"</[%d-%a]+",i)
				-- no label found
				if(start == nil)then
					error("Missing symbol after < in: line: "..linecount.." row: "..i.."");
				end
				--compare label names
				local name1 = string.sub(line,start+2, ende )
				local symbol = self:popS();
				local name2 = symbol[1];
				if(name1 ~= name2)then
					error("Missing closing tag for: "..name2.." in: line: "..symbol[2].." row: "..symbol[3].."");
				end
				-- skip some chars
				i = ende ;
				jump = true;
			end
			-- we found a < and we are not inside of <![CDATA[ or <!
			if(not jump and sub1 and sub1 == "<" and last2 == 0 and last5 == 0)then
				-- too many < or better said odd amount
				if(last3 ~= 0) then
					error("Too much < in: line: "..linecount.." row: "..i.."");
				end
				-- we missed a " ?
				if(last4 ~=0)then
					error("Unexpected end because of missing \" in: line: "..linecount.." row: "..i.."");
				end
				-- get <Label
				last3 = last3 + 1;
				local start, ende = string.find(line,"<[%d-%a]+",i)
				-- no label found
				if(start == nil)then
					error("Missing symbol after < in: line: "..linecount.." row: "..i.."");
				end
				-- push name and info
				local name1 = string.sub(line,start+1, ende )
				self:pushS({name1,linecount,i});
				-- skip some chars
				i = ende;
				-- skip rest of the round
				jump = true;
			end
			-- we found a > and we are not inside <![CDATA[ 
			if(not jump and sub1 and sub1 == ">" and last2 == 0)then
				last3 = last3 - 1;
				-- close any <
				if(last3 ~= 0) then
					last3 = 0;
					-- need testing don't know behaviour of LuaXML
					-- error(1,"Unknown > in: line: "..linecount.." row: "..i..);
				end
				-- close --<!
				if(last5 ~= 0)then
					last5 = 0;
				end
				-- closed with an odd number of "
				if(last4 ~=0)then
					error("Unexpected end because of missing \" in: line: "..linecount.." row: "..i.."");
				end
				-- skip rest of the round
				jump = true;
			end
			-- found " and we are not in <![CDATA[ or <!
			if(not jump and sub1 and sub1 == "\"" and last2 == 0 and last5 == 0)then
				-- last3 we are inside < >
				if(last3 ~= 0)then
					last4 = last4 + 1;
					-- two matching "
					if(last4%2 == 0)then
						last4 = 0;
					end
				end
			end
			jump = false;
		end
		linecount = linecount +1;
	end
	
	if(#self.stack~=0)then
		local symbol = popS();
		error("Missing closing tag for: "..symbol[1].." in: line: "..symbol[2].." row: "..symbol[3].." until the end of the file");
	end
	if(last1 ~= 0)then
		error(1,"Missing ?> until the end of file");
	end
	file:close()
end


function CXML:implicitCast(data)
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
	local retstr = global.tostring(data);

	-- Check if it's an empty string, return nil if it is
	if( retstr == "" ) then
		return nil;
	end;

	return retstr;
end
parser = CXML().new();