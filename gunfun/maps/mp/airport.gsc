#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	maps\airport_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_airport" );
		
	ambientPlay( "ambient_airport_terminal0" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
}
