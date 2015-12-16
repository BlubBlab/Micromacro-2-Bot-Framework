dyinclude("meta-settings/movement.settings.lua");

CAbstractMovement = class(CBaseObject,
	function (self, copyfrom)
		self.type = "default"
		self.Address =0;
		if( type(copyfrom) == "table" ) then
			self.type = copyfrom.type;
			self.Address = copyfrom.Address;
		end
	end

);

-- Forces the player to face a direction.
-- 'dir' should be in radians
function CPlayer:faceDirection(dir,diry)
	local Vec3 = 0
	
	if diry then
		Vec3 = math.sin(diry);
	else
		Vec3 = movement.funcs["get_player_direction_y"](player);
	end
	
	local hypotenuse = (1 - Vec3^2)^.5
	local Vec1 = math.cos(dir) * hypotenuse;
	local Vec2 = math.sin(dir) * hypotenuse;

	player.Direction = math.atan2(Vec2, Vec1);
	player.DirectionY = math.atan2(Vec3, (Vec1^2 + Vec2^2)^.5 );

	local tmpMountAddress = movement.funcs["getMountBase"](player);
	
	player:updateMounted()
	if player.Mounted and tmpMountAddress and tmpMountAddress ~= 0 then
	
		self.Address = tmpMountAddress;
		movement.funcs["change_player_direction"](self, Vec1, Vec2, Vec3)
	
		
	else
	
		self.Address = player:getAddress()
		movement.funcs["change_player_direction"](self, Vec1, Vec2, Vec3)
		
	end
end

--function CAbstractMovement:facedirection(task,x, z, _angle, dist)
--	self.curtime = getTime()
--	player:updateXYZ();
--	x = x or 0;
--	z = z or 0;
--	_angle = _angle or 0.1
--	-- Check our angle to the waypoint.
--	local angle = math.atan2(z - self.Z, x - self.X) + math.pi;
--	local angleDif = angleDifference(angle, self.Angle);
--
--	if( angleDif > _angle ) then
--		-- Attempt to face it
--		if angleDif > angleDifference(angle, self.Angle+ 0.01) then
--			-- Rotate left
--			logger:log('debug-moving','at Player:facedirection: move left angleDif: %.2f > _angle: %.2f', angleDif, _angle);
--			self:move(task,"left", dist)
--		else
--			-- Rotate right
--			logger:log('debug-moving','at Player:facedirection: move right angleDif %.2f > _angle: %.2f', angleDif, _angle);
--			self:move(task,"right",dist)
--		end
--	else
--		logger:log('debug-moving','at Player:facedirection: facing ok, angleDif: %.2f < _angle: %.2f', angleDif, _angle);
--		self:stopTurning()    -- no turning after looking in right direction
--		return true
--	end
--end


