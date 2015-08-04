
local lanes;
if(macro.is32bit())then
	lanes = include("32bit/load.lua")
else
	lanes = include("64bit/load.lua")
end
[[Question: in c and c# threads are functions in Java they are objects which way?]]
local ThreadList ={}
local LindaList = {}
local LookList = {}
local AtomicCounterList = {}

function createRealThread( name, func, args, prior)
	if(prior == nil)then
		local thread = lanes.gen("*",{globals = _G},func)(args)
	else
		local thread = lanes.gen("*",{globals = _G, priority = prior},func)(args)
	end
	ThreadList[name] = thread;
end 
function killRealThread( name, timeout, force)
	local thread = ThreadList[name]
	if(thread ~= nil)then
		return thread:cancel(timeout, force)
	else
		return false,"thread does not exist"
	end
end
function getRealThreadStatus(name)
	local thread = ThreadList[name]
	if( thread ~= nil )then
		return thread.status
	else
		return false,"thread does not exist"
	end
end
--Lindas are thread safe queues
[[ ? create a wrapper class for lindas?]]
function createLinda(name)
	linda = lanes.linda()
	if(name ~= nil)then
		LindaList[name] = linda;
	end
	return linda;
end
function getLinda(name)
	return LindaList[name];
end
--Must be called from inside the Thread
--For yield calls the Windows API call Sleep(0) =? sleep 0
--but Better would for a yield implementation Windows SwitchToThread() API call
function sleepThread(msec)
	system.rest(msec)
end
[[TODO implement SwitchToThread() in MM2]]
function yieldThread()
	-- this won't work because execute is a child process
	--os.execute("sleep 0")
	if system.yield then
		system.yield()
	else
		system.rest(0)
	end
	
end
function createLock(name)
	local linda = lanes.linda()
	local lock = lanes.genlock(linda,name,1)
	if(name ~= nil)then
		LookList[name]= lock;
	end
	return lock;
end
function getLock(name)
	return LookList[name];
end
[
function lock(lockOject)
	lockObject(1)
end
function unlock(lockObject)
	lockObject(-1)
end
--Okay this function doesn't make it simpler :(
function createThreadTimer(linda, string_time_def, startin, interval)
	lanes.timer( linda, string_time_def,  startin, interval)
end
function createAtomicCounter(name)
	local linda = lanes.linda()
	local atomic_inc = lanes.genatomic( linda, name)
	if(name ~= nil)then
		AtomicCounterList[name] = atomic_inc;
	end
	return atomic_inc;
end
function getAtomicCounter(name)
	atomic_inc = AtomicCounterList[name];
	if(atomic_inc ~= nil)then
		return atomic_inc;
	else
		return false,"atomic counter doesn't exist";
	end
end
