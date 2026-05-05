#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
//	maps\createart\dcburning_fog::main();
	maps\dcburning_fx::main();
	maps\mp\_load::main();
//	maps\createfx\dcburning_audio::main();

	maps\mp\_compass::setupMiniMap("compass_map_dcburning");
	
	ambientPlay( "ambient_dcemp_dry" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
}