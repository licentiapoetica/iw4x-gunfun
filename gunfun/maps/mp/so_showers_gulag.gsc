#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{

	///maps\createfx\gulag_fx::main();
	///maps\gulag_precache::main();
//	maps\createart\gulag_fog::main();
	maps\mp\gulag_fx::main();
	
	maps\mp\_load::main();
	///maps\mp\_compass::setupMiniMap( "compass_map_gulag" );
	/*
	setClientDvar("g_TeamIcon_Axis","faction_128_ussr");
	setClientDvar("g_TeamIcon_EnemyAxis","faction_128_ussr");
	setClientDvar("g_TeamIcon_MyAxis","faction_128_ussr");

	setClientDvar("g_TeamIcon_Allies","faction_128_ussr");
	setClientDvar("g_TeamIcon_EnemyAllies","faction_128_ussr");
	setClientDvar("g_TeamIcon_MyAllies","faction_128_ussr");
	*/
	setDvar( "r_spotLightMaxLength", 900 );
	
	ambientPlay( "ambient_gulag_ext0" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
}

