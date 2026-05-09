#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

// =========================================================
// FileName: vote.gsc
// Date: 11.05.2019 
// 
// Author Of Code: Santahunter
// 
// =========================================================


/*

ALPHA
so_killspree_trainer "The Pit"
so_rooftop_contingency "Sniper Fi"
so_killspree_favela "O Cristo Redentor"
so_forest_contingency "Evasion"
so_crossing_so_bridge "Suspension"

BRAVO
so_ac139_co_hunted "Overwatch" (Two-Players Min)
so_killspree_invasion "Body Count"
so_defuse_favela_escape "Bomb Squad"
so_snowrace1_cliffhanger "Race"
so_chopper_invasion "Big Brother" (Two-Players Min)   /////////////////// BURGERTOWN

CHARLIE
so_hidden_so_ghillies "Hidden"
so_showers_gulag "Breach & Clear"
so_snowrace2_cliffhanger "Time Trial"
so_defuse_invasion "Homeland Security"
so_intel_boneyard "Snatch & Grab"

DELTA
so_download_arcadia "Wardriving"
so_demo_so_bridge "Wreckage"
so_sabotage_cliffhanger "Acceptable Losses"
so_escape_airport "Terminal"
so_takeover_estate "Estate Takedown"

ECHO
so_assault_oilrig "Wetwork"
so_juggernauts_favela "High Explosive"
so_takeover_oilrig "Armor Piercing"

*/

