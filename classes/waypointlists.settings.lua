waypointlists = {};
waypointlists.settings = {};
-- turn the test mode on for waypointlist
waypointlists.settings["test"] = true;
--rewrite XML waypoint files yes or no?
waypointlists.settings["rewrite_waypoint"] = true;
--remove later
waypointlists.settings["WPT_FORWARD"] = 1;
waypointlists.settings["WPT_BACKWARD"] = 2;
--real data
WPT_FORWARD = waypointlists.settings["WPT_FORWARD"] or 1;
WPT_BACKWARD = waypointlists.settings["WPT_BACKWARD"] or 2;