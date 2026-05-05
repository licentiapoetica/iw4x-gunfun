#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{	
	maps\contingency_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_contingency" );
	
	ambientPlay( "contingency_ext0" );	

	setdvar( "sm_sunShadowScale", 0.5 );// optimization
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.24 );
	setdvar( "r_lightGridContrast", 0 );
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
	
}