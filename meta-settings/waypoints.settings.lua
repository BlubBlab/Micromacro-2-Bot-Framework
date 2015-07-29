waypoints = {};
-- only as an example remove later
waypoints.settings = {};
waypoints.settings["WPT_NORMAL"] = 3;
waypoints.settings["WPT_TRAVEL"] = 4;
waypoints.settings["WPT_RUN"] = 5;

WPT_NORMAL = waypoints.settings["WPT_NORMAL"] or 3;
WPT_TRAVEL = waypoints.settings["WPT_TRAVEL"] or 4;		-- don't target, don't fight back
WPT_RUN = waypoints.settings["WPT_RUN"] or 5;		-- don't target