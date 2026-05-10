#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	setDvar( "physVeh_collideWithClipOnly", 1 );

//	maps\createart\roadkill_art::main();
//	maps\createfx\roadkill_audio::main();
//	maps\roadkill_anim::main();
//	maps\roadkill_precache::main();
//	maps\createart\roadkill_fog::main();
	maps\roadkill_fx::main();
	
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_roadkill" );
	
	ambientPlay( "ambient_roadkill_ext2" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
	
}