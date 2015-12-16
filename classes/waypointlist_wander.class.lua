CWaypointListWander = class(CWaypointList);


function CWaypointListWander:load(filename)
-- Unused
end


function CWaypointListWander:advance()
-- Unused
end

function CWaypointListWander:getNextWaypoint()
	local X, Y

	if self.Radius ~= 0 then

		-- Check if we have mobs in out area
		local pawn = player:findEnemy(false, nil, evalTargetDefault)
		if pawn then
			cprintf(cli.lightblue, "Moving towards [%s], distance from start %d\n", pawn.Name, distance(pawn.X, pawn.Z, self.OrigX, self.OrigZ))
			X = pawn.X
			Y = pawn.Z

			-- No mobs, we run aimlessly around (or sit down?)
		else
			local halfrad = self.Radius/2;
			X = self.OrigX + math.random(-halfrad, halfrad);
			Z = self.OrigZ + math.random(-halfrad, halfrad);
		end

		-- no active moving if radius=0, so player can move the character manuel to every position
		-- that means also no moving back to fught start position for melees
	else
		X = player.X;
		Z = player.Z;
	end

	return CWaypoint(X, Z); -- TODO: Make sure this works
end


function CWaypointListWander:setRadius(rad)
	self.Radius = rad;
end

function CWaypointListWander:findWaypointTag(tag)
	return 0;
end
