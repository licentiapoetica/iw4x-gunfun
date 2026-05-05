#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

loadStreaks()
{
    precacheShader("cardicon_helmet_brit_ww2");
    precacheShader("cardicon_boot");
    precacheShader("cardicon_headshot");
    precacheShader("cardicon_ghost_mic");
    precacheShader("cardicon_biohazard");
    precacheShader("cardicon_juggernaut_2");
    precacheShader("cardicon_paratrooper");
    precacheShader("cardicon_xray");
    precacheShader("dpad_killstreak_sentry");
    precacheShader("cardicon_b2");
    precacheShader("cardicon_fmj");
    precacheShader("cardicon_thebomb");
    precacheShader("cardicon_cod4");
	precacheShader("cardicon_loadedfinger");

    level.streaks3 = [];
    level.streaks6 = [];
    level.streaks9 = [];
	// add
	// - no reload
	// - radioactive

    level.streaks3[level.streaks3.size] = "No Recoil";
    level.streaks3[level.streaks3.size] = "Riotshield";
    level.streaks3[level.streaks3.size] = "Speed";
	level.streaks3[level.streaks3.size] = "No Reload";

    level.streaks6[level.streaks6.size] = "Suicide Bomber";
    level.streaks6[level.streaks6.size] = "I.M.S";
    level.streaks6[level.streaks6.size] = "Explosive Bullets";
	level.streaks6[level.streaks6.size] = "Radioactive";

    level.streaks9[level.streaks9.size] = "Juggernaut";
    level.streaks9[level.streaks9.size] = "Jetpack";
    level.streaks9[level.streaks9.size] = "XRay";
}
getStreak(which)
{
    switch(which)
    {
        case 0:
			invalid = true;
			streak = undefined;
			while(invalid)
			{
				streak = level.streaks3[randomInt(level.streaks3.size)];
				if(!self.isJugger)
					invalid = false;
				else if(streak != "Speed") 
					invalid = false;
			}
            return streak;
        case 1:
           return level.streaks6[randomInt(level.streaks6.size)];  
        case 2:
           return level.streaks9[randomInt(level.streaks9.size)];  
        default:
            break;   
    }
}
getStreakIcon(streak)
{
	if(streak == "Riotshield")
		return "cardicon_helmet_brit_ww2";
	if(streak == "Speed")
		return "cardicon_boot";
	if(streak == "No Recoil")	
		return "cardicon_headshot";
	if(streak == "Suicide Bomber")	
		return "cardicon_ghost_mic";
	if(streak == "Radioactive")	
		return "cardicon_biohazard"; //cardicon_hazard
	if(streak == "Juggernaut")	
		return "cardicon_juggernaut_2";
	if(streak == "Jetpack")	
		return "cardicon_paratrooper";
	if(streak == "XRay")	
		return "cardicon_xray";	
	if(streak == "Gl Sentry")	
		return "dpad_killstreak_sentry";
		//return tableLookup( "mp/killstreakTable.csv", 1, "sentry", 14 );
	if(streak == "Bomber")	
		return "cardicon_b2";	
	if(streak == "Explosive Bullets")
		return "cardicon_fmj";
	if(streak == "I.M.S")
		return "cardicon_thebomb";	
	if(streak == "Godmode")
		return "cardicon_chicken";
	if(streak == "No Reload")
		return "cardicon_loadedfinger";	
	return "cardicon_cod4";
}
setStreaks()
{
    if(!getDvarInt("streaks_online"))
        return;

    self.streaks[0] = getStreak(0);
	self.streaks[1] = getStreak(1);
	self.streaks[2] = getStreak(2);

    self thread drawStreaks();
    self thread onKilling();
}
drawStreaks()
{
	if(isDefined(self.streakIcons[0]))
	{
		for(i=0;i<3;i++)
		{
			self.streakIcons[i] destroy();		    
		} 
		self.streakText destroy();
	}  
	self.streakIcons = [];
	for(index = 0;index < 3;index++)
	{
		self.streakIcons[index] = self createFontString( "objective", 2 );
        self.streakIcons[index].foreground = false;
        self.streakIcons[index].hideWhenInMenu = true;
        self.streakIcons[index].fontScale = 1;
        self.streakIcons[index].font = "hudbig";
        self.streakIcons[index].alpha = 1;
        self.streakIcons[index].glow = 1;
        self.streakIcons[index].glowColor = ( 0, 0, 1 );
        self.streakIcons[index].glowAlpha = 1;
        self.streakIcons[index].color = ( 1.0, 1.0, 1.0 );
		self.streakIcons[index] setPoint("RIGHT", "RIGHT", 0, 0-(index *45));
        self.streakIcons[index] setShader(getStreakIcon(self.streaks[index]), 40, 40 );
	}
	self.streakText = self createFontString( "objective", 2 );
    self.streakText.foreground = false;
    self.streakText.hideWhenInMenu = true;
    self.streakText.fontScale = 1;
    self.streakText.font = "hudbig";
    self.streakText.alpha = 1;
    self.streakText.glow = .3;
    self.streakText.glowColor = ( 1, 0, 0 );
    self.streakText.glowAlpha = 1;
    self.streakText.color = ( 1.0, 1.0, 0.0 );
	self.streakText setPoint("RIGHT", "RIGHT", -50, 0);
}
onKilling()
{
    self endon("death");
    self endon("disconnect");
    level endon("nuke"); 
	spree = 0;
	value = 3;
	counter = 1;
	self.streakText setValue(value);
    while(true)
    {
        kills = self.kills;
		wait .1;
		if(kills != self.kills)
		{
			for(i = kills;i < self.kills;i++)
			{
				spree++;
				value--;				
				if(spree == 3 || spree == 6 || spree == 9)
				{
					streak = self giveReward(spree);
					self thread doStreakPopup(spree,streak);
					if(spree == 9)
						spree = 0;
				}
				if(value == 0)
				{
					value = 3;
					if(counter < 3)
					{
						y = self.streakText.y - 45;
						self.streakText setPoint("RIGHT", "RIGHT", -50, y);						
						counter++;
					}
					else
					{
						self.streakText setPoint("RIGHT", "RIGHT", -50, 100);
						counter = 1;
						self.streaks[0] = getStreak(0);
						self.streaks[1] = getStreak(1);
						self.streaks[2] = getStreak(2);
						self thread drawStreaks();
					}
				}
				self.streakText setValue(value);				
			}
        }    
    }
}
doStreakPopup(spree, streak)
{
	notifyHello = spawnstruct();
	notifyHello.glowColor = (0.0, 0.6, 0.3);
	notifyHello.titleText = spree + " Streak";
	notifyHello.notifyText = streak;	
	notifyHello.iconName = getStreakIcon(streak);	
	notifyHello.hideWhenInMenu = true;
	notifyHello.sound = "mp_level_up"; 
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyHello );
}
giveReward(spree)
{
	streak = "";
	if(spree == 3)
		streak = self.streaks[0];
	else if(spree == 6)
		streak = self.streaks[1];
	else if(spree == 9)
		streak = self.streaks[2];	
	self thread giveStreak(streak);
	return streak;	
}
giveStreak(streak)
{
    switch(streak)
    {
        case "No Recoil":
            self player_recoilScaleOn(0);
            break;
        case "Speed":
            self.speed = true;
            wait 1;
            self maps\mp\perks\_perks::givePerk("specialty_lightweight");
            self maps\mp\perks\_perks::givePerk("specialty_lightweight");
            self setMoveSpeedScale(1.6);
            self.setMoveSpeedScale = 1.6;
            //self thread spawnFireLoop();
            break;   
        case "Riotshield":
            self AttachShieldModel( "weapon_riot_shield_mp", "tag_shield_back" );
            break; 
        case "Jetpack":
            self thread Jetpack();
            break; 
        case "Suicide Bomber":
			self thread Suicidebomber();
            break; 
        case "I.M.S":
            self thread tryUseIMS();
			self thread infoText("I.M.S");
            break; 
        case "Juggernaut":
			self thread Juggernaut();
            break; 
        case "XRay":
            self thread Wh();
            break; 
        case "Explosive Bullets":
            self thread Explosive();
            break;   
		case "No Reload":
			self thread NoReload();
		case "Radioactive":
			self thread Radioactive();
			break;      
        default:
            self iPrintlnBold("^1ERROR: Unknown Streak!");
            break;    
    }
}
Radioactive()
{
	self endon("disconnect");
	self endon("death");
	level endon("nuke");
	playFxOnTag( level.spawnGlow["enemy"], self, "pelvis" ); 
	playFxOnTag( level.spawnGlow["friendly"], self, "j_head" );
	//self SetPlayerIgnoreRadiusDamage( true );
	while(1)
	{
		wait .1;
		//self RadiusDamage(self.origin,120,50,40,self,"MOD_Explosive","nuke_mp");
		//RadiusDamage(self.origin, 50, 30, 20, self );
		foreach(player in level.players)
		{
			if(player == self)
				continue;
			if(getDvar("g_gametype") == "gungame_team")
			{
				if(player.team == self.team)
					continue;
			} 
			if(Distance(player.origin,self.origin) < 120 && isAlive(player))
			{
				player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper( self, self, 4, 0, "MOD_EXPLOSIVE", "none", player.origin, player.origin, "none", 0, 0 );
				self thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback("");
			}
		}		
	}	
}
Suicidebomber()
{
	self endon("disconnect");
	self waittill("death");
	Earthquake( 0.4, 0.75, self.origin, 512 );
	MagicBullet("ac130_105mm_mp", self.origin+(0,0,20), self.origin, self);
}
Explosive()
{
    self endon("disconnect");
	self endon("death");
	self notify("exploagain");
	self endon("exploagain");
	self.explodmg = 40;
	self.explomindmg = 20;
	self.explotime = .1;
	for(;;)
	{
	    self waittill("weapon_fired");
		class = WeaponClass(self getCurrentWeapon());
		self setClassTime(class);
		forward = self getTagOrigin("j_head");
        end = self thread vector_scal(anglestoforward(self getPlayerAngles()),1000000);
        Location = BulletTrace( forward, end, 0, self )[ "position" ];
		playFx(level.explosionfx, Location); 	
		RadiusDamage(Location, 50, 30, 20, self );
		//self RadiusDamage(Location,250,self.explodmg,self.explomindmg,self,"MOD_Explosive","barrel_mp");
		wait self.explotime;
	}
}
Jetpack()
{
    self endon("death");
	self endon("disconnect");
	self notify("jetpack");
	self endon("jetpack");
	self iPrintlnBold("^3Press ^1F ^7to use ^:Jetpack!");
    self.jetpack = 80;
    self maps\mp\perks\_perks::givePerk("specialty_falldamage");
	self.fx = [];
    self.fx[0] = loadfx ("smoke/smoke_trail_white_heli");
    self.fx[1] = loadfx( "misc/flares_cobra" );     
    JETPACKBACK = createPrimaryProgressBar( -275 );
    JETPACKBACK.bar.x = 40;
    JETPACKBACK.x = 100;
    JETPACKTXT = createPrimaryProgressBarText( -275 );
    JETPACKTXT.x=100;
	if(randomInt(10) < 8)
        JETPACKTXT settext("^:Jetpack");
	else
	{
	    JETPACKTXT settext("^:Big Jetpack");
		self.jetpack = 120;
	}	    
    self thread dod(JETPACKBACK.bar,JETPACKBACK,JETPACKTXT);
    self attach("projectile_hellfire_missile","tag_stowed_back");
    while(true)
    {
        if(self usebuttonpressed() && self.jetpack>0)
        {
            //self playsound("veh_ac130_sonic_boom");
            //self playsound("veh_mig29_sonic_boom");
			self playsound("cobra_helicopter_dying_loop");
            self setstance("crouch");
            playfx(self.fx[0],self gettagorigin("j_spine4"));
			playfx(self.fx[1],self gettagorigin("j_spine4"));
            earthquake(.15,.2,self gettagorigin("j_spine4"),50);
            self.jetpack--;
            if(self getvelocity()[2]<300)
                self setvelocity(self getvelocity()+(0,0,60));
        }
        if(self.jetpack < 80 &&!self usebuttonpressed())
            self.jetpack++;
        JETPACKBACK updateBar(self.jetpack/80);
        JETPACKBACK.bar.color=(1,self.jetpack/80,self.jetpack/80);
        wait .05;
    }
}
dod(a,b,c)
{
    self waittill_any("death", "disconnect", "jetpack");
    a destroy();
    b destroy();
    c destroy();
}
tryUseIMS()
{
    self notify("ims2");
	self endon("ims2");
	self endon("disconnect");
	self notifyonplayercommand("IMS", "+actionslot 4");
	self waittill("IMS");
	ims = spawn("script_model", self.origin);
    ims setModel( "sentry_minigun_folded" );
    ims.angles = (90,0,0);	
	ims.imsbombs = 3;	
	block = spawn("script_model", self.origin+(-40,0,0));
	block setModel("com_plasticcase_enemy");
	block.angles = (0,0,0);
	block Solid();	
	block2 = spawn("script_model", self.origin+(40,0,0));
	block2 setModel("com_plasticcase_enemy");
	block2.angles = (0,0,0);
	block2 Solid();	
	block3 = spawn("script_model", self.origin+(0,40,0));
	block3 setModel("com_plasticcase_enemy");
	block3.angles = (0,90,0);
	block3 Solid();
	block4 = spawn("script_model", self.origin+(0,-40,0));
	block4 setModel("com_plasticcase_enemy");
	block4.angles = (0,90,0);
	block4 Solid();	
	self thread BombThem(ims);
	self thread DeleteIt(block, block2, block3, block4);
	self thread DeleteIMS(ims);
	self thread DeleteIMS2(ims);
	
}

