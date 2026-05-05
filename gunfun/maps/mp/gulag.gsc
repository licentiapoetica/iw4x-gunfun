#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{

//	maps\createfx\gulag_audio::main();
//	maps\gulag_precache::main();
//	maps\createart\gulag_fog::main();
//	maps\gulag_fx::main();
	
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap( "compass_map_gulag" );
	
	setDvar( "r_spotLightMaxLength", 900 );
	
	ambientPlay( "ambient_gulag_ext0" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
}