loadVote()
{
	precacheShader("line_horizontal");
	precacheShader("hudscoreboardscroll_uparrow");
	precacheShader("hudscoreboardscroll_downarrow");
	level.maxOptions = 8;
	maps();
	thread startVote();
}
maps()
{
	level.maps = [];
	// MW2 Base Maps
	level.maps[level.maps.size] = "mp_rust";
	level.maps[level.maps.size] = "mp_afghan";
	level.maps[level.maps.size] = "mp_terminal";
	level.maps[level.maps.size] = "mp_highrise";
	//level.maps[level.maps.size] = "mp_derail"; //fuck derail
	level.maps[level.maps.size] = "mp_rundown";
	level.maps[level.maps.size] = "mp_brecourt"; //Wasteland
	level.maps[level.maps.size] = "mp_boneyard"; //Scrapyard
	level.maps[level.maps.size] = "mp_quarry";
	level.maps[level.maps.size] = "mp_nightshift"; //Skidrow
	level.maps[level.maps.size] = "mp_estate";
	level.maps[level.maps.size] = "mp_invasion";
	level.maps[level.maps.size] = "mp_checkpoint"; //Karachi
	level.maps[level.maps.size] = "mp_subbase";
	level.maps[level.maps.size] = "mp_favela";
	level.maps[level.maps.size] = "mp_underpass";
	//level.maps[level.maps.size] = "iw4_credits"; // no
	
	// MW2 DLC Maps
	level.maps[level.maps.size] = "mp_complex"; //Bailout Stimulus DLC
	level.maps[level.maps.size] = "mp_crash"; //Crash
	level.maps[level.maps.size] = "mp_overgrown"; //Overgrown
	level.maps[level.maps.size] = "mp_compact"; //Salvage Stimulus DLC
	level.maps[level.maps.size] = "mp_storm"; //Storm
	
	level.maps[level.maps.size] = "mp_abandon"; //Carnival
	//level.maps[level.maps.size] = "mp_fuel2"; // hell no
	level.maps[level.maps.size] = "mp_strike"; //Strike
	level.maps[level.maps.size] = "mp_trailerpark"; //Trailerpark
	level.maps[level.maps.size] = "mp_vacant"; //Vacant
	
	level.maps[level.maps.size] = "mp_nuked"; //Nuketown
	
	level.maps[level.maps.size] = "mp_cross_fire";
	level.maps[level.maps.size] = "mp_bloc";
	level.maps[level.maps.size] = "mp_cargoship";
	
	level.maps[level.maps.size] = "mp_killhouse";
	level.maps[level.maps.size] = "mp_bog_sh";
	
	level.maps[level.maps.size] = "mp_cargoship_sh";
	
	level.maps[level.maps.size] = "mp_shipment_long";
	level.maps[level.maps.size] = "mp_rust_long";
	level.maps[level.maps.size] = "mp_firingrange";
	
	level.maps[level.maps.size] = "mp_storm_spring";
	level.maps[level.maps.size] = "mp_fav_tropical";
	level.maps[level.maps.size] = "mp_estate_tropical";
	level.maps[level.maps.size] = "mp_crash_tropical";
	level.maps[level.maps.size] = "mp_bloc_sh";
	
	////////////// NOT VANILLA /////////////////////////
	
	//level.maps[level.maps.size] = "af_caves";
	//level.maps[level.maps.size] = "af_chase";
	//level.maps[level.maps.size] = "airport";
	//level.maps[level.maps.size] = "arcadia";
	//level.maps[level.maps.size] = "boneyard";
	//level.maps[level.maps.size] = "ending";
	//level.maps[level.maps.size] = "cliffhanger";
	//level.maps[level.maps.size] = "co_hunted";
	//level.maps[level.maps.size] = "so_forest_contingency";
	//level.maps[level.maps.size] = "dcburning";
	//level.maps[level.maps.size] = "dcemp";
	//level.maps[level.maps.size] = "estate";
	//level.maps[level.maps.size] = "favela";
	//level.maps[level.maps.size] = "so_showers_gulag";
	level.maps[level.maps.size] = "oilrig";
	//level.maps[level.maps.size] = "roadkill";
	//level.maps[level.maps.size] = "so_hidden_so_ghillies";
	//level.maps[level.maps.size] = "trainer";
	
	/////////////// TAUROS //////////////////////////////
	
	//level.maps[level.maps.size] = "so_chopper_invasion"; // Burgertown // so_killspree_invasion
	//level.maps[level.maps.size] = "so_killspree_trainer"; // Startmission // The Pit
	
	/////////////// DRAGONITE //////////////////////////////
	//level.maps[level.maps.size] = "so_defuse_favela_escape";
	//level.maps[level.maps.size] = "dc_whitehouse";
	//level.maps[level.maps.size] = "so_crossing_so_bridge";
	
	level.mapStruct = [];
	
	foreach(map in level.maps)
	{
		level.mapStruct[level.mapStruct.size] = spawnStruct();
		level.mapStruct[level.mapStruct.size-1].mapname = map;
		level.mapStruct[level.mapStruct.size-1].displayName = getDisplayName(map);
	}
	
}
getDisplayName(map)
{
	if(map == "mp_afghan")
		return "Afghan";
	if(map == "mp_rust")
		return "Rust";
	if(map == "mp_terminal")
		return "Terminal";
	if(map == "mp_highrise")
		return "Highrise";
	if(map == "mp_derail")
		return "Derail";
	if(map == "mp_rundown")
		return "Rundown";
	if(map == "mp_brecourt")
		return "Wasteland";
	if(map == "mp_boneyard")
		return "Scrapyard";
	if(map == "mp_quarry")
		return "Quarry";
	if(map == "mp_estate")
		return "Estate";
	if(map == "mp_nightshift")
		return "Skidrow";
	if(map == "mp_invasion")
		return "Invasion";
	if(map == "mp_checkpoint")
		return "Karachi";
	if(map == "mp_subbase")
		return "Subbase";
	if(map == "mp_favela")
		return "Favela";
	if(map == "mp_underpass")
		return "Underpass";
	if(map == "iw4_credits")
		return "Testmap";
	if(map == "mp_abandon")
		return "Carnival";
	if(map == "mp_fuel2")
		return "Fuel";
	if(map == "mp_strike")
		return "Strike";
	if(map == "mp_trailerpark")
		return "Trailerpark";	
	if(map == "mp_vacant")
		return "Vacant";
	if(map == "mp_complex")
		return "Bailout";
	if(map == "mp_crash")
		return "Crash";
	if(map == "mp_overgrown")
		return "Overgrown";
	if(map == "mp_compact")
		return "Salvage";
	if(map == "mp_storm")
		return "Storm";
	if(map == "mp_nuked")
		return "Nuketown";
	if(map == "mp_cross_fire")
		return "Crossfire";
	if(map == "mp_cargoship")
		return "Cargoship";
	if(map == "mp_bloc")
		return "Bloc";
	if(map == "mp_killhouse")
		return "Killhouse";
	if(map == "mp_bog_sh")
		return "Bog";
	if(map == "mp_cargoship_sh")
		return "Freighter";
	if(map == "mp_shipment_long")
		return "Shipment Long";
	if(map == "mp_rust_long")
		return "Rust Long";
	if(map == "mp_firingrange")
		return "Firing Range";
	if(map == "mp_storm_spring")
		return "Chemical Storm";
	if(map == "mp_fav_tropical")
		return "Tropical Favela";
	if(map == "mp_estate_tropical")
		return "Tropical Estate";
	if(map == "mp_crash_tropical")
		return "Tropical Crash";		
	if(map == "mp_bloc_sh")
		return "Ruin City";
	if(map == "af_caves")
		return "Afghanistan Caves";	
	if(map == "af_chase")
		return "Afghanistan Hunt";	
	if(map == "airport")
		return "Airport";	
	if(map == "arcadia")
		return "Arcadia";	
	if(map == "boneyard")
		return "Airplane Scrapyard";	
	if(map == "ending")
		return "Museum";	
	if(map == "cliffhanger")
		return "Cliffhanger";	
	if(map == "co_hunted")
		return "Hunted";	
	if(map == "contingency" || map == "so_forest_contingency")
		return "Contingency";	
	if(map == "dcburning")
		return "DC Burning";	
	if(map == "dcemp")
		return "DC Dark";	
	if(map == "estate")
		return "Makarovs House";	
	if(map == "favela")
		return "Rojas Favelas";		
	if(map == "favela_escape" || map == "so_defuse_favela_escape")
	{	
		return "Favels Escape";	
	}		
	if(map == "gulag" || map == "so_showers_gulag")
		return "Gulag";	
	if(map == "invasion")
		return "School";	
	if(map == "oilrig")
		return "Oilrig";	
	if(map == "roadkill")
		return "School";	
	if(map == "so_hidden_so_ghillies")
		return "Chernobyl";		
	if(map == "trainer" || map == "so_killspree_trainer")
		return "The Pit";
	if(map == "so_chopper_invasion" || map == "so_killspree_invasion")
		return "Burgertown";
	if(map == "dc_whitehouse")
	{		
		return "DC Whitehouse";
	}	
	if(map == "so_crossing_so_bridge")
		return "Bridge";
	return map;
}