DeleteIMS(ims)
{
    self waittill_any("death", "disconnect", "Ims_Dead");
	ims delete();
}

DeleteIMS2(ims)
{
    level waittill("fuckemp");
	ims delete();
}

DeleteIt(block, block2, block3, block4)
{
    self waittill_any("disconnect", "Ims_Dead");
	
	block delete();
	block2 delete();
	block3 delete();
	block4 delete();
}
BombThem(ims)
{
    //self endon("death");
	self endon("disconnect");
	self endon("Ims_Dead");
	expos = self.origin;
	wait 4;
	self iPrintln("I.M.S ready!");
	for(;;)
	{
	    foreach(player in level.players)
		{
		    if(player != self)
			{
			    if(Distance(expos, player.origin) <= 300)
				{
				    if(ims.imsbombs > 0)
					{
					    ims.imsbombs--;
				        self thread Boom(player, expos);
						if(ims.imsbombs == 0)
						    self notify("Ims_Dead");
						wait 5;
					}					
				}
				
			}
		}
		wait 1;
	}	
}
Boom(player, expos)
{
    player playsound ("claymore_activated");
	level._effect["bombexplosion"] = loadfx("explosions/tanker_explosion");
	PlayFx( level._effect["bombexplosion"], expos );
	//RadiusDamage(self.origin,350,500,100,level);
	MagicBullet("ac130_105mm_mp", expos, expos+(0,-100,-1000), self); 
	MagicBullet("ac130_105mm_mp", expos, expos+(100,0, -10), self); 
	MagicBullet("ac130_105mm_mp", expos, expos+(0,100, -10), self);
	MagicBullet("ac130_105mm_mp", expos, expos+(-100,0, -10), self);
	MagicBullet("ac130_105mm_mp", expos, expos+(0,-100, -10), self);
	PlayRumbleOnPosition( "grenade_rumble", self.origin );
	earthquake( 0.4, 0.75, self.origin, 512 );
	player playsound("exp_suitcase_bomb_main");	
}
vector_scal(vec, scale)
{
    vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
    return vec;
}
setClassTime(class)
{
    if(class == "rifle")
	{
	    self.explodmg = 20;
	    self.explotime = 0;
		self.explomindmg = 1;
	}
	else if(class == "smg")
	{
	    self.explodmg = 20;
	    self.explotime = 0;
		self.explomindmg = 1;
	}
	else if(class == "spread")
	{
	    self.explodmg = 30;
	    self.explotime = .5;
		self.explomindmg = 10;
	}
	else //pistol
	{
	    self.explodmg = 40;
	    self.explotime = 1;
		self.explomindmg = 15;
	}
}

