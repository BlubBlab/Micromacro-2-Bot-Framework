pawns = {};
pawns.settings = {};


-- meta index races I properly don't need to do this but we will see
pawns.settings["races_list"] = {"RACE_HUMAN","RACE_ELF","RACE_DWARF"};


--The race ID's from the objects out of the object list
pawns.settings["races_types"] = {RACE_HUMAN = 0, RACE_ELF = 1, RACE_DWARF = 2};
pawns.settings["races_default"] = pawns.settings["races_types"]["RACE_HUMAN"];


-- if in another MMO you have only 1 class set the to 1
pawns.settings["max_number_classes_activ"] = 2; 
pawns.settings["max_number_classes_total"] = 3;


-- meta index classes
pawns.settings["class_list"] = {"CLASS_NONE","CLASS_WARRIOR","CLASS_SCOUT",
								"CLASS_ROGUE","CLASS_MAGE","CLASS_PRIEST",
								"CLASS_KNIGHT","CLASS_WARDEN","CLASS_DRUID",
								"CLASS_WARLOCK","CLASS_CHAMPION"};

								--The class ID's from the objects the object list
pawns.settings["class_types"] = {CLASS_NONE = -1,CLASS_WARRIOR = 1,CLASS_SCOUT = 2,
								CLASS_ROGUE = 3,CLASS_MAGE = 4,CLASS_PRIEST = 5,
								CLASS_KNIGHT = 6,CLASS_WARDEN = 7,CLASS_DRUID = 8,
								CLASS_WARLOCK = 9, CLASS_CHAMPION = 10}
								

-- meta index nodes
pawns.settings["nodes_list"] = {"NTYPE_WOOD","NTYPE_ORE","NTYPE_HERB"};
pawns.settings["nodes_type"] = {NTYPE_WOOD = 1,NTYPE_ORE = 2,NTYPE_HERB = 3};


-- can be others in games like DP we have 3 the total number will be the length of the table "energy_list"
pawns.settings["max_number_energys_activ"] = 2;
pawns.settings["energy_list"] = {"mana","rage","enery","focus"}



pawns.settings["armor_map"] = { 
	[pawns.settings["class_types"].CLASS_NONE] = "none",
	[pawns.settings["class_types"].CLASS_WARRIOR] = "chain",
	[pawns.settings["class_types"].CLASS_SCOUT] = "leather",
	[pawns.settings["class_types"].CLASS_ROGUE] = "leather",
	[pawns.settings["class_types"].CLASS_MAGE] = "cloth",
	[pawns.settings["class_types"].CLASS_PRIEST] = "cloth",
	[pawns.settings["class_types"].CLASS_KNIGHT] = "chain",
	[pawns.settings["class_types"].CLASS_WARDEN] = "chain",
	[pawns.settings["class_types"].CLASS_DRUID] = "cloth",
	[pawns.settings["class_types"].CLASS_WARLOCK] = "cloth",
	[pawns.settings["class_types"].CLASS_CHAMPION] = "chain",
	}
	
pawns.settings["classEnergyMap"] = {
	[pawns.settings["class_types"].CLASS_NONE] = "none",
	[pawns.settings["class_types"].CLASS_WARRIOR] = "rage",
	[pawns.settings["class_types"].CLASS_SCOUT] = "focus",
	[pawns.settings["class_types"].CLASS_ROGUE] = "energy",
	[pawns.settings["class_types"].CLASS_MAGE] = "mana",
	[pawns.settings["class_types"].CLASS_PRIEST] = "mana",
	[pawns.settings["class_types"].CLASS_KNIGHT] = "mana",
	[pawns.settings["class_types"].CLASS_WARDEN] = "mana",
	[pawns.settings["class_types"].CLASS_DRUID] = "mana",
	[pawns.settings["class_types"].CLASS_WARLOCK] = "focus",
	[pawns.settings["class_types"].CLASS_CHAMPION] = "rage",
	}
	

PT_NONE = 0;
PT_PLAYER = 1;
PT_MONSTER = 2;
-- we can use SIGEL in other games for special event drops
PT_SIGIL = 3;
PT_NPC = 4;
PT_NODE = 4;

ATTACKABLE_MASK_PLAYER = 0x10000;
ATTACKABLE_MASK_MONSTER = 0x20000;
ATTACKABLE_MASK_CLICKABLE = 0x1000;

AGGRESSIVE_MASK_MONSTER = 0x100000;

pawns.funcs["init_all_classes"] = function()

	local activ_classes = pawns.settings["max_number_classes_activ"];
	local default_class = pawns.settings["class_types"]["CLASS_NONE"];
	
	local class_table = {};
	
	for i = 1, activ_classes  do
		class_table[i] =  default_class;
	end
	
	return class_table;
end

pawns.funcs["init_all_levels"] = function()

	local number_of_levels = pawns.settings["max_number_classes_activ"];
	local level_table = {};
	
	for i = 1, number_of_levels  do
		level_table =  1;
	end

end

pawns.funcs["init_all_activ_powers"] = function()
	
	local number_of_levels = pawns.settings["max_number_classes_activ"];
	local power_table = {};
	
	for i = 1, number_of_levels  do
		power_table =  1000;
	end


end

pawns.funcs["init_all_powers"] = function()
	local enys = pawns.settings["energy_list"];
	local powers = {};
	local size = #enys;
	
	for i = 1, size do
		powers[enys[i]] = 0;
		powers["Max"..enys[i]] = 0;
	end
	
end
pawns.funcs["eval_updates"]= function(self)
	--if( self.Alive ==nil or self.HP == nil or self.MaxHP == nil or self.MP == nil or self.MaxMP == nil or
	--	self.MP2 == nil or self.MaxMP2 == nil or self.Name == nil or
--		self.Level == nil or self.Level2 == nil or self.TargetPtr == nil or
	--	self.X == nil or self.Y == nil or self.Z == nil or self.Attackable == nil ) then
	return false;
end