#include common_scripts\utility; 
#include maps\mp\_utility; 
#include maps\mp\gametypes\_hud_util;

/////////////////////
//
// Gamemodes: 
// 
//  - basic
//  - team gungame
//  - no streaks
//  - snipers only
//  - kill confirmed
//  - pistol & shotgun only  (disabled)

Init()
{
    level._effect["claymore_explode"] = loadfx("explosions/tanker_explosion");
    loadSettings();
    thread mod\weapons::loadWeapons();
    thread mod\streaks::loadStreaks();
    thread mod\vote::loadVote(); // does not work
    thread onPlayerConnect();
    thread deleteSentries();
    thread launchGame();
}
setGamemodes()
{
    level.gungamemodes = [];
    level.gungamemodes[level.gungamemodes.size] = "Fungame"; // God of Hellfire addition
    level.gungamemodes[level.gungamemodes.size] = "Classic";
    // level.gungamemodes[level.gungamemodes.size] = "Classic"; // raising the chance
    // level.gungamemodes[level.gungamemodes.size] = "Classic";
    // level.gungamemodes[level.gungamemodes.size] = "No Streaks";
    // level.gungamemodes[level.gungamemodes.size] = "Snipers only";
    //level.gungamemodes[level.gungamemodes.size] = "Pistol & Shotguns only"; // works but is it fun?
    // level.gungamemodes[level.gungamemodes.size] = "Team Gungame";
    // level.gungamemodes[level.gungamemodes.size] = "Kill Confirmed";
}
initializeGametype(type) // called in vote.gsc after first map
{
    setDvar("gunmode", type);
    setDvar("gun_kills", 1); // Default to 1 kill per weapon
    if(type == "Team Gungame")
        setDvar("g_gametype", "gungame_team");
    else
        setDvar("g_gametype", "gungame");    
    switch(type)
    {
        case "Classic":
            setDvar("global_health", 60);
            setDvar("speed", 1.2);
            setDvar("streaks_online", 1);
            setDvar("jump_height", 60);
            setDvar("amount_weapons", 100);
            setDvar("shuffle_weapons", 1);
            break;
        case "No Streaks":
            setDvar("global_health", 70);
            setDvar("speed", 1.2);
            setDvar("streaks_online", 0);
            setDvar("jump_height", 70);
            break;    
        case "Snipers only":
            setDvar("global_health", 70);
            setDvar("speed", 1.2);
            setDvar("streaks_online", 1);
            setDvar("jump_height", 70);
            break;
        case "Pistol & Shotguns only":
            setDvar("global_health", 70);
            setDvar("speed", 1.2);
            setDvar("streaks_online", 1);
            setDvar("jump_height", 70);
            break;      
        case "Team Gungame":
            setDvar("global_health", 70);
            setDvar("speed", 1.2);
            setDvar("streaks_online", 1);
            setDvar("jump_height", 70);
            break;  
        case "Kill Confirmed":
            setDvar("global_health", 100);
            setDvar("speed", 1);
            setDvar("streaks_online", 1);
            setDvar("jump_height", 70);
            break;       
        case "Fungame":
            setDvar("global_health", 60);
            setDvar("speed", 1.5);
            setDvar("streaks_online", 1);
            setDvar("jump_height", 0.5);
            setDvar("amount_weapons", 150);
            setDvar("gun_kills", 1);
            break;    
        default: // not required
            setDvar("global_health", 70);
            setDvar("speed", 1.2);
            setDvar("streaks_online", 1);
            setDvar("jump_height", 70);
            setDvar("amount_weapons", 100);
            break;    
    }
}
loadSettings()
{
    /////////////////////// CUSTOM SETTINGS /////////////////////////////
    //SetDvarIfUninitialized("gunmode", "Classic");
    SetDvarIfUninitialized("gunmode", "Fungame");
    initializeGametype(getDvar("gunmode"));

    if(getDvar("g_gametype") == "gungame_team")
        setDvar("amount_weapons", int(getDvarInt("amount_weapons")/4));
    
    setDvar("shuffle_weapons", 0);
    setDvar("intermission", 15);
    SetDvarIfUninitialized("show_damage_ui", 1);
    setDvar("gunversion", "1.5 Remaster by ^1Santahunter - Modified by God of Hellfire");
    /////////////////////////////////////////////////////////////////////
    setDvar("scr_" + (getDvar("g_gametype")) + "_timelimit", 0); 	
	setDvar("scr_" + (getDvar("g_gametype")) + "_scorelimit", 0); 
	setDvar("ui_allow_teamchange", 0); 
    setDvar("testClients_watchKillcam", 0); 	
	setDvar("scr_game_hardpoints", 0); 	
	setDvar("scr_game_graceperiod", 0); 	
	setDvar("scr_game_matchstarttime", 0); 
	setDvar("scr_game_playerwaittime", 0); 
    setDvar("g_hardcore", 1);
    setDvar("bg_viewKickScale", 0);
    setDvar("cg_viewkickscale", 0);
    setDvar("cg_drawDamageFlash", 0);
    setDvar("bg_shock_lookControl_mousesensitivityscale", 1);
    setDvar("bg_shock_movement", 0);
    setDvar("bg_shock_lookControl", 0);
    setDvar("bg_shock_screenBlurBlendTime", 0);
    setDvar("bg_shock_screenBlurBlendFadeTime", 0);

    level.state = "prematch";
    level.markerIcon = "ui_host";
    level.teamKills = [];
    level.teamKills["allies"] = 0;
    level.teamKills["axis"] = 0;
    level.teamKills["allies_weapon"] = 1;
    level.teamKills["axis_weapon"] = 1;
    precacheShader(level.markerIcon);
    setGamemodes();
    
    // Bot Management
    setDvar("bots_main", 1);
    setDvar("bots_manage_fill", 12);
    setDvar("bots_skill", 5);
}
deleteSentries()
{
    turret = GetEntArray("misc_turret","classname");   
	for(i=0;i<turret.size;i++) 	   
	    turret[i] delete(); 
}
launchGame()
{
    hud = createServerFontString("hudbig", 1);
    hud setPoint("CENTER", "CENTER", 0,-80);
    hud.color = (1,1,0);
    hud.glowAlpha = 1;
    hud.glowColor = (.7,0,0);
    hud setText("Game starting in");

    value = createServerFontString("hudbig", 1.75);
    value setPoint("CENTER", "CENTER", 0,0);
    value.glowAlpha = 1;
    value.color = (1,1,0);
    value.glowAlpha = 1;
    value.glowColor = (.7,0,0);
    
    for(i = getDvarInt("intermission");i > 0;i--)
    {
        value changeFontScaleOverTime(1);
        value.fontScale = 0.5;
        value setValue(i);
        wait 1;
        value.fontScale = 1.75;
        foreach(player in level.players)
        {
            player playLocalSound("ui_mp_suitcasebomb_timer");
        }
    }
    level.state = "ingame";
    value setValue(0);
    foreach(player in level.players)
    {
        player enableWeapons();
        player visionSetNakedForPlayer(getDvar("mapname"), 2);
        player setMoveSpeedScale(1.25);
    }
       
    setDvar("jump_height", 60);
    hud destroy();
    value destroy();
    //player freezeControls(false);
}
onPlayerConnect()
{
    while(true)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}