Wh()
{
	// cheat invert vision, marks near enemies
	self endon("death");
	self endon("disconnect");
	self notifyOnPlayerCommand("3","+actionslot 3");
	hud = self createText("Press [{+actionslot 3}] to use recon vision", 1.5, "CENTER", "BOTTOM", 0,-80,"default");
	hud.glowcolor = (0,.7,0);
	self thread destroyGhostHud(hud);
	while(true)
	{
		self waittill("3");
		self visionSetNakedForplayer("cheat_invert", 2);
		hud.label = &"Countdown: ";
		self.recon = true;
		self thread scanPlayer();
		for(i = 10;i > 0;i--)
		{
			hud setValue(i);
			wait 1;
		}
		self visionSetNakedForplayer(getDvar("mapname"), 2);
		self.recon = false;
		hud fadeOverTime(1);
		hud.alpha = 0;
		wait 20;
		hud.label = &"";
		hud setText("Press [{+actionslot 3}]  to use recon vision");
		hud fadeOverTime(1);
		hud.alpha = 1;
	}
}

destroyGhostHud(hud)
{
	self endon("disconnect");
	//self endon("ghostCounter_done");
	self waittill_any("death", "spawned_player");
	hud destroy();
}
scanPlayer()
{
	//self endon("disconnect");
	//self endon("death");
	//self endon("ghostCounter_done");
	self.scanPlayer = [];
	while(self.recon)
	{
		foreach(player in level.players)
		{
			if(player == self)
				continue;
			if((getDvar("g_gametype") == "gungame_team") && self.team == player.team)
				continue;	
			if(Distance(player.origin,self.origin) <= 1000)
			{
				go = true;
				foreach(scan in self.scanPlayer)
				{
					if(scan == "" + player.guid)
						go = false;					
				}
				if(go)
				{
					self thread createScanImage(player);
					self.scanPlayer[self.scanPlayer.size] = "" + player.guid;
				}				
			}
		}
		wait .5;
	}
	self notify("ghostCounter_done");
}
createText(text,size,align,pos,x,y,font)
{
	if(!isDefined(font))
		hud = self createFontString("default",size);
	else
		hud = self createFontString(font,size);
	hud setPoint(align,pos,x,y);
	if(isDefined(text))
		hud setText(text);
	hud.glowAlpha = 1;
	hud.hideWhenInMenu = true;
	return hud;
}
createScanImage(player)
{
	//self endon("disconnect");
	
	rectpos = spawn("script_model", player getTagOrigin("j_head")+(0,0,-20));
	rectpos enableLinkTo();
	rectpos linkTo(player);
	
	icon = NewClientHudElem(self);
	icon.elemType = "bar";
	icon.width = 64;
	icon.height = 80;
    icon SetShader( "cardicon_headshot", 40, 40 );
	icon.color = (1,0,0);
    icon.alpha = 0;
	icon.x = rectpos.origin[ 0 ];
    icon.y = rectpos.origin[ 1 ];
    icon.z = rectpos.origin[ 2 ];
	icon SetTargetEnt(rectpos);
	icon SetWayPoint( true, true );
	icon fadeovertime(1);
	icon.alpha = 1;
	self waittill_any("disconnect","ghostCounter_done");
	icon fadeovertime(2);
	icon.alpha = 0;
	wait 2;
	rectpos delete();
	icon destroy();
}

