#include common_scripts\utility; 
#include maps\mp\_utility; 
#include maps\mp\gametypes\_hud_util;

/////////////////////
//
// Gamemode: Fungame (only mode)
//

Init()
{
    level._effect["claymore_explode"] = loadfx("explosions/tanker_explosion");
    loadSettings();
    thread mod\weapons::loadWeapons();
    thread mod\streaks::loadStreaks();
    thread onPlayerConnect();
    thread deleteSentries();
    thread launchGame();
}
initializeGametype()
{
    setDvar("gunmode", "Fungame");
    setDvar("g_gametype", "gungame");
    setDvar("gun_kills", 1);
    setDvar("global_health", 60);
    setDvar("speed", 1.5);
    setDvar("streaks_online", 1);
    setDvar("jump_height", 70);
    setDvar("amount_weapons", 40); // 0 = full 162-weapon progression
    setDvar("shuffle_weapons", 0); // weapons play in fixed order
}
loadSettings()
{
    /////////////////////// CUSTOM SETTINGS /////////////////////////////
    initializeGametype();

    setDvar("intermission", 15);
    setDvar("sv_customstats", 0);
    SetDvarIfUninitialized("show_damage_ui", 1);
    setDvar("gunversion", "");
    /////////////////////////////////////////////////////////////////////
    setDvar("scr_gungame_timelimit", 0);
	setDvar("scr_gungame_scorelimit", 0);
	setDvar("ui_allow_teamchange", 0); 
    setDvar("scr_game_allowkillcam", 1); // needed for final killcam
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
    setDvar("bg_shock_movement_duration", 0);
    setDvar("bg_shock_movement_magnitude", 0);
    setDvar("bg_shock_lookControl", 0);
    setDvar("bg_shock_lookControl_duration", 0);
    setDvar("bg_shock_screenBlurBlendTime", 0);
    setDvar("bg_shock_screenBlurBlendFadeTime", 0);
    setDvar("player_sprintUnlimited", 1);   // Marathon: unlimited sprint

    level.state = "prematch";
    level.markerIcon = "ui_host";
    precacheShader(level.markerIcon);
    precacheShader("line_horizontal");
    precacheShader("white");
    
    // Bot Management
    setDvar("bots_main", 1);
    setDvar("bots_manage_fill", 10);         // total slots: players + bots = 10
    setDvar("bots_manage_fill_mode", 0);     // mode 0 = count players AND bots
    setDvar("bots_manage_fill_kick", 1);     // kick a bot when a human pushes count over 10
    setDvar("bots_skill", 8);
    setDvar("bots_skill_allies_hard", 1);
    setDvar("bots_skill_allies_med", 0);
    setDvar("bots_skill_axis_hard", 1);
    setDvar("bots_skill_axis_med", 0);
    setDvar("bots_play_knife", 0);
    setDvar("bots_main_chat", 0);
    // Suppress engine-level developer prints.
    setDvar("developer", 0);
}
deleteSentries()
{
    turret = GetEntArray("misc_turret","classname");   
	for(i=0;i<turret.size;i++) 	   
	    turret[i] delete(); 
}
launchGame()
{
    // Wait for gametype to initialize _hud_util globals (level.fontHeight, level.uiParent).
    // launchGame runs from Init() which fires before the gametype callback.
    while(!isDefined(level.fontHeight) || !isDefined(level.uiParent))
        waitFrame();
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
        // Use the mode-configured speed dvar, not a hardcoded value.
        // Fungame = 1.5, Classic = 1.2, etc. — 1.25 was always wrong for Fungame.
        player setMoveSpeedScale(getDvarFloat("speed"));
    }
       
    setDvar("jump_height", 60);
    hud destroy();
    value destroy();
    //player freezeControls(false);
}
onPlayerConnect()
{
    level endon("game_over");
    while(true)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}
