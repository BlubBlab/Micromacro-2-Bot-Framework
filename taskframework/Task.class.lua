--- The class for the tasks
-- 
--  version 0.5 beta for the task class
--  
-- @module CTask
 
--- debug on/off
local debug_task = false;
--constants for the states.

---
-- One of the global CONSTANCE in this file
-- @type CONSTANCE

--- CONSTANCE For the case the task should run
STATE_PENNDING = 0;
--- CONSTANCE For the case the task has failed
STATE_FAILED = 1;
--- CONSTANCE For the case the task has success
STATE_SUCCESS = 2;
--- CONSTANCE For the case there is no task on the stack
STATE_NIL = 3;

---
-- Any type of var including lists
-- @type var 

---
-- One or more incoming argument.
-- @type vars
-- @list <#var>


--Only until field number 5 are used usually the others are for special cases.

--- @type state
-- @field #string state_name Label of the state
-- @field #function state_func Function which are called for the state
-- @field #vars args List of args with which the current state will be called.
-- @field #number last_call The Time millisec from GetTime() when the last call was.
-- @field #number last_success The Time millisec from GetTime() when the last successful call was.
-- @field #string fail_name Label of the next state if the current fails.
-- @field #function fail_func Function which are called for the next state if the current fails.
-- @field #vars fail_args List of args with which the next state if the current fail will be called.
-- @field #string success_name Label of the next state if the current successed.
-- @field #function success_func Function which are called for the next state if the current success.
-- @field #vars success_args List of args with which the next state if the current success will be called.