Wh_Old()
{
	self endon("death");
	self endon("disconnect");
	self notify("wh");
	self endon("wh");
	self ThermalVisionFOFOverlayOn();
	for(i = 30;i > 0;i--)
	{
		wait 1;
		self iPrintln("Infrared Vision for: " + i);
	}
	self ThermalVisionFOFOverlayOff();
}
///////////////////////////////////////////////////////////
infoText(item)
{
	infotext = self createFontString("hudsmall", 1);
	infotext  setPoint("CENTER", "CENTER", 0, -50);
	infotext.color = (1,1,0); 
	infotext.glowalpha = .5; 
	infotext.glowcolor = (1,0,0); 		
	infotext setText("Press [{+actionslot 4}] to use " + item);
	//infoText fadeOverTime(2);
	//infoText.alpha = 0;
	wait 2;
	if(isDefined(infoText))
		infoText destroy();
}
Juggernaut()
{
	level endon("nuke");
	self.isJugger = true;
	self.maxhealth = 400;
	self.health = self.maxhealth; 
	self setMoveSpeedScale(.7);

	juggIcon = newHudElem();
	juggIcon.x = self.origin[0];
	juggIcon.y = self.origin[1];
	juggIcon.z = self.origin[2] + 54;
	juggIcon.alpha = .8;
	juggIcon.archived = true;
	juggIcon setShader("cardicon_juggernaut_2");
	juggIcon SetWayPoint( true, true );
    juggIcon SetTargetEnt(self);
	self thread destroyJuggOnNuke(juggIcon);
	self waittill_any("death", "disconnect", "isMarked");
	juggicon destroy();
}
destroyJuggOnNuke(juggIcon)
{
	self endon("death");
	self endon("disconnect");
	level waittill("nuke");
	juggIcon destroy();
}
NoReload()
{
	self endon("death");
	self endon("disconnect");
	while(true)
	{
		if(self AttackButtonPressed())
		{
			current = self getCurrentWeapon();
			clip = self GetWeaponAmmoClip(current);
			stock = self GetWeaponAmmoStock(current);
			if(stock > 0)
			{
				self setWeaponAmmoStock(current, stock-1);
				self setWeaponAmmoClip(current, clip+1);
			}
			waitFrame();
		}
		else
		   self waittill("weapon_fired");
	}
}