onPlayerSpawned()
{
    self endon("disconnect");
    self thread firstSpawn();
    while(true)
    {
        self waittill("spawned_player");
        self thread loadSetup();
        // self thread test();
    }
}
firstSpawn()
{
    self endon("disconnect");
    team = getCorrectTeam();
    self thread setStartWeapon(team);
    self.firstSpawn = true;
    self.knifeKills = 0;
    self.gungameKills = 0;
    self.streaks = [];
    self setClientDvar("cg_drawSplatter", 0); 
    self setClientDvar("cg_drawDamageFlash", 0);
    self setClientDvar("cg_viewkickscale", 0.1);
    self setClientDvar("bg_viewKickScale", 0.1);
    self setClientDvar("bg_shock_lookControl_mousesensitivityscale", 1);
    self setClientDvar("bg_shock_movement", 0);
    self setClientDvar("bg_shock_lookControl", 0);
    self setClientDvar("ui_drawradar", 0);
    self setClientDvar("cg_drawTeamScores", 0);
	self.hud_damagefeedback.color = (1,0,0); 
    self.line = self createRectangle("CENTER", "LEFT", 0,-90,300,5,(1,1,0),"line_horizontal",1);
    self thread onKilling();
    self thread createUI();
    self thread refillOnFire();
    self thread watchVersion();
    self thread FPSBoost(); 
    if(getDvar("g_gametype") == "gungame_team") 
        self thread upgradeOnTeamKills();
    for(i=1;i<3;i++)	 
	    self setClientDvar("lowAmmoWarningNoAmmoColor" + i, 0, 0, 0, 0); 
    wait .2;
    self notify("menuresponse", game["menu_team"], team);
	wait .1;   
	self notify("menuresponse", "changeclass", "class1");	 	
    wait .1;    
    self.firstSpawn = false;
    self thread tryCreateMarkerIcons();
}
getCorrectTeam()
{
    if(getDvar("g_gametype") != "gungame_team") 
        return "allies";
    allies = 0;
    axis = 0;
    foreach(player in level.players)
    {
        if(player.team == "allies")
            allies++;
        else if(player.team == "axis")
            axis++;    
    }
    if(allies >= axis)  
        return "allies";
    return "axis";    
}       
setStartWeapon(team)
{
    if(getDvar("g_gametype") != "gungame_team") 
        self.current = 1;
    else    
        self.current = level.teamKills[team + "_weapon"];
}
loadSetup()
{
    self hide();
    self thread mod\streaks::setStreaks();
    self takeAllWeapons();
    self _clearPerks();
    self thread updateWeapon();
    self.maxhp = getDvarInt("global_health"); 
	self.actual_maxhealth = self.maxhp; 
	self.actual_health = self.actual_maxhealth;
    self.maxhealth = 1000;
    self.health = 1000;
    self thread watchHealthHUD();
    self thread watchRegen();
    self thread watchDeagleGL();
    self thread watchM40A3();
    self thread watchHUD();
    self.streaking = 0;
    self.speed = false;
    self.isJugger = false;
    self.moveSpeedScaler = getDvarFloat("speed"); 
	self setMoveSpeedScale(getDvarFloat("speed")); 
    self maps\mp\perks\_perks::givePerk("specialty_fastreload"); // due to icys request :)
    self maps\mp\perks\_perks::givePerk("specialty_falldamage"); // due to icys request :)
    self maps\mp\perks\_perks::givePerk("specialty_quickdraw"); 

    self thread takeInvalidWeapon();
    if(level.state ==  "prematch")
    {
        //self freezeControls(true);
        self setMoveSpeedScale(0);
        self disableWeapons();
        self visionSetNakedForPlayer("blacktest", 0);
        waitFrame();
        if(level.state == "prematch")
            self setMoveSpeedScale(0);
    }    
}
upgradeOnTeamKills()
{
    self endon("disconnect");
    while(true)
    {
        level waittill("upgrade_" + self.team);
        wait .3;
        enemyTeam = self getEnemyTeam();
        self.current = level.teamKills[self.team + "_weapon"];
        self thread updateWeapon();
        self.weaponhud setText("Weapon: " + self.current + "/" + (level.gungameList.size) + "/^3" + level.teamKills[enemyTeam + "_weapon"]); 	
    }
}
getEnemyTeam()
{
    if(self.team == "allies")
        return "axis";   
    return "allies";
}
updateWeapon()
{
    if(self.current > (level.gungameList.size - 1))
    {
        self thread tryNuke();
        return;
    }
    //self iPrintlnBold(level.gungameList[self.current]);
    variant = randomInt(9);
    if(getDvar("gunmode") == "Fungame")
        variant = 0;
    if (isSubstr(level.gungameList[self.current], "_akimbo")) 
	    self giveWeapon(level.gungameList[self.current],  variant, true); 
	else 		
	    self giveWeapon(level.gungameList[self.current],  variant, false);
    self giveWeapon("onemanarmy_mp");
    self takeWeapon(self getCurrentWeapon());
    self giveMaxAmmo(level.gungameList[self.current]);
    waitFrame();
    self switchtoweaponimmediate(level.gungameList[self.current]);
    waitFrame();
    if(level.state == "prematch" || level.state == "ingame")
        self show();
    if(self.isJugger)
        self setMoveSpeedScale(1);
    else if(self.speed)
         self setMoveSpeedScale(1.6);
    if(level.state ==  "prematch")
    {
        self setMoveSpeedScale(0);
        if(level.state == "prematch")
            self setMoveSpeedScale(0);
    }   

    if(isDefined(self.pers["isBot"]) && self.pers["isBot"] && getDvar("gunmode") == "Fungame")
    {
        if(level.gungameList[self.current] == "riotshield_mp")
            self setClientDvar("bots_play_knife", 1);
        else
            self setClientDvar("bots_play_knife", 0);
    }

    if(self getCurrentWeapon() == "none" && !self isMantling() && !self isOnLadder()) // in rare case weapon does not exist
    {
        self updateWeapon();
    }
}
refillOnFire()
{
    self endon("disconnect");
    while(true)
    {
        self waittill("weapon_fired");
        weapon = self getCurrentWeapon();
        self giveMaxAmmo(weapon);
    }
}
onKilling() {  
	self endon("disconnect"); 
	level endon("nuke"); 
	self.multiplier = 0; 
	self.amount = 0; 
	//kills = self.pers["kills"]; 
    kills = 0;
    refreshCounter = 0;
	self.scoretext = self createText("hudbig", 1, "CENTER", "CENTER", 0, 0, .7,""); 
	self.scoretext_amount = self createText("hudbig", 1, "CENTER", "CENTER", -10, 20, .7,""); 	
	self.multitext = []; 
	for(i=2;i<6;i++) 
	    self.multitext[i] = self createText("hudbig", .6, "CENTER", "CENTER", 50, (i * 20), .7,"");         
	while(true)
    {
        wait .3;
        if(kills > self.gungameKills) // not called on team gungame
        {
            self thread scorepopup(-100);	
            kills--;
            refreshCounter++;
            killsPerWeapon = getDvarInt("gun_kills", 1);
            if(killsPerWeapon > 1)
            {
                killsInGun = (self.gungameKills % killsPerWeapon);
                self.weaponhud setValue(self.current);
                self.killhud setValue(killsInGun);
                self.killhud.alpha = 1;
                self.killtotalhud.alpha = 1;
            }
            else
            {
                self.weaponhud setValue(self.current);
                self.killhud.alpha = 0;
                self.killtotalhud.alpha = 0;
            }
            self refreshCounter(refreshCounter);
            self updateRatio();
        }
        else if(kills < self.gungameKills)
        {
            kills++;
            refreshCounter++;
            self thread scorepopup(100);
            self.streaking++; 	
            if(getDvar("g_gametype") != "gungame_team")
            {
                killsPerWeapon = getDvarInt("gun_kills", 1);
                if(killsPerWeapon > 1)
                {
                    if(self.gungameKills % killsPerWeapon == 0)
                    {
                        self.current++;
                        self thread updateWeapon();
                    }
                    killsInGun = (self.gungameKills % killsPerWeapon);
                    self.weaponhud setValue(self.current);
                    self.killhud setValue(killsInGun);
                }
                else
                {
                    self.current++;
                    self thread updateWeapon();
                    self.weaponhud setValue(self.current);
                }
            }
            if(self.current >= (level.gungameList.size-5) && !isDefined(self.markerIcon))
                self thread initCreateMarkerIcon();
            self refreshCounter(refreshCounter);
            self updateRatio();
        }  
    }
}
updateRatio()
{
    if(self.deaths != 0) 		 
        ratio = (self.kills/self.deaths); 		
    else           
        ratio = self.kills;		
    self.ratiohud setValue(floatToString(ratio)); 	
}
refreshCounter(refreshCounter)
{
    if(refreshCounter == 10) 	
    { 		 
        refreshCounter = 0;
        self.weaponhud destroy(); 	
        self createWeaponHud();	
    }    
}
warning(friendly) 
{ 
    self notify("warning");
 	if(friendly == 0) 
	    warning = self createText("hudbig", .8, "CENTER", "CENTER", 0, 130, 1,"Enemy's powershield absorbed damage!"); 
	else if(friendly == 1)
	    warning = self createText("hudbig", .8, "CENTER", "CENTER", 0, 130, 1,"Powershield absorbed damage!");
	else if(friendly == 2) 
        warning = self createText("hudbig", .8, "CENTER", "CENTER", 0, 130, 1,"Enemy demoted you!"); 
	else  	 
	    warning = self createText("hudbig", .8, "CENTER", "CENTER", 0, 130, 1,"You demoted yourself!");	 
	self thread clearWarning(warning); 
	warning.glowColor = (1,0,0); 	
	warning fadeovertime(5); 	
	warning.alpha = 0; 	
	wait 5; 	
	if(isDefined(warning)) 	 
	warning destroy(); 
	self notify("warning_end");
} 
clearWarning(hud) 
{  
	self endon("warning_end"); 
	self waittill("warning"); 	
	if(isDefined(hud)) 	 
	    hud destroy(); 
} 
createText(font,fontScale,align,relative,x,y,alpha,input,color,gcolor,galpha) 
{ 
	text = self createFontString(font,fontScale,self); 
	text setPoint(align,relative,x,y); 
	text.sort = 999;
 	text.alpha = alpha; 
	if(isDefined(color))	
	    text.color = color; 	
	if(isDefined(gcolor))	 
    	text.glowcolor = gcolor;	
 	if(isDefined(galpha))     
	    text.glowalpha = galpha; 
	else 	  
	    text.glowalpha = 1; 
	text setText(input); 
	text.HideWhenInMenu = true; 	
	return text; 
} 
scorepopup(amount)
{  
	self endon("disconnect"); 
	self notify("scoring"); 	
	self endon("scoring"); 
	self.multiplier++;	 	
	self.amount = self.amount + amount; 
	color = (0,0,0); 
	glowColor = (0,0,0); 	
	switch(self.multiplier) 
	{ 	   
        case 1: 
            color = (1,1,1); 	
            glowColor = (0,1,0); 		
            break; 		
        case 2: 	
            color = (1,1,0); 	
            glowColor = (1,0,0); 	
            break; 		
        case 3: 		
            color = (0,0,0); 	
            glowColor = (1,0,0); 	
            break; 		
        default:	
            color = (0,0,0);  	
            glowColor = (0,0,1); 	
            break;	 	
	} 		 
	self.scoretext.alpha = 1; 
  	self.scoretext_amount.alpha = 1; 
  	self.scoretext.color = color; 	
	self.scoretext.glowColor = glowColor; 
	self.scoretext SetPulseFX( 40, 2000, 600 );
    if(getDvar("gunmode") == "Kill Confirmed")
 	    self.scoretext setText("Upgraded!^3"); 
    else
        self.scoretext setText("Killed!^3");
	self.scoretext_amount.color = color; 
	self.scoretext_amount.glowColor = glowColor;
 	self.scoretext_amount SetPulseFX( 40, 2000, 600 );
 	self.scoretext_amount setText("+" + self.amount); 	
	if(self.multiplier > 1) 	
	{ 	
        self.multitext[self.multiplier].alpha = 1;  
        self.multitext[self.multiplier] fadeOverTime(0.1);	 
        self.multitext[self.multiplier].color = color; 		
        self.multitext[self.multiplier].glowColor = glowColor; 	
	}	
	if(self.multiplier == 2) 
	{ 	 
        self thread lowerMultitext(self.multiplier); 	
        self.multitext[self.multiplier] setText("Double Kill!"); 
	}	    			     
	else if(self.multiplier == 3) 	
        self.multitext[self.multiplier] setText("Triple Kill!");	
 	else if(self.multiplier == 4) 	
        self.multitext[self.multiplier] setText("Multi Kill!");		
 	else if(self.multiplier > 4) 	
	{ 	  
        color = []; 	
        for(i = 0;i < 13;i++) 	
        color[i] = randomInt(9); 	
        difference = self.multiplier - 4; 	
        self.multitext[5] setText("^3x" + difference + " ^" + color[0] + "K^" + color[1] + "i^" + color[2] + "l^" + color[3] + "l^" + color[4] + "i^" + color[5] + "n^" + color[6] + "g ^" + color[7] + "S^" + color[8] + "p^" + color[9] + "r^" + color[10] + "e^" + color[11] + "e^" + color[12] + "!"); 
	}	  
   	self thread lowerMultiplier(); 
}
lowerMultiplier()
{    
	self endon("disconnect"); 	
	self notify("lowering"); 
	self endon("lowering"); 
	wait 5; 
	self notify("start_lowering");
 	self.multiplier = 0; 
	self.amount = 0; 
} 
lowerMultitext(multiplier) 
{
 	self waittill_any("start_lowering", "disconnect");
	for(i=2;i<6;i++) 	
    { 	  
        self.multitext[i] fadeOverTime(3);	
        self.multitext[i].alpha = 0; 
        wait .75; 
	} 
	wait 4; 
} 
tryNuke()
{
    if(isDefined(level.startNuke))
        return;
    level.state = "aftermatch";
    level notify("nuke");
    if(getDvar("g_gametype") != "gungame_team")
        self.weaponhud setValue(level.gungameList.size-1);

    //self thread mod\api::tryCallApi("increment");
    foreach(player in level.players)
        player hide();
    self thread maps\mp\killstreaks\_nuke::tryUseNuke();
}
createUI()
{
    self thread createWeaponHud();	
    self thread createKillHud();
    self thread Weaponnumber();
    self thread createRatioHud();
}
createWeaponHud()
{
    self.weaponhud = self createFontString("hudsmall", 1.2);
    self.weaponhud setPoint("RIGHT", "CENTER", -350, -105); 	
    self.weaponhud.glowalpha = .5; 
    self.weaponhud.color = (1,1,0); 
    self.weaponhud.hideWhenInMenu = true;
    self.weaponhud.glowcolor = (1,0,0);
    self.weaponhud.label = &"Weapon: ";
    self.weaponhud setValue(self.current);

    self.weapontotalhud = self createFontString("hudsmall", 1.2);
    self.weapontotalhud setPoint("LEFT", "CENTER", -350, -105); 	
    self.weapontotalhud.glowalpha = .5; 
    self.weapontotalhud.color = (1,1,0); 
    self.weapontotalhud.hideWhenInMenu = true;
    self.weapontotalhud.glowcolor = (1,0,0);
    self.weapontotalhud.label = &" / ";
    self.weapontotalhud setValue(level.gungameList.size - 1);
}
createKillHud()
{
    self.killhud = self createFontString("hudsmall", 1.2);
    self.killhud setPoint("RIGHT", "CENTER", -350, -85); 	
    self.killhud.glowalpha = .5; 
    self.killhud.color = (1,1,0); 
    self.killhud.hideWhenInMenu = true;
    self.killhud.glowcolor = (1,0,0);

    self.killtotalhud = self createFontString("hudsmall", 1.2);
    self.killtotalhud setPoint("LEFT", "CENTER", -350, -85); 	
    self.killtotalhud.glowalpha = .5; 
    self.killtotalhud.color = (1,1,0); 
    self.killtotalhud.hideWhenInMenu = true;
    self.killtotalhud.glowcolor = (1,0,0);

    killsPerWeapon = getDvarInt("gun_kills", 1);
    if(killsPerWeapon > 1)
    {
        self.killhud.label = &"Kills: ";
        self.killhud setValue(0);
        self.killtotalhud.label = &" / ";
        self.killtotalhud setValue(killsPerWeapon);
        self.killhud.alpha = 1;
        self.killtotalhud.alpha = 1;
    }
    else
    {
        self.killhud.alpha = 0;
        self.killtotalhud.alpha = 0;
    }
}
createRatioHud()
{
    self.ratiohud = self createFontString("hudsmall", 1); 
    self.ratiohud setPoint("LEFT", "CENTER", -410, -125); 
    self.ratiohud.color = (1,1,0); 	
    self.ratiohud.glowalpha = .3; 
    self.ratiohud.glowcolor = (1,0,0); 
    self.ratiohud.label = &"Ratio: ";
    self.ratiohud.alpha = 0;
    self waittill_any("death", "killed_lethal");
    self.ratiohud fadeOverTime(2);
    self.ratiohud.alpha = 1;
}
Weaponnumber() // deprecated
{  
    self notify("weaponnumber"); 	
    self endon("weaponnumber");     
    self endon("disconnect"); 		
    kills = 0; 
    oldkills = 0;
    wait 1;
    while(1) 	
    {
        kills++; 	 
        self.weaponhud setValue(self.current);
        //self waittill("killed_enemy"); 
        self waittill("update_weaponNumber");
        //progress updateBar(self.current/level.weapon.size); 			
        if(kills >= 10) 	
        { 		 
            self.weaponhud destroy(); 	
            self createWeaponHud();
            self thread Weaponnumber(); 	
        } 
        if(oldkills != self.kills) 	
        { 		 
            oldkills = self.kills; 
            if(self.deaths != 0) 		 
                ratio = (self.kills/self.deaths); 		
            else           
                ratio = self.kills;		
            self.ratiohud setValue(floatToString(ratio)); 	
        } 
    } 
} 
floatToString(float)
{    
    string = "" + float;  
    if(string.size > 5)    
        string = getSubStr(string, 0, 5);  
    return StringToFloat(string);
} 
takeInvalidWeapon()
{
    self endon("disconnect");
    self endon("death");
    level endon("nuke");
    counter = 0;
    wait 3;
    while(1) 	
    {
        waitFrame(); 
        if(!isAlive(self))
            continue;
        if(self isMantling())
            continue;
        weapon = self getCurrentWeapon();
        if(!self hasWeapon(level.gungameList[self.current]))
        {
            counter++;
            if(counter == 2)
            {
                counter = 0;
                level.gungameList[self.current] = mod\weapons::setWeapon("peacekeeper_mp");
            }
        }
        if(weapon != level.gungameList[self.current])
        {
            self takeAllWeapons();
            self thread updateWeapon();
            wait 2.5;
        }
    }
}
takeInvalidWeapon2()
{
    self endon("disconnect");
    level endon("nuke");
    counter = 0;
    wait 3;
    while(1) 	
	{ 	  
		wait .25; 
        if(!isAlive(self))
            continue;
		weapon = self getCurrentWeapon(); 
		if((weapon != level.gungameList[self.current] && weapon != "killstreak_uav_mp") || weapon == "none") 	
		{ 		  
            weaponArray = strTok(weapon, "_");
            //if(weapon == ("gl_" + weaponArray[1] + "_mp"))
            //    continue;
            //if(weapon == "none" && self isMantling())    
            //    continue;
            //self iPrintln("false");
            //iPrintlnBold(weapon);
			self takeAllWeapons(); 	   
			//if(!self hasWeapon(level.gungameList[self.current]) || weapon == "none") 	
			//{ 		
                counter++; 
                if(counter == 40) // debug
                {
                    self.gungameKills++;
                    counter = 0;
                    self.current++;
                    self thread updateWeapon();
                    wait 1;
                }
                else
				    self updateWeapon();
				wait .2;					 		
			//} 			
			//if(level.gungameList[self.current] == "throwingknife_mp") 	
			//	self thread ThrowingKnife(); 		
			if(!self.speed)         
			{ 			
				speed = level.speed; 	   
				self setMoveSpeedScale(speed); 		
				if(self.hardmode == 1) 			
				{ 				
					speed = level.speed * 0.8; 		
					self setMoveSpeedScale(speed); 	
				} 
				self.moveSpeedScaler = speed; 					
		}			
		} 		
		else if(weapon == "usp_tactical_mp") 	
		{  		
			speed = level.speed * 1.2; 	     
			self setMoveSpeedScale(speed); 		
			self setWeaponAmmoClip("usp_tactical_mp", 0); 		
			self setWeaponAmmoStock("usp_tactical_mp", 0); 	
		}		 	
	} 
}
ThrowingKnife() 
{   
	self endon("disconnect"); 	 
	self notify("tk"); 
	self endon("tk"); 
	for(;;) 
	{ 	 
        self waittill( "grenade_fire", lightstick, weapName ); 	
        if(weapName == "throwingknife_mp") 	
        { 	
        self giveWeapon("throwingknife_mp"); 	
        self giveMaxAmmo("throwingknife_mp"); 		
        } 	
    } 
}
giveGun(weapon, variant) 
{  
	if (!isDefined(variant)) 	
	    variant = randomInt(9); 
	if (isSubstr(weapon, "_akimbo")) 
	    self giveWeapon(weapon, variant, true); 
	else 		
	    self giveWeapon(weapon, variant, false); 
}
initCreateMarkerIcon()
{
    rank = 1;
    foreach(player in level.players)
    {
        if(isDefined(player.markerIcon))
            rank++;
    }
    self.markerIcon = rank;
    self.markerIconsEnemies = [];
    self thread createWarnHUD();
    if(self.isJugger)
        self notify("isMarked");
    foreach(player in level.players)
    {
        if(player != self)
        {
            self thread createMarkerIcon(player);
        }
    }
    self waittill("disconnect");
    foreach(icon in self.markerIconsEnemies)
    {
        if(isDefined(icon))
            icon destroy();
    }
}
createMarkerIcon(player)
{
    self.markerIconsEnemies[self.markerIconsEnemies.size] = NewClientHudElem(player);
    self.markerIconsEnemies[self.markerIconsEnemies.size-1] SetShader(level.markerIcon, 10, 10 );
    self.markerIconsEnemies[self.markerIconsEnemies.size-1].width = 10;
    self.markerIconsEnemies[self.markerIconsEnemies.size-1].height = 10;
    self.markerIconsEnemies[self.markerIconsEnemies.size-1].color = getColor(self.markerIcon);
    self.markerIconsEnemies[self.markerIconsEnemies.size-1].x = self.origin[ 0 ];
    self.markerIconsEnemies[self.markerIconsEnemies.size-1].y = self.origin[ 1 ];
    self.markerIconsEnemies[self.markerIconsEnemies.size-1].z = self.origin[ 2 ] + 55;
    self.markerIconsEnemies[self.markerIconsEnemies.size-1] SetWayPoint( true, true );
    self.markerIconsEnemies[self.markerIconsEnemies.size-1] SetTargetEnt(self);
}
getColor(rank)
{
    if(rank == 1)
        return (1, 215/255, 0); // gold
    if(rank == 2)
        return (155/255,0,0);   // darkred
    if(rank == 3)
        return (0,0,155/255);   // darkblue
    return (191/255, 137/255, 112/255);    // bronze  
}
createWarnHUD()
{
    /*
    warnHUD = self createFontString("hudsmall", 1.2);
    warnHUD setPoint("CENTER", "CENTER", 0, -10); 	
    warnHUD.glowalpha = .5; 
    warnHUD.color = (155/255,0,0); 
    warnHUD.hideWhenInMenu = true;
    warnHUD.glowcolor = (0,0,0); 	
    warnHUD setText("Final Game: You are marked for all enemies now!");
    wait 3;
    warnHUD destroy();
    */
    self thread maps\mp\gametypes\_hud_message::hintMessage("Final Game: You are marked for all enemies now!");
}
tryCreateMarkerIcons()
{
    foreach(player in level.players)
    {
        if(isDefined(player.markerIcon))
        {
            player thread createMarkerIcon(self);
        }
    }
}
createRectangle(align, relative, x, y, width, height, color, shader, sort)
{
	hud = newClientHudElem(self);
	hud.sTexType = "bar";
	hud.width = width;
	hud.height = height;
	hud.align = align;
	hud.relative = relative;
	hud.xOffset = 0;
	hud.yOffset = 0;
	hud.children = [];
	hud.sort = sort;
	hud.color = color;
	hud setParent(level.uiParent);
	hud setShader(shader,width,height);
	hud.hidden = false;
	hud.HideWhenInMenu = true;
	hud setPoint(align,relative,x,y);
	return hud;
}  
upgradeTeamUI(team)
{
	fontElem = newTeamHudElem( team );
	fontElem.elemType = "font";
	fontElem.font = "default";
	fontElem.fontscale = 1.6;
	fontElem.baseFontScale = 1.6;
    fontElem.glowAlpha = 1;
    fontElem.color = (1,1,0);
    fontElem.glowColor = (1,0,0);
	fontElem.x = 0;
	fontElem.y = 0;
	fontElem.width = 0;
	fontElem.height = int(level.fontHeight * 1.6);
	fontElem.xOffset = 0;
	fontElem.yOffset = 0;
	fontElem.children = [];
	fontElem setParent( level.uiParent );
	fontElem.hidden = false;
	fontElem setText("Weaponupgrade for your team!");
    fontElem setPoint("CENTER", "TOP", 0,200);
    wait 3;
    fontElem fadeOverTime(2);
    fontElem.alpha = 0;
    wait 2;
	fontElem destroy();
}
upgradeEnemyWeaponUI(team)
{
    foreach(player in level.players)
    {
        if(player.team == team)
        {
            player.weaponhud setText("Weapon: " + player.current + "/" + (level.gungameList.size) + "/^3" + level.teamKills[player getEnemyTeam() + "_weapon"]); 	
        }
    }
}
spawnDogTag(victim, attacker)
{
    picked = false;
    dogtag = spawn("script_model", victim.origin+(0,0,30));
    //dogtag setModel("test_sphere_silver");
    //playFxOnTag( level.spawnGlow["enemy"], self, "pelvis" ); 
	//playFxOnTag( level.spawnGlow["friendly"], self, "j_head" );
    fx = spawnFx(level.dogtag, dogtag.origin);
    fx2 = spawnFx(level.dogtag2, dogtag.origin);
    triggerFx(fx);
    triggerFx(fx2);
    while(!isDefined(level.startNuke) && !picked)
    {
        foreach(player in level.players)
        {
            if(Distance(player.origin, dogtag.origin) < 75 && isAlive(player))
            {
                if(player != victim)
                    player.gungameKills++;
                dogtag delete();
                fx delete(); 
                fx2 delete();   
                picked = true;
            }
        }
        wait .1;
    }
    if(isDefined(fx))
    {
        fx delete();
        fx2 delete();
    }
    if(!picked)
        dogtag delete();
}
FPSBoost() 
{  
	self endon("disconnect"); 
    self notifyonplayercommand("FPS", "+actionslot 2"); 
	for(;;) 
    { 	 
        self waittill("FPS"); 	
        self setClientDvar("r_fullbright", 1); 	
        self waittill("FPS"); 	
        self setClientDvar("r_fullbright", 0);
 	} 
}
test()
{
    self notifyOnPlayerCommand("F", "+activate");
    self thread test2();
    while(true)
    {
        self waittill("F");
        //self thread tryNuke();
        // setDvar("g_gametype", "gungame_team");
        // map("mp_rust");
        self suicide();
    }
}
test2()
{
    self notifyOnPlayerCommand("G", "+frag");
    self thread test2();
    while(true)
    {
        self waittill("G");
        setDvar("g_gametype", "gungame");
        setDvar("gunmode", "Kill Confirmed");
        map("mp_rust");
    }
}
watchVersion()
{
    self endon("disconnect");
    self notifyOnPlayerCommand("open", "+scores");
    self notifyOnPlayerCommand("close", "-scores");
    while(true)
    {
        self waittill("open");
        self.versionText = self createFontString("hudbig", .60);
        self.versionText setPoint("CENTER", "BOTTOM", 0,-40);
        self.versionText setText(getDvar("gunversion"));
        self waittill("close");
        self.versionText destroy();
    }
}
watchHealthHUD()
{
    self endon("disconnect");
    self endon("death");
    
    if(isDefined(self.healthHUD))
        self.healthHUD destroy();
        
    self.healthHUD = self createFontString("hudsmall", 1.2);
    self.healthHUD setPoint("BOTTOM RIGHT", "BOTTOM RIGHT", -10, -10);
    self.healthHUD.label = &"HP: ";
    
    while(true)
    {
        self.healthHUD setValue(self.actual_health);
        if(self.actual_health < (self.actual_maxhealth * 0.3))
            self.healthHUD.color = (1, 0, 0);
        else
            self.healthHUD.color = (1, 1, 1);
        wait 0.1;
    }
}

