#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	maps\cliffhanger_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_cliffhanger" );
		
	ambientPlay( "ambient_cliffhanger_ext0" );	
	
	setDvar( "r_specularcolorscale", "1.2" );
	setDvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
}