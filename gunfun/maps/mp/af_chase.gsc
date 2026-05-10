#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	maps\af_chase_fx::main();
	maps\mp\_load::main();
	
	setDvar( "r_specularcolorscale", "3" );
	
	maps\mp\_compass::setupMiniMap( "compass_map_afghan_chase" );
	
	ambientPlay( "ambient_af_chase_caves_int0" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";		
}