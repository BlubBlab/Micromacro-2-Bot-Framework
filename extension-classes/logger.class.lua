dyinclude("classes/abstract.logger.class.lua",true);

CLogger = class(CAbstractLogger,
	function (self, copyfrom)
		self.file = nil;
		self.filename = nil;
		self.dateformat = "%Y/%m/%d %H:%M:%S";
		self.lastMsgTime = 0;		-- last time we log a message
		self.lastMsg = "<UNKNOWN>";			-- last mesage we log
		self.repeatTimer = 20;		-- at least x second until repat same message

		if( fn ) then
			self:openFile(fn);
		end
	end

);