--- Constructor of the class CTask
-- @function [parent=#global] CTask
-- @param #string name The name of the label for this task
-- @param #function func The function which should be called in this task
-- @param #string fail_name (optional) Name for the label of the task which should be called if the previous task fails.
-- @param #function fail_func (optional)The function which should be called if the previous task fails.
-- @param #string success_name (optional) Name for the label of the task which should be called if the previous task success.
-- @param #function success_func (optional)The function which should be called if the previous task success.
-- @post Object is generated
CTask = class(
function (self, name , func ,fail_name , fail_func, success_name , success_func)
	--- @list <#state>
	self.entry = {};
	
	if(func == nil or type(func) ~= "function")then
		local err = "Error: Non-function type passed to Task constructor where a function is expected.";
		setTextColor(cli.yellow);
		error(err, 2);
		return;
	end

	if(fail_func and type(fail_func) ~= "function")then
		local err = "Error: Non-function type passed to Task constructor where a function is expected(failed).";
		setTextColor(cli.yellow);
		error(err, 2);
		return;
	end

	if(success_func and type(success_func) ~= "function")then
		local err = "Error: Non-function type passed to Task constructor where a function is expected(success).";
		setTextColor(cli.yellow);
		error(err, 2);
		return;
	end
	self.entry.state_name = name or "STATE_DEFAULT";
	self.entry.state_func = func;
	self.entry.last_call = nil;
	self.entry.last_success = nil;
	self.entry.fail_name = fail_name or "STATE_DEFAULT";
	self.entry.fail_func = fail_func;
	self.entry.success_name =  success_name or "STATE_DEFAULT";
	self.entry.success_func = success_func;
	self.entry.args = nil;
	self.entry.success_args = nil;
	self.entry.fail_args = nil;
end
);
--- Return a custom var for the task
-- @function [parent=#CTask]  getVar
-- @pre A instance of the object must be generated previously.
-- @param #string var_name The name of var
-- @return #var The request var.
function CTask:getVar(var_name)
	return 	self.entry[""..var_name..""];
end
--- Set a custom var for the task
-- @function [parent=#CTask] setVar
-- @pre A instance of the object must be generated previously.
-- @param #string var_name The name of var
-- @param #var var The var which should be saved.
-- @post The var is internal saved.
function CTask:setVar(var_name, var)
	
	if(var_name =="state_name" or var_name =="state_func" or var_name =="args" )then
		local err = "Error: Illegal access on predefined var with task:setVar() .";
		setTextColor(cli.yellow);
		error(err, 2);
		return;
	end
	self.entry[""..var_name..""] = var;
end
--- Run the function for this task
-- @function [parent=#CTask] run
-- @pre A instance of the object must be generated previously
-- @callof #hasArgsInfo
-- @return #CONSTANCE
function CTask:run()
	if(self:hasArgsInfo())then
		if(debug_task)then
			cprintf(cli.yellow, "[DEBUG] args found stack level %d with state: %s \n", #self.entry, task.entry.state_name);
		end
		return self.entry.state_func(self,unpack(self.entry.args));
	else
		if(debug_task)then
			cprintf(cli.yellow, "[DEBUG] no args found stack level %d with state: %s \n", #self.entry, task.entry.state_name);
		end
		return self.entry.state_func(self);
	end

end
--- Update the time for the last finished run of the task
-- @function [parent=#CTask] update
-- @pre A instance of the object must be generated previously
-- @post The time is updated.
function CTask:update()
	self.entry.last_call = getTime();
end
--- Return and generate the task on the fail case
-- @function [parent=#CTask] getFailTask
-- @pre A instance of the object must be generated previously
-- @pre Infos about the fail case should have been added previously 
-- @return #CTask The requested new task.
function CTask:getFailTask()
	return  CTask(self.entry.fail_name,self.entry.fail_func);
end
--- Return the fails args.
-- @function [parent=#CTask] getFailArgs
-- @pre A instance of the object must be generated previously
-- @pre Args about the fail case should have been added previously 
-- @return #table The requested args of the fails case.
function CTask:getFailArgs()
	return self.entry.fail_args;
end
--- Return the success args
-- @function [parent=#CTask] getSuccessArgs
-- @pre A instance of the object must be generated previously
-- @pre Args about the fail case should have been added previously 
-- @return #table The requested args of the fails case.
function CTask:getSuccessArgs()
	return self.entry.success_args;
end
--- Return and generate the task on the success case
-- @function [parent=#CTask] getSuccessTask
-- @pre A instance of the object must be generated previously
-- @pre Infos about the success case should have been added previously 
-- @return #CTask The requested new task
function CTask:getSuccessTask()
	return  CTask(self.entry.success_name,self.entry.success_func);
end
--- Return if the task has infos about what to do in the fail case.
-- @function [parent=#CTask] hasFailInfo
-- @pre A instance of the object must be generated previously
-- @return #boolean True if at least a function is there, false if not
function CTask:hasFailInfo()
	return self.entry.fail_func ~= nil;
end
--- Return if the task has infos about what to do in the success case.
-- @function [parent=#CTask] hasSuccessInfo
-- @pre A instance of the object must be generated previously
-- @return #boolean True if at least a function is there, false if not
function CTask:hasSuccessInfo()
	return self.entry.success_func ~= nil;
end
--- Return if the task has args.
-- @function [parent=#CTask] hasArgsInfo
-- @pre A instance of the object must be generated previously
-- @return #boolean True if the task has args, false if not.
function CTask:hasArgsInfo()
	return self.entry.args ~= nil;
end
--- Add the args to the task
-- @function [parent=#CTask] appendArgs
-- @pre A instance of the object must be generated previously
-- @param #vars ... A lot of args.
-- @post The args have been added to the task.
function CTask:appendArgs(...)
	self.entry.args = {...};
end
--- Add the args to the task for a logical switch
-- @function [parent=#CTask] appendArgsSwitch
-- @pre A instance of the object must be generated previously
-- @param #table args A lot of args for the default case
-- @param #table fail_args A lot of args for the fail case
-- @param #table success_args  A lot of args for the success case
-- @post The args have been added to the task.
function CTask:appendArgsSwitch(args, fail_args, success_args)

	self.entry.args = args;
	self.entry.fail_args = fail_args;
	self.entry.success_args = success_args
end