function CAbstractMovement:moveRotate(task, object)

	local movementLastUpdateR = task:getVar("movementLastUpdateR");

	if(movementLastUpdateR == nil)then
		movementLastUpdateR = getTime();

	end

	local curtime = getTime();
	local delta = 200;
	local finished = false;

	if deltaTime(curtime, movementLastUpdateR) > delta then
		-- QUICK_TURN only

		player:updateDirection();
		camera:update();

		local angle,yangle = player:getPointAngle(object)
		local angleDif,angleDifY = player:getPointAngleDifference(object)
		local pangle, pyangle = player:angleDifference(angle - 0.01, yangle - 0.01);

		if( settings.profile.options.QUICK_TURN == true ) then
			self:faceDirection(angle, yangle);
			camera:setRotation(angle, yangle);
		--angleDif = angleDifference(angle, self.Direction);
		else
			local direction = player:getDirection();
			self:faceDirection(direction, yangle); -- change only 'Y' angle with 'faceDirection'.
		end

		if not(angleDif > math.rad(65)  )then
			self:stopTurning()
			finished = true;
		end

		if( pangle < angleDif ) then

			movement.funcs["stop_right"](self);
			movement.funcs["move_left"](self);


		else
			movement.funcs["stop_left"](self);
			movement.funcs["move_right"](self);



		end
		if( yangle and (yangle ~= 0.0 ) )then

			if not(yangleDif > math.rad(65) ) then

				movement.funcs["stop_up"](self);
				movement.funcs["stop_down"](self);
				finished = true and finished;

			end

			if( ypangle < yangleDif ) then

				movement.funcs["stop_up"](self);
				movement.funcs["move_down"](self);

			else

				movement.funcs["stop_down"](self);
				movement.funcs["move_up"](self);

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
function CAbstractMovement:moveTo(task, object,ignoreCycleTargets, dontStopAtEnd, range)
	if(waypoint.Zone == nil) then  waypoint.Zone = 0; end;

	local movementLastUpdateF  = task:getVar("movementLastUpdateF");
	local notMovingTime = task:getVar("notMovingTime");

	local curtime = getTime();
	local delta = 100;

	if( ignoreCycleTargets == nil ) then
		ignoreCycleTargets = false;
	end;
	--XXX: Later this must be fixed maybe...
	--	if settings.profile.options.PARTYLEADER_WAIT and GetPartyMemberName(1) then
	--		if not checkparty(150) then
	--			releaseKeys()
	--			repeat yrest(500) player:updateBattling() until checkparty(150) or player.Battling
	--		end
	--	end

	local function passed_point(lastpos, point)
		local X,Y,Z = player:getPos();
		point.X = tonumber(point.X)
		point.Z = tonumber(point.Z)

		local posbuffer = 5

		local passed = true
		if lastpos.X < point.X and X < point.X - posbuffer then
			return false
		end
		if lastpos.X > point.X and X > point.X + posbuffer then
			return false
		end
		if lastpos.Z < point.Z and Z < point.Z - posbuffer then
			return false
		end
		if lastpos.Z > point.Z and Z > point.Z + posbuffer then
			return false
		end

		return true
	end

	if(movementLastUpdateF == nil)then
		movementLastUpdateF = getTime()
	end
	--we rotate the char
	local rotateState = self:moveRotate(task,object);
	-- make sure everything has stopped
	if(rotateState == STATE_SUCCESS)then
			-- only to make sure
				movement.funcs["stop_left"](self);
				movement.funcs["stop_right"](self);
				movement.funcs["stop_up"](self);
				movement.funcs["stop_down"](self);
	end

	if deltaTime(curtime, movementLastUpdateF) > delta then
		--TODO: check mount, fly ant so on..
		local X,Y,Z = player:getPos();
		local dist = player:getDistance(object);
		local angle,yangle = player:getPointAngle(object);

		-- Make sure we don't have a garbage (dead) target
		player:updateTargetPtr()
		if( player.TargetPtr ~= 0 ) then
			local target = CPawn.new(self.TargetPtr)
			if target:exists() then -- Target exists
				target:updateHP()
				if( target.HP <= 1 ) then
					player:clearTarget();
				end
			end
		end

		player:updateXYZ()
		if(__WPL:getMode()   == "wander"  and
			__WPL:getRadius() == 0     )   then
			-- I deceided to hell with th 3 sec wait
      --player:restrnd(100, 1, 4);  -- wait 3 sec
			-- we will not move back to WP if wander and radius = 0
			-- so one can move the character manual and use the bot only as fight support
			-- there we set the WP to the actual player position
			player:updateDirection()
			angle = player:getDirection()
			local x1,y1,z1 = player:getPos();
			waypoint.Z = z1;
			waypoint.X = x1;

		end;

		-- TODO: move to bot.lua or better it must be informed about it
		-- look for a target before start movig
		player:updateBattling()
		if((not player.Fighting) and (not ignoreCycleTargets)) then
			if player:target(player:findEnemy(false, nil, evalTargetDefault, player.IgnoreTarget)) then -- find a new target
				cprintf(cli.turquoise, language[86]); -- stopping waypoint::target acquired before moving
				local success = false;
				local  failreason = WF_TARGET;
				return STATE_FAIL, success, failreason;
			end;
		end;


		local X,Y,Z = player:getPos();
		local LastX =  task:getVar("LastX") or X;
		local LastZ =  task:getVar("LastZ") or Z;
		local LastY =  task:getVar("LastY") or Y;

		if 1 > player:distance(LastX,LastZ,LastY) then
			if not notMovingTime then
				--expose to task and also here in the next if
				notMovingTime = getTime();
				task:setVar("notMovingTime", getTime());
			end
			if deltaTime(getTime(), notMovingTime ) > 5000 then
				-- we stick for more then 5 sec, stop the bot
				--error('we dont move since more then 5 seconds. We stop the bot',0)
				--TODO: unstick state
				return STATE_FAILED,"not moving";

			elseif deltaTime(getTime(), notMovingTime ) > 200 then
				-- TODO: unstick state
				logger:log('info',"not moving");
				-- deal with not moving here.
				movement.funcs["jump"](self);
			end
		else
			local lastpos = {X=LastX, Z=LastZ, Y=LastY}
			-- Check if within range if range specified
			if range and range > dist then
				-- within range
				if (settings.profile.options.WP_NO_STOP ~= false) then
					if (dontStopAtEnd ~= true) or (settings.profile.options.QUICK_TURN == false) then
						movement.funcs["stop_forward"](self);
					end
				else
					movement.funcs["stop_forward"](self);
				end
			
				
				return STATE_SUCCESS;
			end
			--Check if past waypoint
			if passed_point(lastpos, waypoint) then
				-- waypoint reached
				if (settings.profile.options.WP_NO_STOP ~= false) then
					if (dontStopAtEnd ~= true) or (settings.profile.options.QUICK_TURN == false) then
							movement.funcs["stop_forward"](self);
					end
				else
						movement.funcs["stop_forward"](self);
				end

				return STATE_SUCCESS;
			end
			-- Check if close to waypoint.
			if dist < successdist then
				if (settings.profile.options.WP_NO_STOP ~= false) then
					if (dontStopAtEnd ~= true) or (settings.profile.options.QUICK_TURN == false) then
							movement.funcs["stop_forward"](self);
					end
				else
						movement.funcs["stop_forward"](self);
				end

				return STATE_SUCCESS;
			end
		end
		task:setVar("LastX", X);
		task:setVar("LastZ", Z);
		task:setVar("LastY", Y);
		task:setVar("movementLastUpdateF",getTime());
		-- Ensure we're moving foward
		
		movement.funcs["move_forward"](self);
		return STATE_PENNDING;

	end
end





