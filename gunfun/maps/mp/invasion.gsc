#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	if ( getdvar( "r_reflectionProbeGenerate" ) == "1" )
		return;

	setDvar( "r_specularcolorscale", "2.3" );

	maps\invasion_fx::main();
	maps\mp\_load::main();
	
//	maps\createart\invasion_art::main();
	
	ambientPlay( "ambient_invasion_ext1" );	
	
	setDvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";


	maps\_compass::setupMiniMap("compass_map_invasion");
}	