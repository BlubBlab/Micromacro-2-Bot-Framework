--- The class for task
--
-- This is version 0.9 beta of the class for tasks
--
-- @module CTaskTimer
--

include("Task.class.lua");
--- debug on/off
local degbug_timed_state = false;

---
-- Any type of var including lists
-- @type var

---
-- One or more incoming argument.
-- @type vars
-- @list <#var>

--- Constructor of the class CTaskTimer
-- @function [parent=#global] CTaskTimer
-- @post Object is generated
CTaskTimer = class(
	function (self)
		--- @list <CTask#CTask>
		self.entry = {};

		self.lastkey = nil;
	end
);
--- It's a fabric method for objects of the class CTaskStack
-- @function [parent=#CTaskTimer] new
-- @return #CTaskTimer new instanced object of CTaskTimer
function CTaskTimer.new()
	return CTaskTimer();
end

--- Add a task with a timer to the taskplaner so it can run when expected.
-- @function [parent=#CTaskTimer] registerTask
-- @pre A instance of the object must be generated previously.
-- @param #string name The name of the label for this task
-- @param #number time In which interval the task should be called in millisecounds.
-- @param #function func The function which should be called in this task
-- @param #vars ... List of args which should append on this task
-- @callof CTask#CTask, CTask#appendArgs, CTask#setVar
-- @post A new task is added to be called when time has come.
function CTaskTimer:registerTask(name, time, func, ...)
	if( type(func) ~= "function" ) then
		local err = "Error: Non-function type passed to registerTask() where a function is expected.";
		setTextColor(cli.yellow);
		error(err, 2);
		return;
	end

	if( type(time) ~= "number" ) then
		local err = "Error: Non-numerical type passed to registerTask() where a time value is expected.";
		setTextColor(cli.yellow);
		error(err, 2);
		return;
	end

	local tmp = {};

	local task = CTask(name,func);
	task:appendArgs(...);
	task:setVar("state_interval",time)
	task:setVar("last_call",getTime())
	table.insert (self.entry, task);
end
--- Remove a planed task from the entry
-- @function [parent=#CTaskTimer] unregisterTaskTimer
-- @pre A instance of the object must be generated previously
-- @param  #string name The name of the label for this task
-- @callof  CTask#getVar
-- @post The task has been removed from the plan.
function CTaskTimer:unregisterTaskTimer(name)

	for key,task in pairs(self.entry) do
		if(task:getVar("name") == name)then
			return remove(self.entry,task);
		end
	end
	--[[

	if( self.entry[name] ) then

	self.entry[name] = nil;

	end;

	]]--
end
--- Get the size of the list
-- @function [parent=#CTaskTimer] getn
-- @pre A instance of the object must be generated previously.
-- @return #number size of the list..
function CTaskTimer:getn()
	return #self.entry
end

--- List values on screen
-- @function [parent=#CTaskTimer] list
-- @pre A instance of the object must be generated previously.
function CTaskTimer:list()
	for i,v in pairs(self.entry) do
		print(i, v)
	end
end
--- Get if the list is empty?
-- @function [parent=#CTaskTimer] empty
-- @pre A instance of the object must be generated previously.
-- @return #boolean if the stack is empty or not.
function CTaskTimer:empty()
	if(#self.entry == 0)then
		return true;
	else
		return false;
	end
end

--- Let the planned tasks run
-- @function [parent=#CTaskTimer] timed_run
-- @pre A instance of the object must be generated previously.
-- @param #number msec How much time the timedisk should consume
-- @callof  CTask#run, CTask#getVar
-- @post All planed task have run in the avaible time.
-- @notice the maximum time can be exceeded when one task alone consume it.
function CTaskTimer:timed_run(msec)

	local completeloop = true;
	local skip = false;
	local startTime = getTime();
	local max_runtime = msec or 150;
	local callreport;
	local callargs;
	if(#self.entry == 0)then
		if(degbug_timed_state)then
			cprintf(cli.yellow, "[DEBUG] we didn't find any entry");
		end
		return nil;
	end
	if(self.lastkey)then
		skip = true;
	end

	for key,task in pairs(self.entry) do
		local lastcall = task:getVar("last_call") or 0;
		local interval = task:getVar("state_interval");

		if(not skip and  (deltaTime(getTime(),lastcall) > ( interval + 10) ))then

			callargs = {task:run()};
			if(#callargs > 0 )then
				callreport = callargs[1];
			end

			if(degbug_timed_state)then
				if(callreport)then
					cprintf(cli.yellow, "[DEBUG] callreport message found:  %s \n",callreport );
				else
					cprintf(cli.yellow, "[DEBUG] no callreport were found \n");
				end
			end
			if(callreport and (callreport == STATE_FAILED or callreport == STATE_SUCCESS))then
				task:update();
			end
		end

		if(skip and self.lastkey == key)then
			if(degbug_timed_state)then
				cprintf(cli.yellow, "[DEBUG] end skipping because we found key: s%", key);
			end
			skip = false;
		end

		if( (deltaTime(getTime(), startTime) > max_runtime))then
			if(degbug_timed_state)then
				cprintf(cli.yellow, "[DEBUG] break loop because we used up the time: %d", max_runtime);
			end
			self.lastkey = key;
			completeloop = false;
			break;
		end

	end
	if(completeloop)then
		self.lastkey = nil;
	end

end
--- A global object of the class CTaskTimer
--  This is the default object
tasktimer = CTaskTimer.new();




