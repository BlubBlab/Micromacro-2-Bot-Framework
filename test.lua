--- Example for common use
-- @module main
include("lib2.lua");

--include("classes/node.class.lua")


function macro.init()
	-- Now those object are there by default make things easier
	--tasktimer = CTaskTimer.new();
	--taskstack = CTaskStack.new();

	tasktimer:registerTask("test1",secondsToTimer(1),function() print("Hello") return STATE_SUCCESS end );
	tasktimer:registerTask("test2",secondsToTimer(2.5),function() print("How") return STATE_SUCCESS end );
	tasktimer:registerTask("test3",secondsToTimer(4.5),function() print("Are") return STATE_SUCCESS end );
	tasktimer:registerTask("test4",secondsToTimer(4.5),function() print("You") return STATE_SUCCESS end);
	tasktimer:registerTask("test1",secondsToTimer(5),function() print("Spam") return STATE_SUCCESS end);
	-- The little simpler alternative is :
	-- timerFactory("test1",secondsToTimer(5),function() print("Spam") return STATE_SUCCESS end)


	taskstack:push_state("testx",function() print("Hello") return STATE_SUCCESS end);
--The more simpler alternative is :
-- taskFactory("STRING_PRINT",function(string) print(string) return STATE_SUCCESS end, string);
-- It easier because you need in the simple case no second call to push the args
-- and you can return direktly out of the function/task by: return taskFactory(..) because
-- it return STATE_PENNDING,

-- load XML data from file "test.xml" into local table xfile

-- if(filesystem.fileExists("p1.xml")) then
-- print("yo");
-- current_dir = filesystem.getCWD();
-- local num = string.find(current_dir,"scripts",1,true) or string.find(current_dir,"lib",1,true)
-- local sestring = string.sub(current_dir,1,num-2);
-- print(current_dir);
-- print(sestring.." w "..num);


-- end
--validXML("p1.xml");
--local node = xml.load("ks-last-ks.xml");
--__WPL = CWaypointList();
--__WPL:load("ks-last-ks.xml");
--table.show(xfile); print_r(xfile);
--table.save(xfile,"new.lua");

--database.skills[name]


end

function macro.main()

	taskstack:run();
	tasktimer:timed_run();

	--[[







		I also implemented yrestTask(msec) and restTaks(msec) if you need to wait for something







		they behave like the taskFactory or timerFactory means you can jump out directly of the 







		function/task by return yrestTask(..). 







		







		If everything break yrest and rest also avaible but the use isn't recommended.







	]]--

	--[[







		The (new) format for task functions is:







		function mytask(task, arg1, arg2,..argN)







			







			How can I save vars to the task longer than the run?!:







			task:setVar("myvar",var);







			







			You get them back this way:







			local myvar = task:getVar("mayVar");







			







			Depending what you want you need return one of those 3:







			local SomeoneOfThese = STATE_PENNDING  STATE_FAILED  STATE_SUCCESS







			return 	SomeoneOfThese, arg1 , arg2 ,...argN;







		end







	--]]
	return true;
end

function macro.event()

end
