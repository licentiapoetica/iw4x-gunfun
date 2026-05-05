#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

//	Callback Setup
//	This script provides the hooks from code into script for the gametype callback functions.

//=============================================================================
// Code Callback functions

/*================
Called by code after the level's main script function has run.
================*/
CodeCallback_StartGameType()
{
	if( getDvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

	// If the gametype has not beed started, run the startup
	if(!isDefined(level.gametypestarted) || !level.gametypestarted)
	{
		[[level.callbackStartGameType]]();

		level.gametypestarted = true; // so we know that the gametype has been started up
	}
}


/*================
Called when a player begins connecting to the server.
Called again for every map change or tournement restart.

Return undefined if the client should be allowed, otherwise return
a string with the reason for denial.

Otherwise, the client will be sent the current gamestate
and will eventually get to ClientBegin.

firstTime will be qtrue the very first time a client connects
to the server machine, but qfalse on map changes and tournement
restarts.
================*/
CodeCallback_PlayerConnect()
{
	if( getDvar( "r_reflectionProbeGenerate" ) == "1" )
		level waittill( "eternity" );

	self endon("disconnect");
	[[level.callbackPlayerConnect]]();
}

/*================
Called when a player drops from the server.
Will not be called between levels.
self is the player that is disconnecting.
================*/
CodeCallback_PlayerDisconnect()
{
	self notify("disconnect");
	[[level.callbackPlayerDisconnect]]();
}

/*================
Called when a player has taken damage.
self is the player that took damage.
================*/
CodeCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	self endon("disconnect");
	
	if(sWeapon == "model1887_mp")
	    iDamage += 30;
	if(sWeapon == "model1887_akimbo_mp")
	    iDamage += 25;	
	if(sWeapon == "cheytac_mp")
        iDamage += 40;	
	if(sWeapon == "barrett_mp")
        iDamage += 20;	
	if(sWeapon == "m40a3_mp")
	    iDamage += 20;
	
	if(sMeansOfDeath == "MOD_MELEE")
	{
		eAttacker.knifeKills++;
		if(eAttacker.knifeKills >= 5)	
			iDamage = 50;
	}
	if(level.state == "ingame" && getDvarInt("show_damage_ui") == 1){
		if(getDvar("g_gametype") == "gungame_team")
		{
			if(self.team == eAttacker.team)
			{
				[[level.callbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset); // tested?
				return;
			}
		}
		damagehud = eAttacker createDamageHud();
		damageHud setValue(iDamage);
		damageHud moveOverTime(1);
		damageHud.x -= 300;
		damageHud.y += (-1 * randomInt(150));
		damageHud fadeOverTime(1);
		damageHud.alpha = 0;
		eAttacker thread destroyDamageHud(damageHud);
		self thread updateDamageHud();
	}
	if(level.state != "ingame")
		iDamage = 0;
    [[level.callbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

updateDamageHud()
{
	wait .1;
	self notify("takeDamage");
}
createDamageHud()
{
	damageHud = createText(undefined,1.3,"CENTER", "CENTER", 0,-100);
	damageHud.glowColor = (.7,0,0);
	damageHud.x = 350;
	damageHud.y = 0;
	return damageHud;
}
destroyDamageHud(damageHud)
{
	wait 1;
	damageHud destroy();
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

/*================
Called when a player has been killed.
self is the player that was killed.
================*/
CodeCallback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self endon("disconnect");
	
	if(self == eAttacker || sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_FALLING")
	{
		if(self.score >= 100)	
			self.score -= 100;
		else
			self.score = 0;			
		if(self.current > 0)
			self.current--;	
		if(getDvar("g_gametype") != "gungame_team")		
			self.gungameKills--;	
		self thread mod\main::warning(3);
	}
	else if(sMeansOfDeath != "MOD_MELEE" || sWeapon == "riotshield_mp")
	{
		eAttacker playlocalsound("mp_enemy_obj_captured");	
		eAttacker notify("killed_enemy");
		eAttacker.score += 100;
		if(getDvar("g_gametype") != "gungame_team")
		{
			//iPrintlnBold(getDvar("gunmode"));
			if(getDvar("gunmode") != "Kill Confirmed")
			{
				if(sWeapon == "riotshield_mp" && getDvar("gunmode") == "Fungame")
					eAttacker.gungameKills += getDvarInt("gun_kills", 1);
				else
					eAttacker.gungameKills++;
			}
			else
				thread mod\main::spawnDogTag(self, eAttacker);	
		}		
		else if(eAttacker.team != self)
		{
			if(eAttacker.team == "allies")
			{
				level.teamKills["allies"]++;
				if(level.teamKills["allies"] >= getRequiredKills())
				{
					level.teamKills["allies"] = 0;
					level.teamKills["allies_weapon"]++;
					level notify("upgrade_allies");
					thread mod\main::upgradeTeamUI("allies");
					thread mod\main::upgradeEnemyWeaponUI("axis");
				}
			}	
			else	
			{
				level.teamKills["axis"]++;
				if(level.teamKills["axis"] >= eAttacker getRequiredKills())
				{
					level.teamKills["axis"] = 0;
					level.teamKills["axis_weapon"]++;
					level notify("upgrade_axis");
					thread mod\main::upgradeTeamUI("axis");
					thread mod\main::upgradeEnemyWeaponUI("allies");
				}
			}
			eAttacker thread mod\main::scorepopup(100);
            eAttacker.streaking++; 					
		}	
	}
	else{
		eAttacker.score += 100;
	}
	self notify("killed_lethal"); 
	[[level.callbackPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
}
getRequiredKills()
{
	allies = 0;
	axis = 0;
	foreach(player in level.players)
	{
		if(player.team == "allies")
			allies++;
		else if(player.team == "axis")
			axis++;	
	}
	if(self.team == "allies")
		return allies;
	else if(self.team == "axis")
		return axis;
	return 9999;		
}

getRequiredKillsOld()
{
	if(level.players.size < 4)
		return 2;
	if(level.players.size < 6)
		return 3;
	if(level.players.size < 10)
		return 4;
	if(level.players.size < 15)
		return 5;			
	return 6;	
}

/*================
Called when a vehicle has taken damage.
self is the vehicle that took damage.
================*/
CodeCallback_VehicleDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName )
{
	if ( isDefined( self.damageCallback ) )
		self [[self.damageCallback]]( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
	else
		self Vehicle_FinishDamage( inflictor, attacker, damage, dFlags, meansOfDeath, weapon, point, dir, hitLoc, timeOffset, modelIndex, partName );
}


/*================
Called when code is forcibly ending the game.
e.g. we suck as host.
================*/
CodeCallback_CodeEndGame()
{
	self endon("disconnect");
	[[level.callbackCodeEndGame]]();
}


/*================
Called when a player has been killed, but has last stand perk.
self is the player that was killed.
================*/
CodeCallback_PlayerLastStand(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	self endon("disconnect");
	[[level.callbackPlayerLastStand]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
}


/*================
Called when a player reconnects to the server
following a host migration.
================*/
CodeCallback_PlayerMigrated()
{
	self endon("disconnect");
	[[level.callbackPlayerMigrated]]();
}


/*================
Called once when a host migration has occured.
================*/
CodeCallback_HostMigration()
{
	[[level.callbackHostMigration]]();
}



//=============================================================================

// Damage flags used in the playerDamage callback
SetupDamageFlags()
{
	// code-defined:
	level.iDFLAGS_RADIUS						= 1;	// damage was indirect
	level.iDFLAGS_NO_ARMOR						= 2;	// armor does not protect from this damage
	level.iDFLAGS_NO_KNOCKBACK					= 4;	// do not affect velocity, just view angles
	level.iDFLAGS_PENETRATION					= 8;	// damage occurred after one or more penetrations
	level.iDFLAGS_STUN							= 16;	// non-lethal
	level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT		= 32;	// missile impacted on the front of the victim's shield
	level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT_HUGE	= 64;	//   ...and was from a projectile with "Big Explosion" checked on.
	level.iDFLAGS_SHIELD_EXPLOSIVE_SPLASH		= 128;	// explosive splash, somewhat deflected by the victim's shield

	// script-defined:
	level.iDFLAGS_NO_TEAM_PROTECTION			= 256;
	level.iDFLAGS_NO_PROTECTION					= 512;
	level.iDFLAGS_PASSTHRU						= 1024;
}


/*================
Setup any misc callbacks stuff like defines and default callbacks
================*/
SetupCallbacks()
{
	SetDefaultCallbacks();
	SetupDamageFlags();
}


/*================
Called from the gametype script to store off the default callback functions.
This allows the callbacks to be overridden by level script, but not lost.
================*/
SetDefaultCallbacks()
{
	level.callbackStartGameType = maps\mp\gametypes\_gamelogic::Callback_StartGameType;
	level.callbackPlayerConnect = maps\mp\gametypes\_playerlogic::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = maps\mp\gametypes\_playerlogic::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = maps\mp\gametypes\_damage::Callback_PlayerDamage;
	level.callbackPlayerKilled = maps\mp\gametypes\_damage::Callback_PlayerKilled;
	level.callbackCodeEndGame = maps\mp\gametypes\_gamelogic::Callback_CodeEndGame;
	level.callbackPlayerLastStand = maps\mp\gametypes\_damage::Callback_PlayerLastStand;
	level.callbackPlayerMigrated = maps\mp\gametypes\_playerlogic::Callback_PlayerMigrated;
	level.callbackHostMigration = maps\mp\gametypes\_hostmigration::Callback_HostMigration;
}


/*================
Called when a gametype is not supported.
================*/
AbortLevel()
{
	println("Aborting level - gametype is not supported");

	level.callbackStartGameType = ::callbackVoid;
	level.callbackPlayerConnect = ::callbackVoid;
	level.callbackPlayerDisconnect = ::callbackVoid;
	level.callbackPlayerDamage = ::callbackVoid;
	level.callbackPlayerKilled = ::callbackVoid;
	level.callbackCodeEndGame = ::callbackVoid;
	level.callbackPlayerLastStand = ::callbackVoid;
	level.callbackPlayerMigrated = ::callbackVoid;
	level.callbackHostMigration = ::callbackVoid;

	setdvar("g_gametype", "gungame");

	exitLevel(false);
}


/*================
================*/
callbackVoid()
{
}




