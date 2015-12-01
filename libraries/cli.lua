local global = _G;



black = 0;
darkblue = 1;
green = 2;
turquoise = 3;
red = 4;
purple = 5;
forestgreen = 6;
lightgray = 7;
gray = 8;
blue = 9;
lightgreen = 10;
lightblue = 11;
lightred = 12;
pink = 13;
yellow = 14;
white = 15;

local type = global.type;
local error = global.error;
local string = global.string;
local unpack = global.unpack;
local pcall = global.pcall;
local io = global.io;
local tostring = global.tostring;

-- Formatted output
-- C printf-like function
global.printf = function(format, ...)
	local t, n = global.unpack2(...);

	for i = 1,n do
		local v = t[i];
		if( type(v) == "nil" ) then
			local err = global.sprintf("bad argument #%d to 'printf' (got %s)", i, type(v));
			error(err, 2);
		end

		if( type(v) == "table" or type(v) == "boolean" or type(v) == "function"
			or type(v) == "thread" or type(v) == "userdata" ) then
			t[i] = tostring(t[i]);
		end

	end

	local status, err = pcall(string.format, format, unpack(t));

	if( status == false ) then
		error(err, 2);
	end

	io.write(err);
end


-- Formatted output
-- C sprintf-like function
global.sprintf = function(format, ...)
	local t, n = global.unpack2(...);

	for i = 1,n do
		local v = t[i];
		if( type(v) == "nil" ) then
			local err = global.sprintf("bad argument #%d to 'sprintf' (got %s)", i, type(v));
			error(err, 2);
		end

		if( type(v) == "table" or type(v) == "boolean" or type(v) == "function"
			or type(v) == "thread" or type(v) == "userdata" ) then
			t[i] = tostring(t[i]);
		end

	end

	local status, err = pcall(string.format, format, unpack(t));

	if( status == false ) then
		error(err, 2);
	end

	return err;
end

-- Colored printf-like function
global.cprintf = function (color, format, ...)
	local status,msg = global.pcall(global.sprintf, format, ...);

	if( status == false ) then
		global.error(msg, 2);
	else
		global.setTextColor(color);
		global.io.write(msg);
		global.setTextColor(lightgray);
	end
end

-- Colored printf, use |color| to set color
global.cprintf_ex = function (format, ...)
	local color = lightgray;
	local varargIndex = 1;
	if( global.type(format) == "number" ) then
		color = format;
		format = global.select(1, ...);
		varargIndex = 2;
	end;


	local status,msg = global.pcall(global.sprintf, format, global.select(varargIndex,...));

	if( status == false ) then
		global.error(msg, 2);
	else

		local segmentStart = 0;
		local findPos = 0;
		local endPos = 0;
		local curPos = 0;
		local colname;

		while(findPos) do
			if( global.cli[colname] ~= color and global.cli[colname] ~= nil ) then
				color = global.cli[colname];
				global.setTextColor(color);
			end

			findPos, curPos, colname = global.string.find(msg, "|(%a+)|", curPos + 1);

			if( findPos ~= nil ) then
				global.io.write( global.string.sub(msg, segmentStart, findPos - 1) );
				segmentStart = curPos + 1;
			end
		end

		global.io.write( global.string.sub(msg, segmentStart) );

		global.setTextColor(lightgray); -- Reset back to default
	end
end
