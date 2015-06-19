--- The class for the task stack
-- 
-- version 0.91 beta for the task stack
-- 
-- @module CTaskStack

include("Task.class.lua");

--- debug on/off
local degbug_state = false;

---
-- Any type of var including lists
-- @type var 

---
-- One or more incoming argument.
-- @type vars
-- @list <#var>

--- Constructor of the class CTaskStack
-- @function [parent=#global] CTaskStack
-- @post Object is generated
CTaskStack = class(
function (self)
	--- @list <CTask#task>
	self.entry = {};
end
);

--- It's a fabric method for objects of the class CTaskStack
-- @function [parent=#CTaskStack] new
-- @return #CTaskStack new instance object of CTaskStack
function CTaskStack.new()
	return CTaskStack();
end

--- Push a object on to the stack
-- @function [parent=#CTaskStack] push
-- @pre A instance of the object must be generated previously.
-- @param #vars ... A single object or a list of objects to push on the stack.
-- @post Object(s) are on top of the stack.
-- @notice This functions is for internal use  recommend only.
function CTaskStack:push(...)
	if ... then
		local targs = {...}
		-- add values
		for _,v in ipairs(targs) do
			table.insert(self.entry, v)
		end
	end
end

--- Remove a value from the stack and than push a new value on the stack
--
-- This method is for creating logical switches when you don't want to return to the original task
-- when the new task is finished  through fail or success. That the code is outsouced has only symatic reasons.
--
-- @function [parent=#CTaskStack] push_switch
-- @pre A instance of the object must be generated previously.
-- @callof #pop, #push
-- @param CTask#CTask ... A single task or a list of tasks to push on the stack.
-- @post Remove the task on the top of the stack and push tasks(s) are on top of the stack afterwards.
-- @notice This functions is for internal use  recommend only.
function CTaskStack:push_switch(...)
	self:pop();
	self:push(...);
end
--- Push a new task on the top of the stack
-- The new task that will  be pushed on the stack depends on the args
--
-- @function [parent=#CTaskStack] push_task
-- @pre A instance of the object must be generated previously.
-- @callof #push_switch, #push
-- @param #string name The name of the label for this task
-- @param #function func The function which should be called in this task
-- @param #string fail_name (optional) Name for the label of the task which should be called if the previous task fails.
-- @param #function fail_func (optional)The function which should be called if the previous task fails.
-- @param #string success_name (optional) Name for the label of the task which should be called if the previous task success.
-- @param #function success_func (optional)The function which should be called if the previous task success.
-- @post A new task is on top of the stack.
function CTaskStack:push_state(name , func ,fail_name , fail_func, success_name , success_func)

	local Task = CTask(name , func ,fail_name , fail_func, success_name , success_func);


	if(Task:hasFailInfo() or Task:hasSuccessInfo() )then
		--This will be chosen automatically if you use the extra arguments.
		self:push_switch(Task);

	else
		self:push(Task)
	end

end
--- Put the list of args to the task on top of the stack
-- @function [parent=#CTaskStack] push_args
-- @pre A instance of the object must be generated previously.
-- @pre A task must be on top of the stack.
-- @param #vars ... List of args which should append on the task
-- @post List of args have been appended to the task.
function CTaskStack:push_args(...)

	if(#self.entry == 0)then
		local err = "Error: Args have been passed through push_args() but no task where on the stack.";
		setTextColor(cli.yellow);
		error(err, 2);
		return;
	end

	self.entry[#self.entry]:appendArgs(...);
end
--- Put the lists of args to the task on top of the stack
--
-- This version is for the distribution of the args when you creating
-- logical switches when you don't want to return to the original task
--
-- @function [parent=#CTaskStack] push_args_switch
-- @pre A instance of the object must be generated previously.
-- @pre A task must be on top of the stack.
-- @param #table args List of args which should append on the task for default
-- @param #table fail_args List of args which should append on the task for the case that the task fails.
-- @param #table success_args  List of args which should append on the task for the case that the task success.
-- @post List of args have been appended to the task.
function CTaskStack:push_args_switch(args, fail_args, success_args)

	self.entry[#self.entry]:appendArgsSwitch(args, fail_args, success_args);

end
--- Pop a object from the top of the stack of
-- @function [parent=#CTaskStack] pop
-- @pre A instance of the object must be generated previously.
-- @pre A s must be on top of the stack.
-- @param #number num(optional) Number of object which should be removed from the top of the stack if nil 1
-- @return CTask#CTask  Return the task(s) from the top of the stack depend on the param num
-- @post Object(s) are removed from the stack
-- @notice This functions is for internal use  recommend only.
function CTaskStack:pop(num)

	-- get num values from stack
	local num = num or 1

	-- return table
	local entries = {}

	-- get values into entries
	for i = 1, num do
		-- get last entry
		if #self.entry ~= 0 then
			table.insert(entries, self.entry[#self.entry])
			-- remove last value
			table.remove(self.entry)
		else
			break
		end
	end

	if(#entries ~= 0)then
		-- return unpacked entries
		return unpack(entries)
	else
		return nil;
	end
end
--- Let you peek on the top of the stack without removing anything.
-- @function [parent=#CTaskStack] peek
-- @pre A instance of the object must be generated previously.
-- @pre A task must be on top of the stack.
-- @return CTask#CTask Return the task from the top of the stack.
function CTaskStack:peek()
	if(#self.entry > 0)then
		return  self.entry[#self.entry];
	else
		return nil;
	end
end
--- Get the size of the stack.
-- @function [parent=#CTaskStack] getn
-- @pre A instance of the object must be generated previously.
-- @return #number size of the stack..
function CTaskStack:getn()
	return #self.entry
end

--- list values on screen
-- @function [parent=#CTaskStack] list
-- @pre A instance of the object must be generated previously.
function CTaskStack:list()
	for i,v in pairs(self.entry) do
		print(i, v)
	end
end
--- Get if the stack is empty?
-- @function [parent=#CTaskStack] empty
-- @pre A instance of the object must be generated previously.
-- @return #boolean if the stack is empty or not.
function CTaskStack:empty()
	if(#self.entry == 0)then
		return true;
	else
		return false;
	end
end
--- Run the function for the task which is on top of the stack.
-- @function [parent=#CTaskStack] run
-- @pre A instance of the object must be generated previously.
-- @pre A task should be on top of the stack.
-- @callof #pop, #push, #peek, #push_args.
-- @return #boolean if call was success full, 
-- @return CTask#CONSTANCE What happend STATE_PENNDING, STATE_FAILED ,STATE_SUCCESS, STATE_NIL.
-- @return #vars Unknown amount of args from the called function.
-- @post task are removed from the top of the stack if the called function hasn't returned STATE_PENNDING
-- @notice return STATE_NIL means the stack is empty
function CTaskStack:run()
	local callreport;
	local callargs;
	local task = self:peek();
	if( task == nil)then
		if(degbug_state)then
			cprintf(cli.yellow, "[DEBUG] nil state at stack level %d \n", #self.entry or 0 );
		end
		-- state stack is empty seek new state in main
		return false, STATE_NIL;
	end

	callargs = {task:run()};

	if(#callargs > 0 )then
		callreport = callargs[1];
	end

	--debugging
	if(degbug_state)then
		if(callreport)then
			cprintf(cli.yellow, "[DEBUG] callreport message found:  %s \n",callreport );
		else
			cprintf(cli.yellow, "[DEBUG] no callreport were found \n");
		end
	end

	-- function returned with a demand to called again.
	if(callreport and callreport == STATE_PENNDING )then

		return true ,unpack(callargs);

	end

	-- function returned with a fail
	if(callreport and callreport == STATE_FAILED and task:hasFailInfo())then
		self:pop()
		self:push(task:getFailTask());
		self:push_args(unpack(task:getFailArgs()));

		return false ,callreport;

	elseif(callreport and callreport == STATE_FAILED)then

		return false ,unpack(callargs);

	end

	-- function returned with a success
	if(callreport and callreport == STATE_SUCCESS and task:hasSuccessInfo())then
		self:pop()
		self:push(task:getSuccessTask())
		self:push_args(unpack(task:getSuccessArgs()));

		return true ,callreport;

	elseif(callreport and callreport == STATE_SUCCESS)then
		self:pop()

		return true ,unpack(callargs);
	end
	return true ,unpack(callargs);
end
--- A global object of the class CTaskStack
--  This is the default object
taskstack = CTaskStack.new()