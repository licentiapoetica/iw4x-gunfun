#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{	
	maps\boneyard_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_boneyard" );
	
	ambientPlay( "ambient_boneyard_ext0" );	

	setdvar( "r_specularcolorscale", "2.5" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.452 );
	setdvar( "r_lightGridContrast", 0 );
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
	
}