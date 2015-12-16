movement = {}
movement.settings = {}
movement.funcs = {}

movement.funcs["move_left"] = function(self)
	InputOutput:PressHold(self, settings.hotkeys.ROTATE_LEFT.key );
end

movement.funcs["move_right"] = function(self)
	InputOutput:PressHold(self, settings.hotkeys.ROTATE_RIGHT.key );
end

movement.funcs["move_up"] = function(self)
	InputOutput:PressHold(self, settings.hotkeys.ROTATE_UP.key );
end

movement.funcs["move_down"] = function(self)
	InputOutput:PressHold(self, settings.hotkeys.ROTATE_DOWN.key );
end

movement.funcs["stop_left"] = function(self)
	InputOutput:PressRelease(self, settings.hotkeys.ROTATE_LEFT.key );
end

movement.funcs["stop_right"] = function(self)
	InputOutput:PressRelease(self, settings.hotkeys.ROTATE_RIGHT.key );
end

movement.funcs["stop_up"] = function(self)
	InputOutput:PressRelease(self, settings.hotkeys.ROTATE_UP.key );
end

movement.funcs["stop_down"] = function(self)
	InputOutput:PressRelease(self, settings.hotkeys.ROTATE_DOWN.key );
end

movement.funcs["jump"] = function(self)
	InputOutput:PressRelease(self, settings.hotkeys.JUMP.key );
end

movement.funcs["stop_forward"] = function(self)
	InputOutput:PressRelease(self, settings.hotkeys.MOVE_FORWARD.key );
end

movement.funcs["move_forward"] = function(self)
	InputOutput:PressHold(self, settings.hotkeys.MOVE_FORWARD.key );
end

movement.funcs["getMountBase"] = function(self)
	return 	InputOutput:MountBase(self);
end

movement.funcs["change_player_direction"] = function(self, Vec1, Vec2, Vec3)
		InputOutput:WritePawnDirection("x",self,Vec1)
		InputOutput:WritePawnDirection("z",self,Vec2)
		InputOutput:WritePawnDirection("y",self,Vec1)
end
movement.funcs["get_player_direction_y"] = function(self)
	return 	InputOutput:PawnDirection("y", self);
end