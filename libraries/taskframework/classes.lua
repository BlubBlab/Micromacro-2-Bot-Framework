local global = _G;



global.class = function(base, ctor, inheritctor)
	local c = {};

	if( inheritctor == nil ) then inheritctor = true; end;

	if( not ctor and global.type(base) == 'function' ) then
		ctor = base;
		base = nil;
	elseif( global.type(base) == 'table' ) then
		for i,v in global.pairs(base) do
			c[i] = v;
		end
		c.parent = base;
	end;
	c.__index = c;
	--c.parent = base;
	c.constructor = ctor;
	c.inheritctor = inheritctor;


	local metatable = {};
	metatable.__call = function(class_tbl, ...)
		local obj = {};
		global.setmetatable(obj, c);

		--obj.parent = class_tbl;

		if( base and class_tbl.constructor ) then
			if( inheritctor ) then -- Run baseclass constructor first
				-- First, we must create a list of all constructors
				-- that we will  be using.
				local cbase = base;
				local ctorlist = {};
				while( cbase ) do
					if( cbase.constructor ) then
						global.table.insert(ctorlist, cbase.constructor);

						if( cbase.inheritctor ~= true ) then break; end;
						cbase = cbase.parent;
					end
				end

				-- Now we call the constructors in reverse order
				for i = #ctorlist,1,-1 do
					ctorlist[i](obj, ...);
				end
			end

			-- Run new constructor
			class_tbl.constructor(obj, ...);
		elseif( class_tbl.constructor ) then
			class_tbl.constructor(obj, ...);
		else
			if( base and base.constructor ) then
				base.constructor(obj, ...);
			end;
		end;

		return obj;
	end;


	c.is_a = function(self, _basetype)
		local mt = global.getmetatable(self);
		local parent_mt = global.getmetatable(_basetype);
		while( mt ) do
			if( mt == _basetype or mt == parent_mt ) then
				return true;
			end;

			mt = mt.parent;
		end

		return false;
	end;


	global.setmetatable(c, metatable);
	return c;
end