watchRegen()
{
    self endon("disconnect");
    self endon("death");
    
    while(true)
    {
        self waittill("takeDamage");
        wait 5; // wait 5 seconds after damage
        
        while(self.actual_health < self.actual_maxhealth)
        {
            self.actual_health += 5;
            if(self.actual_health > self.actual_maxhealth)
                self.actual_health = self.actual_maxhealth;
            
            wait 0.1;
        }
    }
}

watchDeagleGL()
{
    self endon("disconnect");
    while(true)
    {
        self waittill("weapon_fired", weaponName);
        if(weaponName == "deserteagle_akimbo_mp")
        {
            angles = self getPlayerAngles();
            forward = anglesToForward(angles);
            start = self getEye();
            end = start + (forward * 10000);
            MagicBullet("gl_mp", start, end, self);
            
            if(isDefined(self.pers["isBot"]) && self.pers["isBot"])
                wait .3;
            else
                wait .15;
        }
    }
}

watchHUD()
{
    self endon("disconnect");
    while(true)
    {
        self setClientDvar("ui_drawradar", 1);
        self setClientDvar("cg_drawRadar", 1);
        self setClientDvar("cg_drawAmmo", 1); // Force ammo back on even in hardcore
        self setClientDvar("cg_drawStance", 0);
        self setClientDvar("cg_drawTeamScores", 0);
        self setClientDvar("cg_drawKillfeed", 0);
        self setClientDvar("ui_hud_hardcore", 1);
        self setClientDvar("cg_drawBreathHint", 0);
        self setClientDvar("cg_drawMantleHint", 0);
        self setClientDvar("cg_drawTurretCrosshair", 0);
        self setClientDvar("cg_cursorHints", 0);
        wait 1;
    }
}

watchM40A3()
{
    self endon("disconnect");
    while(true)
    {
        self waittill("weapon_fired", weaponName);
        if(weaponName == "m40a3_mp")
        {
            angles = self getPlayerAngles();
            forward = anglesToForward(angles);
            start = self getEye();
            end = start + (forward * 10000);
            trace = BulletTrace(start, end, true, self);
            
            if(isDefined(trace["position"]))
            {
                pos = trace["position"] + (trace["normal"] * 10);
                RadiusDamage(pos, 150, 200, 50, self);
                PlayFX(level._effect["claymore_explode"], pos);
                self PlaySound("claymore_activated");
            }
        }
    }
}