onPlayerSpawned()
{
    level endon("game_over");
    self endon("disconnect");
    self thread firstSpawn();
    while(true)
    {
        self waittill("spawned_player");
        self thread loadSetup();
    }
}
firstSpawn()
{
    self endon("disconnect");
    self.current = 1;
    self.firstSpawn = true;
    self.knifeKills = 0;
    self.gungameKills = 0;
    self.isJugger = false;
    self.streaks = [];
    self.pers["lastEarnedStreak"] = ""; // prevent bot chat crash on undefined comparison
    self.pers["team"] = "allies";
    self.team = "allies";

    // Join team + select class IMMEDIATELY — must happen before any waits
    // so the engine has a valid class when it auto-spawns mid-game joiners.
    self notify("menuresponse", game["menu_team"], "allies");
    wait .05;
    self notify("menuresponse", "changeclass", "class1");
    wait .05;

    self setClientDvar("cg_drawSplatter", 0); 
    self setClientDvar("cg_drawDamageFlash", 0);
    self setClientDvar("cg_viewkickscale", 0.1);
    self setClientDvar("bg_viewKickScale", 0.1);
    self setClientDvar("bg_shock_lookControl_mousesensitivityscale", 1);
    self setClientDvar("bg_shock_movement", 0);
    self setClientDvar("bg_shock_lookControl", 0);

	if(isDefined(self.hud_damagefeedback))
		self.hud_damagefeedback.color = (1,0,0); 
    self.line = self createRectangle("CENTER", "LEFT", 0,-90,300,5,(1,1,0),"line_horizontal",1);
    // Subtle crosshair dot — light blue, low alpha
    self.crosshair = self createRectangle("CENTER", "CENTER", 0, 0, 3, 3, (0.5, 0.85, 1.0), "white", 1);
    self.crosshair.alpha = 0.4;
    self.crosshair.hideWhenInMenu = true;

    self thread onKilling();
    self thread createUI();
    self thread refillOnFire();
    self thread watchVersion();
    self thread FPSBoost(); 
    for(i=1;i<3;i++)	 
	    self setClientDvar("lowAmmoWarningNoAmmoColor" + i, 0, 0, 0, 0); 

    // Re-apply perks — the engine's class-load can wipe perk state.
    self maps\mp\perks\_perks::givePerk("specialty_fastreload");
    self maps\mp\perks\_perks::givePerk("specialty_falldamage");
    self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
    self maps\mp\perks\_perks::givePerk("specialty_lightweight");
    self maps\mp\perks\_perks::givePerk("specialty_marathon");
    self maps\mp\perks\_perks::givePerk("specialty_fastmantle");
    self setPlayerData("challengeState", "ch_marathon_pro", 2);
    self.firstSpawn = false;
    self thread tryCreateMarkerIcons();
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
    // watchHealthHUD removed — HP display not wanted
    self thread watchRegen();
    self thread watchDeagleGL();
    self thread watchM40A3();
    self thread watchHUD();
    self.streaking = 0;
    self.speed = false;
    self.isJugger = false;
    self.moveSpeedScaler = getDvarFloat("speed"); 
	self setMoveSpeedScale(getDvarFloat("speed")); 
    self thread enforceSpeed(); // override any engine speed penalty every frame
    self maps\mp\perks\_perks::givePerk("specialty_fastreload"); // due to icys request :)
    self maps\mp\perks\_perks::givePerk("specialty_falldamage"); // due to icys request :)
    self maps\mp\perks\_perks::givePerk("specialty_quickdraw");
    self maps\mp\perks\_perks::givePerk("specialty_lightweight");
    self maps\mp\perks\_perks::givePerk("specialty_marathon");
    self maps\mp\perks\_perks::givePerk("specialty_fastmantle");  // Marathon Pro: faster mantle
    self setPlayerData("challengeState", "ch_marathon_pro", 2);   // unlock Marathon Pro
    // Static HUD dvars set once per spawn.
    // g_hardcore=1 handles minimap/radar/teamscore suppression at engine level.
    // We only need to override what we want TO show (ammo, custom health HUD).
    self setClientDvar("cg_drawStance", 0);
    self setClientDvar("cg_drawKillfeed", 0);
    self setClientDvar("cg_drawBreathHint", 0);
    self setClientDvar("cg_drawMantleHint", 0);
    self setClientDvar("cg_drawTurretCrosshair", 0);
    self setClientDvar("cg_cursorHints", 0);
    self setClientDvar("ui_hud_hardcore", 0);     // show custom HUD elements despite g_hardcore
    // Re-apply shock suppression every spawn — engine can reset client dvars on respawn
    self setClientDvar("bg_shock_movement", 0);
    self setClientDvar("bg_shock_movement_duration", 0);
    self setClientDvar("bg_shock_movement_magnitude", 0);
    self setClientDvar("bg_shock_lookControl", 0);
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

updateWeapon()
{
    // Safety: end this thread if the match is over or the player is gone/dead.
    level endon("game_over");
    self endon("disconnect");
    self endon("death");
    // Exclusivity guard: notifying "updateWeapon" kills any previously running
    // instance of this function on this player, then we register to die the same
    // way when the NEXT call arrives. Only one updateWeapon thread per player.
    self notify("updateWeapon");
    self endon("updateWeapon");

    // Don't proceed until the weapon list is fully built
    if(!isDefined(level.weaponsLoaded) || !level.weaponsLoaded)
        return;
    if(self.current > (level.gungameList.size - 1))
    {
        self thread endMatch();
        return;
    }
    weaponName = level.gungameList[self.current];
    // Guard: skip if the weapon entry is missing, empty, or "none".
    if(!isDefined(weaponName) || weaponName == "none" || weaponName == "")
        return;
    variant = 0;
    self takeAllWeapons();
    if (isSubstr(weaponName, "_akimbo")) 
	    self giveWeapon(weaponName, variant, true); 
	else 		
	    self giveWeapon(weaponName, variant, false);
    // Verify the weapon was actually loaded — giveWeapon silently fails if
    // the weapon asset doesn't exist in the engine.
    if(!self hasWeapon(weaponName))
    {
        self.current++;
        return;
    }
    self giveWeapon("onemanarmy_mp");
    self takeWeapon("onemanarmy_mp");
    // Skip ammo operations for weapons with no ammo pool (riotshield, defaultweapon, etc.)
    // giveMaxAmmo on these causes "Weapon name none" engine errors.
    if(weaponName != "riotshield_mp" && weaponName != "defaultweapon_mp")
    {
        self giveMaxAmmo(weaponName);
        self setWeaponAmmoClip(weaponName, 9999);
    }
    waitFrame();
    self switchtoweaponimmediate(weaponName);
    waitFrame();
    if(weaponName != "riotshield_mp" && weaponName != "defaultweapon_mp")
        self setWeaponAmmoClip(weaponName, 9999);
    if(level.state == "prematch" || level.state == "ingame")
        self show();
    // Always restore the correct speed, clamped to the mode's configured base floor.
    // getBaseSpeed() ensures no path can silently drop below the dvar-configured minimum.
    if(level.state != "prematch")
    {
        if(self.speed)
            self setMoveSpeedScale(1.6); // Speed streak: above base, always fine
        else
            self setMoveSpeedScale(getBaseSpeed()); // Juggernaut and normal: always >= base speed
    }
    if(level.state ==  "prematch")
    {
        self setMoveSpeedScale(0);
        if(level.state == "prematch")
            self setMoveSpeedScale(0);
    }   

    if(isDefined(self.pers["isBot"]) && self.pers["isBot"])
    {
        if(level.gungameList[self.current] == "riotshield_mp")
        {
            self setClientDvar("bots_play_knife", 1);
            self thread watchBotRiotShield();
        }
        else
        {
            self setClientDvar("bots_play_knife", 0);
            self notify("botshield");
        }
    }
    // NOTE: The old recursive self-call "self updateWeapon()" was removed here.
    // It caused unbounded call-stack growth when getCurrentWeapon() returned "none".
    // takeInvalidWeapon() polls every frame and will re-issue the thread if needed.

    // Bounded retry: the engine may need a few frames after switchtoweaponimmediate
    // to register the active weapon. Loop up to 8 frames re-issuing the switch.
    // This is the safe replacement for the old unbounded recursive call.
    retries = 0;
    while(self getCurrentWeapon() == "none" && !self isMantling() && !self isOnLadder() && retries < 8)
    {
        self switchtoweaponimmediate(level.gungameList[self.current]);
        waitFrame();
        retries++;
    }
}
refillOnFire()
{
    level endon("game_over");
    self endon("disconnect");
    while(true)
    {
        self waittill("weapon_fired");
        weapon = self getCurrentWeapon();
        if(weapon != "none" && weapon != "")
            self giveMaxAmmo(weapon);
    }
}
onKilling() {
	self endon("disconnect");
	level endon("game_over");
	self.multiplier = 0;
	self.amount = 0;
    kills = 0;
    refreshCounter = 0;
    // Cache settings that never change mid-match — eliminates getDvar()/getDvarInt()
    // native calls inside this loop which runs every 0.3s per player.
    killsPerWeapon = getDvarInt("gun_kills", 1);
	// Guard: only create HUDs if they don't already exist (prevents leak on reconnect)
	if(!isDefined(self.scoretext))
		self.scoretext = self createText("hudbig", 1, "CENTER", "CENTER", 0, 0, .7,"");
	if(!isDefined(self.scoretext_amount))
		self.scoretext_amount = self createText("hudbig", 1, "CENTER", "CENTER", -10, 20, .7,"");
	if(!isDefined(self.multitext) || !isDefined(self.multitext[2]))
	{
		self.multitext = [];
		for(i=2;i<6;i++)
		    self.multitext[i] = self createText("hudbig", .6, "CENTER", "CENTER", 50, (i * 20), .7,"");
	}
	while(true)
    {
        wait .3;
        if(kills > self.gungameKills) // not called on team gungame
        {
            self thread scorepopup(-100);
            kills--;
            refreshCounter++;
            if(killsPerWeapon > 1)
            {
                killsInGun = (self.gungameKills % killsPerWeapon);
                self.weaponhud setText("Gun: " + self.current + " / " + (level.gungameList.size - 1));
                self.killhud setValue(killsInGun);
                self.killhud.alpha = 1;
                self.killtotalhud.alpha = 1;
            }
            else
            {
                self.weaponhud setText("Gun: " + self.current + " / " + (level.gungameList.size - 1));
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
            // Always upgrade weapon on kill (Fungame mode)
            if(killsPerWeapon > 1)
            {
                if(self.gungameKills % killsPerWeapon == 0)
                {
                    self.current++;
                    self thread updateWeapon();
                }
                killsInGun = (self.gungameKills % killsPerWeapon);
                self.weaponhud setText("Gun: " + self.current + " / " + (level.gungameList.size - 1));
                self.killhud setValue(killsInGun);
            }
            else
            {
                self.current++;
                self thread updateWeapon();
                self.weaponhud setText("Gun: " + self.current + " / " + (level.gungameList.size - 1));
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
        if(isDefined(self.weapontotalhud))
            self.weapontotalhud destroy();
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
	text = self createFontString(font,fontScale); 
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
    self.scoretext setText("Killed!^3");
	self.scoretext_amount.color = color; 
	self.scoretext_amount.glowColor = glowColor;
 	self.scoretext_amount SetPulseFX( 40, 2000, 600 );
 	// FIX: Use .label + setValue() instead of setText("+" + amount).
 	// Each unique amount string burned a permanent configstring slot.
 	self.scoretext_amount.label = &"+";
 	self.scoretext_amount setValue(self.amount); 	
	// Clamp multitext index to the valid range [2..5] to prevent undefined access
	mtIdx = self.multiplier;
	if(mtIdx > 5) mtIdx = 5;
	if(self.multiplier > 1 && isDefined(self.multitext[mtIdx])) 	
	{ 	
        self.multitext[mtIdx].alpha = 1;  
        self.multitext[mtIdx] fadeOverTime(0.1);	 
        self.multitext[mtIdx].color = color; 		
        self.multitext[mtIdx].glowColor = glowColor; 	
	}	
	if(self.multiplier == 2) 
	{ 	 
        self thread lowerMultitext(self.multiplier); 	
        self.multitext[mtIdx] setText("Double Kill!"); 
	}	    			     
	else if(self.multiplier == 3) 	
        self.multitext[mtIdx] setText("Triple Kill!");	
 	else if(self.multiplier == 4) 	
        self.multitext[mtIdx] setText("Multi Kill!");		
 	else if(self.multiplier > 4) 	
	{ 	  
        difference = self.multiplier - 4; 	
        // FIX: Use .label + setValue() to avoid configstring leak per spree level.
        self.multitext[5].label = &"^1K^2i^3l^4l^5i^6n^7g ^1S^2p^3r^4e^5e ^3x";
        self.multitext[5] setValue(difference); 
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
        if(isDefined(self.multitext[i]))
        {
            self.multitext[i] fadeOverTime(3);	
            self.multitext[i].alpha = 0; 
        }
        wait .75; 
	} 
	wait 4; 
} 
endMatch()
{
    // Re-entry guard: only one endMatch can run
    if(isDefined(level.matchEnded) || level.state == "aftermatch")
        return;

    level.matchEnded = true;
    level.state = "aftermatch";

    level notify("game_over");
    foreach(player in level.players)
        player notify("game_over");

    self.weaponhud setText("Gun: " + (level.gungameList.size - 1));

    // Normal end game screen — _mv.gsc hooks endGame for mapvoting
    thread maps\mp\gametypes\_gamelogic::endGame( self, game["strings"]["score_limit_reached"] );
}
createUI()
{
    self thread createWeaponHud();
    self thread createKillHud();
    // Weaponnumber() removed — marked deprecated, waits on "update_weaponNumber"
    // which is never notified anywhere. Was a zombie thread per player.
    self thread createRatioHud();
}
createWeaponHud()
{
    self.weaponhud = self createFontString("hudsmall", 1.2);
    self.weaponhud setPoint("LEFT", "LEFT", 10, -105);
    self.weaponhud.glowalpha = .5;
    self.weaponhud.color = (1,1,0);
    self.weaponhud.hideWhenInMenu = true;
    self.weaponhud.glowcolor = (1,0,0);
    // setText() is safe here: max ~162 unique strings, configstrings are deduplicated.
    self.weaponhud setText("Gun: " + self.current + " / " + (level.gungameList.size - 1));

    // weapontotalhud kept defined but hidden — total is inline in weaponhud text
    self.weapontotalhud = self createFontString("hudsmall", 1.2);
    self.weapontotalhud.alpha = 0;
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
    self.ratiohud setPoint("LEFT", "LEFT", 10, -125);
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
// Returns the mode-configured base speed, clamped so nothing can go below it.
// All setMoveSpeedScale calls for non-prematch state should go through this
// (or compare against it) to honour the 1.5 Fungame / 1.2 Classic floor contract.
getBaseSpeed()
{
    base = getDvarFloat("speed");
    return base;
} 
enforceSpeed()
{
    // Calls setMoveSpeedScale every server frame — brute-forces over any engine
    // speed penalty (bullet pain, bg_shock, mantle exit, etc.) with no gaps.
    level endon("game_over");
    self endon("disconnect");
    self endon("death");
    while(true)
    {
        waitFrame();
        if(level.state != "ingame")
            continue;
        if(self.speed)
            self setMoveSpeedScale(1.6);
        else
            self setMoveSpeedScale(getBaseSpeed());
    }
}
takeInvalidWeapon()
{
    self endon("disconnect");
    self endon("death");
    level endon("game_over");
    // Skip the first 5 frames so the initial updateWeapon() from loadSetup() has
    // time to complete its switchtoweaponimmediate before we start polling.
    // This prevents a false-positive correction that was causing the 2.5s delay.
    for(i = 0; i < 5; i++)
        waitFrame();
    while(1)
    {
        wait 0.1; // 10/s is ample for a safety-net poller
        if(!isAlive(self))
            continue;
        if(self isMantling())
            continue;
        // Don't poll until weapons are fully loaded
        if(!isDefined(level.weaponsLoaded) || !level.weaponsLoaded)
            continue;
        weapon = self getCurrentWeapon();
        // Skip if player is in a weapon transition ("none" is normal during switches)
        if(weapon == "none" || weapon == "")
            continue;
        if(weapon != level.gungameList[self.current])
        {
            self takeAllWeapons();
            self thread updateWeapon();
            // Short cooldown — just enough for switchtoweaponimmediate to settle.
            wait 0.5;
        }
    }
}
takeInvalidWeapon2()
{
    self endon("disconnect");
    level endon("game_over");
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
    level endon("game_over");
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
    self waittill_any("disconnect", "game_over");
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
	hud.elemType = "icon";
	hud.width = width;
	hud.height = height;
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


FPSBoost() 
{  
    level endon("game_over");
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
    level endon("game_over");
    self endon("disconnect");
    self endon("death");
    
    if(isDefined(self.healthHUD))
        self.healthHUD destroy();
        
    self.healthHUD = self createFontString("hudsmall", 1.2);
    self.healthHUD setPoint("BOTTOM RIGHT", "BOTTOM RIGHT", -10, -10);
    self.healthHUD.label = &"HP: ";
    
    lastHealth = -1; // sentinel: forces first-tick update
    while(true)
    {
        // Only push to the HUD element when the value actually changed.
        // Eliminates 10 setValue() native calls/sec when player is at full health.
        if(self.actual_health != lastHealth)
        {
            lastHealth = self.actual_health;
            self.healthHUD setValue(self.actual_health);
            if(self.actual_health < (self.actual_maxhealth * 0.3))
                self.healthHUD.color = (1, 0, 0);
            else
                self.healthHUD.color = (1, 1, 1);
        }
        wait 0.1;
    }
}

watchRegen()
{
    level endon("game_over");
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
    level endon("game_over");
    self endon("disconnect");
    self endon("death"); // prevent thread accumulation across respawns
    while(true)
    {
        self waittill("weapon_fired", weaponName);
        if(weaponName == "deserteagle_akimbo_mp")
        {
            angles = self getPlayerAngles();
            forward = anglesToForward(angles);
            start = self getEye();
            end = start + (forward * 3000);
            MagicBullet("gl_mp", start, end, self);
            
            if(isDefined(self.pers["isBot"]) && self.pers["isBot"])
                wait .6;
            else
                wait .2;
        }
    }
}

watchHUD()
{
    level endon("game_over");
    self endon("disconnect");
    self endon("death"); // prevent thread accumulation across respawns
    while(true)
    {
        // Re-apply ammo visibility (engine may reset it on class/weapon events).
        self setClientDvar("cg_drawAmmo", 1);
        wait 5;
    }
}

watchM40A3()
{
    level endon("game_over");
    self endon("disconnect");
    self endon("death"); // prevent thread accumulation across respawns
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
                wait .1;
            }
        }
    }
}

// Scripted riot shield bash for bots.
// Bots cannot press the melee button to bash with the riot shield, so this thread
// checks proximity + forward arc every 0.8s and applies damage directly,
// matching the real shield bash range (~85 units) and cooldown (~0.8s).
watchBotRiotShield()
{
    level endon("game_over");
    self endon("death");
    self endon("disconnect");
    // Exclusivity guard: kill any previous instance when weapon changes re-trigger this.
    self notify("botshield");
    self endon("botshield");

    while(true)
    {
        wait 0.8; // ~length of real shield bash animation / cooldown

        if(self getCurrentWeapon() != "riotshield_mp")
            continue;

        selfPos = self getOrigin();
        forward = anglesToForward(self getPlayerAngles());

        foreach(player in level.players)
        {
            if(player == self) continue;
            if(!isAlive(player)) continue;

            toPlayer = player getOrigin() - selfPos;
            dist = Length(toPlayer);

            if(dist > 85) continue; // riot shield melee range

            // Dot product: check player is within ~75 degree forward arc.
            nx = toPlayer[0] / dist;
            ny = toPlayer[1] / dist;
            nz = toPlayer[2] / dist;
            dot = (forward[0] * nx) + (forward[1] * ny) + (forward[2] * nz);

            if(dot > 0.25) // 0.25 ~= 75 degree half-angle
            {
                // The mod pins engine health at 1000 and tracks real HP in actual_health.
                // finishPlayerDamageWrapper only hits engine health (which never changes),
                // so we apply damage directly to the scripted HP instead.
                bashDamage = 100;
                player.actual_health -= bashDamage;
                player notify("takeDamage"); // reset regen timer

                if(player.actual_health <= 0)
                {
                    player.actual_health = 0;
                    // Drive a lethal hit through the engine so the kill is attributed correctly.
                    player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper(
                        self, self, 1000, 0, "MOD_MELEE", "riotshield_mp",
                        player getOrigin(), player getOrigin(), "none", 0, 0
                    );
                }
                break; // one target per swing
            }
        }
    }
}
