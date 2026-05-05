#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	maps\estate_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_estate" );
		
	ambientPlay( "ambient_estate_ext0" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
}
