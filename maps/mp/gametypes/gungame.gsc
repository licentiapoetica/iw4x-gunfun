#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*QUAKED mp_dm_spawn (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies at one of these positions.*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	registerTimeLimitDvar( level.gameType, 10, 0, 1440 );
	registerScoreLimitDvar( level.gameType, 1000, 0, 5000 );
	registerWinLimitDvar( level.gameType, 1, 0, 5000 );
	registerRoundLimitDvar( level.gameType, 1, 0, 10 );
	registerNumLivesDvar( level.gameType, 0, 0, 10 );
	registerHalfTimeDvar( level.gameType, 0, 0, 1 );
	
	level.teamBased = false;
	level.onStartGameType = ::onStartGameType;
	level.getSpawnPoint = ::getSpawnPoint;
	level.onPlayerkilled = ::onPlayerkilled; 

	game["dialog"]["gametype"] = "gungame";

	if ( getDvarInt( "g_hardcore" ) )
		game["dialog"]["gametype"] = "hc_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "camera_thirdPerson" ) )
		game["dialog"]["gametype"] = "thirdp_" + game["dialog"]["gametype"];
	else if ( getDvarInt( "scr_diehard" ) )
		game["dialog"]["gametype"] = "dh_" + game["dialog"]["gametype"];
	else if (getDvarInt( "scr_" + level.gameType + "_promode" ) )
		game["dialog"]["gametype"] = game["dialog"]["gametype"] + "_pro";
}

onStartGameType()
{
	setClientNameMode("auto_change");

	setObjectiveText( "allies", "Mod made by Santahunter \n\n Modified by God of Hellfire" );
	setObjectiveText( "axis", "Mod made by Santahunter \n\n Modified by God of Hellfire" );

	if ( level.splitscreen )
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM" );
	}
	else
	{
		setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
		setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );
	}
	
	setObjectiveHintText( "allies", "Mod made by Santahunter \n\n Modified by God of Hellfire" );
	setObjectiveHintText( "axis", "Mod made by Santahunter \n\n Modified by God of Hellfire" );

	level.killcam = false;
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter(level.mapCenter);
	
	allowed[0] = "dm";
	allowed[1] = "airdrop_pallet";
	maps\mp\gametypes\_gameobjects::main(allowed);

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 00 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 150 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	
	level.QuickMessageToAll = true;
	//level thread maps\mp\gametypes\core::core();
}
getSpawnPoint()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );
	return spawnPoint;
}
onPlayerkilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc, psOffsetTime, deathAnimDuration, killId, means) 	
{
	
}









	