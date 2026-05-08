#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
//	maps\createart\favela_escape_art::main();
//	maps\createart\favela_escape_fog::main();
//	maps\createfx\favela_escape_fx::main();
//	maps\favela_escape_precache::main();
	maps\favela_escape_fx::main();

	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap("compass_map_favela_escape");

	ambientPlay( "ambient_favela_escape_ext0" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
}