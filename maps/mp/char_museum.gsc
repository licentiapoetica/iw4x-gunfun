#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{		
	maps\char_museum_fx::main();	
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_overlay_map_blank" );
			
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
}
