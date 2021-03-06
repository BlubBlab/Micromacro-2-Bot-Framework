--- The Help Modul
-- @module lib2
--
--

--require for compatibility
require"classes";
cli = require"cli";
-- loading the main framework
include("TaskTimer.class.lua");
include("TaskStack.class.lua");

---
-- Any type of var including lists
-- @type var

---
-- One or more incoming argument.
-- @type vars
-- @list <#var>

-- dummy function for compatibility
function setTextColor(...) end
-- function redirection for compatibility
getTime = time.getNow;
--- unpack function with number of arguments on the end.
-- @function[parent=#global] pack
-- @param  #vars ... Args to pack
pack = table.pack;
-- function pack(...)
-- return { n = select("#", ...), ... }
-- end
--- unpack function with number of arguments on the end.
-- @function [parent=#global] unpack
-- @param  #vars ... Args to unpack.
-- @return #table t the unpacked args
unpack = table.unpack;
-- function unpack(...)
-- local n = select('#', ...);
-- local t = {};
-- for i = 1,n do
-- local v = select(i, ...);
-- t[i] = v;
-- end

-- return t;
-- end
--- unpack function with number of arguments on the end.
-- @function [parent=#global] unpack2
-- @param  #vars ... Args to unpack.
-- @return #table t the unpacked args
-- @return #number n Number of args.
function unpack2(...)
	local n = select('#', ...);
	local t = {};
	for i = 1,n do
		local v = select(i, ...);
		t[i] = v;
	end

	return t, n;
end
--- Time delta in milliseconds
-- @function [parent=#global] deltaTime
-- @param #table  time_a The first time table for compare
-- @param #table time_c The second time table for compare
-- @return #number diffrence in milliseconds between the two times.
function deltaTime(time_a,time_b)
	return time.diff(time_a,time_b) *1000;
end
--- Convert hours to timer value
-- @function [parent=#global] hoursToTimer
-- @param #number hours  The time in hours
-- @return #number The time in milliseconds
function hoursToTimer(hours)
	return math.floor( hours * 3600000 );
end

--- Convert minutes to timer value
-- @function [parent=#global] minutesToTimer
-- @param #number minutes  The time in minutes
-- @return #number The time in milliseconds
function minutesToTimer(minutes)
	return math.floor( minutes * 60000 );
end

--- Converts seconds to timer value
-- @function [parent=#global] secondsToTimer
-- @param  #number secounds The time in secounds
-- @return #number The time in milliseconds
function secondsToTimer(seconds)
	return math.floor( seconds * 1000 );
end
--- Make a deep copy of a table
-- @function [parent=#global] deepcopy
-- @param  #table orig The table which should be copy
-- @return #table copy Your new copy
function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

--- Factory function for making a new task
-- @function [parent=#global] taskFactory
-- @pre The TaskStack class must have been loaded previously in the lib2.lia
-- @param #string name The label for the task
-- @param #function func The function which should be called for the task
-- @param #vars ... Any additional args for the task.
-- @post The new task has been added to the task stack.
-- @return #number STATE_PENNDING
function taskFactory(name, func,...)

	taskstack:push_state(name, func );
	taskstack:push_args(...)

	return STATE_PENNDING;

end
--- Factory function for making a new scheduled task
-- @function [parent=#global] timerFactory
-- @pre The TaskTimer class must have been loaded previously in the lib2.lua
-- @param #string name The label for the task
-- @param #number time The interval for the task in  milliseconds.
-- @param #function  func The function which should be called for the task
-- @param #vars ... Any additional args for the task.
-- @return #number STATE_PENNDING
function timerFactory(name, time, func, ...)

	tasktimer:registerTask(name, time, func, ...);

	return STATE_PENNDING;
end
--- Wait function
-- @function [parent=#global] rest
-- @param #number msec Time in milliseconds to wait.
-- @post We have waited our time.
-- @notice The use of this function not recommend.
function rest(msec)


	os.execute("sleep -m" .. tonumber(msec))

	--[[	local i = 0;

		while( deltaTime(getTime(), startTime) < msec ) do

			i = i + 1;

		end

		return i;

		]]--
end
--- Wait function but let scheduled tasks run if possible.
-- @function [parent=#global] yrest
-- @pre The TaskTimer class must have been loaded previously in the lib2.lu
-- @param #number msec Time in milliseconds to wait.
-- @post We have waited our time.
-- @notice The use of this function not recommend.
function yrest(msec)
	if( msec == nil ) then error("yrest() cannot rest for \'nil\'.\n", 2); end;

	local resttime = 10;
	local startTime = getTime();

	if( msec < resttime ) then
		rest(msec);
		return;
	else

		while( deltaTime(getTime(), startTime) < msec ) do
			-- timedstate should be an global object.
			tasktimer:timed_run(msec);
			if(deltaTime(getTime(), startTime) < msec )then
				rest(resttime);
			end
		end

	end

	return deltaTime(getTime(), startTime);
end
--- Create a new Task for the purpose of waiting
-- @function [parent=#global] restTask
-- @param #number msec Time in milliseconds to wait.
-- @post We have waited our time.
-- @return #number CTask#STATE_PENNDING
-- @notice This will not stop scheduled tasks from running;
function restTask(msec)
	local function wait(self,start,msec)

		if(deltaTime(getTime(), startTime) >= msec )then
			return STATE_SUCCESS;
		else
			return STATE_PENNDING;
		end
	end
	taskstack:push_state("STATE_REST_TASK",wait );
	taskstack:push_args(getTime(),msec)

	return STATE_PENNDING;
end
--- Create a new Task for the purpose of waiting
--
-- This function generate a task in which MM will wait and let scheduled tasks run if possible.
-- so that the scheduled tasks will have a greater priority
-- @function [parent=#global] yrestTask
-- @param #number msec Time in milliseconds to wait.
-- @post We have waited our time.
-- @return #number CTask#STATE_PENNDING
function yrestTask(msec)
	local function wait(self,start,msec)
		tasktimer:timed_run(msec);
		if(deltaTime(getTime(), startTime) >= msec )then
			return STATE_SUCCESS;
		else
			return STATE_PENNDING;
		end
	end
	taskstack:push_state("STATE_YREST_TASK", wait );
	taskstack:push_args(getTime(),msec)

	return STATE_PENNDING;
end


