CAbstractMovement = class(CBaseObject,
	function (self, copyfrom)
		self.type = "defualt"
		if( type(copyfrom) == "table" ) then
			self.type = copyfrom.type;
		end
	end
	
);

function CAbstractMovement:moveTo(task, waypoint, ignoreCycleTargets, dontStopAtEnd)

	
	local movementLastUpdateF  = task:getVar("movementLastUpdatFe");
	local notMovingTime = task:getVar("notMovingTime");

	local curtime = getTime();
	local delta = 100;
	
	if(movementLastUpdateF == nil)then
		movementLastUpdateF = getTime()
	end
	
	if deltaTime(curtime, movementLastUpdateF) > delta then
	
	
		task:setVar("movementLastUpdateF",getTime());
	end

end
function CAbstractMovement:stopMoving()

	-- Ensure we're not moving
	memoryWriteInt(proc, addresses.moveForward, 0);
	memoryWriteInt(proc, addresses.moveBackward, 0);
end

function CAbstractMovement:stopTurning()

	-- Ensure we're not turning
	memoryWriteInt(proc, addresses.turnLeft, 0);
	memoryWriteInt(proc, addresses.turnRight, 0);

end
function CAbstractMovement:moveTo_step()
	
	_dist = _dist or 5
	coordsupdate()
	x = x or 0;
	z = z or 0;
	local angle
	local dist = distance(self.X, self.Z, x, z)
	
	if 15 > dist then 
		angle = 0.5 
	else 
		angle = 0.2 
	end

	logger:log('debug-moving',"at Player:moveTo_step: Distance %d from WP (%d,%d)", dist, x, z);
	if self:facedirection(x, z, angle, dist) then
		if dist > 10 and memoryReadInt(proc, addresses.moveForward) == 1 then 
			local tar = targetnearestmob()
			if tar then 
				self:stopMoving()
				stateman:pushState(FirstattackState()) 
				return
			end
		end
		if dist > _dist then
			self:move("forward")
		else
			logger:log('debug',"at Player:moveTo_step: stopMoving() we are close at (%d,%d) dist %d < %d", x, z, dist, _dist);
			self:stopMoving()		-- no moving after being there 
			return true
		end
	else
		logger:log('debug-moving','at Player:moveTo_step: not moving because self:facedirection() = false');
	end
end
function CAbstractMovement:facedirection(task,x, z, _angle, dist)
	self.curtime = getTime()
	player:updateXYZ();
	x = x or 0;
	z = z or 0;
	_angle = _angle or 0.1
	-- Check our angle to the waypoint.
	local angle = math.atan2(z - self.Z, x - self.X) + math.pi;
	local angleDif = angleDifference(angle, self.Angle);

	if( angleDif > _angle ) then
		-- Attempt to face it
		if angleDif > angleDifference(angle, self.Angle+ 0.01) then
			-- Rotate left
			logger:log('debug-moving','at Player:facedirection: move left angleDif: %.2f > _angle: %.2f', angleDif, _angle);
			self:move(task,"left", dist)
		else
			-- Rotate right
			logger:log('debug-moving','at Player:facedirection: move right angleDif %.2f > _angle: %.2f', angleDif, _angle);
			self:move(task,"right",dist)
		end
	else
		logger:log('debug-moving','at Player:facedirection: facing ok, angleDif: %.2f < _angle: %.2f', angleDif, _angle);
		self:stopTurning()		-- no turning after looking in right direction 
		return true
	end
end


function CAbstractMovement:moveRotate(task, object)
	
	local movementLastUpdateR = task:getVar("movementLastUpdateR");
	
	if(movementLastUpdateR == nil)then
		movementLastUpdateR = getTime();
		
	end
	
	local curtime = getTime();
	local delta = 200;
	local finished = false;
	
	if deltaTime(curtime, movementLastUpdateR) > delta then
		player:updateDirection();
		
		local angle,yangle = player:getPointAngle(object)
		local angleDif,angleDifY = player:getPointAngleDifference(object)
		local pangle, pyangle = player:angleDifference(angle - 0.01, yangle - 0.01);
		
		if not(angleDif > math.rad(65)  then
			self:stopTurning()
			finished = true;
		end
	
		if( pangle < angleDif ) then
			
			keyboardRelease( settings.hotkeys.ROTATE_RIGHT.key );
			keyboardHold( settings.hotkeys.ROTATE_LEFT.key );
			-- move camara

		else
		
			keyboardRelease( settings.hotkeys.ROTATE_LEFT.key );
			keyboardHold( settings.hotkeys.ROTATE_RIGHT.key );
			-- move camara
			
		end
		if( yangle and (yangle ~= 0.0 ) )then
		
			if not(yangleDif > math.rad(65)  then
				
				keyboardRelease( settings.hotkeys.ROTATE_UP.key );
				keyboardRelease( settings.hotkeys.ROTATE_DOWN.key );
				finished = true and finished;
			end
	
			if( ypangle < yangleDif ) then
			
				keyboardRelease( settings.hotkeys.ROTATE_UP.key );
				keyboardHold( settings.hotkeys.ROTATE_DOWN.key );
				-- move camara
				
			else
		
				keyboardRelease( settings.hotkeys.ROTATE_DOWN.key );
				keyboardHold( settings.hotkeys.ROTATE_UP.key );
				-- move camara
				
			end
		
		end
		
		task:setVar("movementLastUpdateR", getTime());
		
		if finished then
			return STATE_SUCCESS;
		else
			return STATE_PENDING
		end
			
	end
end
function CAbstractMovement:moveFoward(task, object)
	
	local movementLastUpdateF  = task:getVar("movementLastUpdatFe");
	local notMovingTime = task:getVar("notMovingTime");

	local curtime = getTime();
	local delta = 100;
	
	if(movementLastUpdateF == nil)then
		movementLastUpdateF = getTime()
	end
	
	if deltaTime(curtime, movementLastUpdateF) > delta then
		player:updateXYZ()
		local X,Y,Z = player:getPos();
		local LastX =  task:getVar("LastX") or X;
		local LastZ =  task:getVar("LastZ") or Z;
		local LastY =  task:getVar("LastY") or Y;
		
		if 1 > player:distance(LastX,LastZ,LastY) then
			if not self.notMovingTime then
				--expose to task and also here in the next if
				notMovingTime = getTime();
				task:setVar("notMovingTime", getTime());
			end
			if deltaTime(getTime(), notMovingTime ) > 5000 then 	-- we stick for more then 5 sec, stop the bot
				--error('we dont move since more then 5 seconds. We stop the bot',0)
				--TODO: unstick
				return STATE_FAILED,"not moving";
				
			elseif deltaTime(getTime(), notMovingTime ) > 200 then -- TODO: unstick state
				logger:log('info',"not moving");
				-- deal with not moving here.
				keyboardPress(key.VK_SPACE)
			end
		else
			--self.notMovingTime = nil	-- we moved successfully
				return STATE_SUCCESS;
		end
		task:setVar("LastX", X);
		task:setVar("LastZ", Z);
		task:setVar("LastY", Y);
		task:setVar("movementLastUpdateF",getTime());
		-- Ensure we're moving foward
		memoryWriteInt(proc, addresses.moveForward, 1);
		return STATE_PENNDING;
		
	end
end