createRectangle(shader,align, relative, x, y, width, height)
{
	hud = newHudElem();
	hud.sTexType = "bar";
	hud.width = width;
	hud.height = height;
	hud.align = align;
	hud.relative = relative;
	hud.alpha = 1;
	hud.xOffset = 0;
	hud.yOffset = 0;
	hud.children = [];
	hud.sort = 1;
	hud setParent(level.uiParent);
	hud setShader(shader,width,height);
	hud.hidden = false;
	hud.HideWhenInMenu = true;
	hud setPoint(align,relative,x,y);
	return hud;
}
createPlayerRectangle(shader,align, relative, x, y, width, height)
{
	hud = newClientHudElem(self);
	hud.sTexType = "bar";
	hud.width = width;
	hud.height = height;
	hud.align = align;
	hud.relative = relative;
	hud.alpha = 1;
	hud.xOffset = 0;
	hud.yOffset = 0;
	hud.children = [];
	hud.sort = 1;
	hud setParent(level.uiParent);
	hud setShader(shader,width,height);
	hud.hidden = false;
	hud.HideWhenInMenu = true;
	hud setPoint(align,relative,x,y);
	return hud;
}
///////////////////////////////////////////////////////////////////////
doCountdown(timer,timer2)
{
	secs = 20;
	timer.label = &"Time left: ";
	timer2.alpha = 0; // subsecond display removed
	for(secs = 20; secs > 0; secs--)
	{
		timer setValue(secs);
		wait 1;
	}
	level notify("finishVote");
}
startVote()
{
	//level waittill ( "game_ended" );
	//level waittill ( "spawning_intermission" );
	level waittill("spawnVote");
	//setDvar("g_hardcore", 1);
	setSlowMotion( 0.25, 1, 2.0 );
	thread killGungameHUD();
	background = createRectangle("black","CENTER", "CENTER", 0,0,250,350);
	background.alpha = .7;
	line = createRectangle("line_horizontal","CENTER", "CENTER", 0,-145,180,3);
	line.sort = 2;
	//line.color = (1,0,0);
	line2 = createRectangle("line_horizontal","CENTER", "CENTER", 0,70,180,3);
	line2.sort = 2;
	//line2.color = (1,0,0);
	line3 = createRectangle("line_horizontal","CENTER", "CENTER", 0,110,180,3);
	line3.sort = 2;
	//line3.color = (1,0,0);
	
	//background2 = createRectangle("black","CENTER", "CENTER", -200,0,75,180);
	//background2.alpha = .7;
	arrowUp = createRectangle("hudscoreboardscroll_uparrow","CENTER", "CENTER", -100,-125,25,25);
	arrowDown = createRectangle("hudscoreboardscroll_downarrow","CENTER", "CENTER", 100,-125,25,25);
	arrowUp.sort = 2;
	arrowDown.sort = 2;
	controls = level createServerFontString("default", 1.5);
	controls setPoint("CENTER", "CENTER", -100,-100);
	controls.hideWhenInMenu = true;
	controls setText("[{+forward}]");
	controls2 = level createServerFontString("default", 1.5);
	controls2 setPoint("CENTER", "CENTER", 100,-100);
	controls2.hideWhenInMenu = true;
	controls2 setText("[{+back}]");
	controls3 = level createServerFontString("default", 1.3);
	controls3 setPoint("CENTER", "CENTER", 0,-125);
	controls3.hideWhenInMenu = true;
	controls3 setText("[{+gostand}] to select");
	
	
	//background3 = createRectangle("black","CENTER", "CENTER", 225,0,180,75);
	//background3.alpha = .7;
	timer = level createServerFontString("default", 1.8);
	timer setPoint("CENTER", "CENTER", 0,90);
	timer.hideWhenInMenu = true;
	
	timer2 = level createServerFontString("default", 1.8);
	timer2 setPoint("CENTER", "CENTER", 30,90);
	timer2.hideWhenInMenu = true;
	timer2.label = &": ";
	timer2.sort = 3;
	
	credits = level createServerFontString("default", 1.6);
	credits setPoint("CENTER", "CENTER", 0,130);
	credits.hideWhenInMenu = true;
	credits setText("Made by ^:Santahunter"); // if you change this credits Im gonna come to your house and smack ur sister... for real, dont change it, it took many hours and days to come to this point
	
	thread doCountdown(timer,timer2);
	
	header = createServerFontString("default", 2);
	header setPoint("CENTER", "CENTER", 0,-155);
	header.hideWhenInMenu = false;
	header setText("Votemap");
	
	level.options = [];
	level.votes = [];
	level.invalidMaps = [];
	text = "";
	level.elems = createServerFontString("default", 1.5);
	level.elems setPoint("CENTER", "CENTER", 20,-75);
	level.elems.hideWhenInMenu = true;
	//level.elems = [];
	// FIX: Added maxRetries guard. If the map pool is smaller than maxOptions, the
	// i-- retry would loop forever (no wait = instant VM instruction-count crash).
	maxRetries = level.maps.size * 3;
	retries = 0;
	for(i = 0;i < level.maxOptions;i++)
	{
		retries++;
		if(retries > maxRetries)
			break; // pool exhausted: accept fewer options rather than loop forever
		valid = true;
		map = level.maps[randomInt(level.maps.size-1)];
		gamemode = level.gungamemodes[randomInt(level.gungamemodes.size)];
		foreach(invalid in level.invalidMaps)
		{
			if(map == invalid)
				valid = false;
		}
		if(!valid)
			i--;
		else
		{
			text += getDisplayName(map) + "[^3" + gamemode + "^7] [0]\n";			
			level.votes[i] = 0;
			level.options[i] = spawnstruct();
			level.options[i].map = map;
			level.options[i].gamemode = gamemode;
			level.invalidMaps[level.invalidMaps.size] = map;
		}
	}
	level.elems setText(text);
	foreach(player in level.players)
	{
		player.scrollbarY = -75;
		player.scrollbar = player createPlayerRectangle("line_horizontal","CENTER", "CENTER", 0,player.scrollbarY,220,11);
		player.scrollbar.color = (0,1,0);
		player.scrollbar.sort = 2;
		player thread doControls();		
	}
	level waittill("finishVote");
	background destroy();
	
	//background2 destroy();
	//background3 destroy();
	header destroy();
	timer destroy();
	timer2 destroy();
	controls destroy();
	controls2 destroy();
	controls3 destroy();
	arrowUp destroy();
	arrowDown destroy();
	line destroy();
	line2 destroy();
	line3 destroy();
	credits destroy();
	maps = [];
	level.elems destroy();
	foreach(player in level.players)
		player.scrollbar destroy();
	
	sameVote = -1;
	altVote = "";
	number = 0;
	maxVote = level.votes[0];
	for(i = 1;i < level.votes.size;i++)
	{
		if(level.votes[i] >= maxVote)
		{
			maxVote =  level.votes[i];
			sameVote = -1;
			number = i;
		}
	}
	mod\main::initializeGametype(level.options[number].gamemode);
	setDvar("sv_mapRotationCurrent", "map " + level.options[number].map);
	setDvar("sv_mapRotation", "map " + level.options[number].map);
	level notify("endVote");
	wait 0.1;
	map(level.options[number].map);
}
doControls()
{
	self endon("disconnect");
	level endon("finishVote");
	self.totalVotes = 0;
	self.position = 0;
	self.oldPosition = self.position;
	voted = false;
	self thread onForward();
	self thread onBackward();
	self notifyOnPlayerCommand("Stand", "+gostand");
	while(true)
	{
		self waittill("Stand");
		if(self.totalVotes > 3)
		{
			self iPrintln("^1Maximal votes done");
			continue;
		}
		self.totalVotes++;
		if(voted)
		{
			level.votes[self.oldPosition]--;
			//level.elems[self.oldPosition] setText(getDisplayName(level.options[self.oldPosition]) + " [" + level.votes[self.oldPosition] + "]");
			
		}
		self.oldPosition = self.position;
		//voted = level.options[self.position];
		voted = true;
		level.votes[self.position]++;
		//level.elems[self.position] setText(getDisplayName(level.options[self.position]) + " [" + level.votes[self.position] + "]");
		// FIX: Rebuild vote text only if it actually changed, and cap total rebuilds.
		// Each unique setText() string permanently burns a configstring slot (512 limit).
		text = "";
		for(i = 0;i < level.maxOptions;i++)
		{
			text += getDisplayName(level.options[i].map) + " [^3" + level.options[i].gamemode + "^7][" + level.votes[i] + "]\n";			
		}
		if(!isDefined(level._lastVoteText) || level._lastVoteText != text)
		{
			level.elems setText(text);
			level._lastVoteText = text;
		}
	}
}
onForward()
{
	self endon("disconnect");
	level endon("finishVote");
	self notify("onForward");
	self endon("onForward");
	self notifyOnPlayerCommand("Forward", "+forward");
	while(true)
	{
		self waittill("Forward");
		self.position--;		
		self.scrollbar destroy();
		if(self.position < 0)
		{
			self.position = level.maxOptions-1;
			self.scrollbarY = 51;
		}
		else
			self.scrollbarY -= 18;
			
		//self.scrollbar = self createPlayerRectangle("line_horizontal","CENTER", "CENTER", level.elems[self.position].x,level.elems[self.position].y,220,8);
		self.scrollbar = self createPlayerRectangle("line_horizontal","CENTER", "CENTER", 0,self.scrollbarY,220,11);
		self.scrollbar.color = (0,1,0);
		self.scrollbar.sort = 2;	
	}
}
onBackward()
{
	self endon("disconnect");
	level endon("finishVote");
	self notify("onBackward");
	self endon("onBackward");
	self notifyOnPlayerCommand("Backward", "+back");
	while(true)
	{
		self waittill("Backward");	
		self.position++;
		if(self.position > level.maxOptions-1)
		{
			self.position = 0;	
			self.scrollbarY = -75;
		}
		else
			self.scrollbarY += 18;
		//iPrintln(self.scrollbarY);	
		self.scrollbar destroy();		
		//self.scrollbar = self createPlayerRectangle("line_horizontal","CENTER", "CENTER", level.elems[self.position].x,level.elems[self.position].y,220,8);
		self.scrollbar = self createPlayerRectangle("line_horizontal","CENTER", "CENTER", 0,self.scrollbarY,220,11);
		self.scrollbar.color = (0,1,0);
		self.scrollbar.sort = 2;	
	}
}
killGungameHUD()
{
	foreach(player in level.players)
	{
		for(i=2;i<6;i++) 
		{
	   		if(isDefined(player.multitext[i]))
				player.multitext[i] destroy();
		}

		if(isdefined(player.scoretext))
			player.scoretext destroy();
		if(isdefined(player.scoretext_amount))
			player.scoretext_amount destroy();
		if(isdefined(player.weaponhud))
			player.weaponhud destroy();
		if(isdefined(player.weapontotalhud))
			player.weapontotalhud destroy();
		if(isdefined(player.killhud))
			player.killhud destroy();
		if(isdefined(player.killtotalhud))
			player.killtotalhud destroy();
		if(isdefined(player.ratiohud))
			player.ratiohud destroy();
		if(isDefined(player.streakText))
			player.streakText destroy();	
		
		if(isDefined(player.streakIcons))
		{
			foreach(icon in player.streakIcons)
			{
				if(isDefined(icon))
					icon destroy();
			}
		}

		if(isDefined(player.markerIconsEnemies))
		{
			foreach(icon in player.markerIconsEnemies)
			{
				if(isDefined(icon))
					icon destroy();
			}
		}

		if(isDefined(player.healthHUD))
			player.healthHUD destroy();

		if(isDefined(player.versionText))
			player.versionText destroy();

		if(isDefined(player.line))
			player.line destroy();	   
	}
}
















