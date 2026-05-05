#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{		
	maps\dcemp_fx::main();
	maps\mp\_load::main();
	
//	maps\createart\dcemp_fog::main();
//	maps\createfx\dcemp_fx::main();
//	level thread maps\dcemp_amb::main();
	
	maps\mp\_compass::setupMiniMap( "compass_map_dcemp" );

	ambientPlay( "ambient_dcemp_dry" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
}