#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	setDvar( "r_lightGridEnableTweaks", 1 );
	setDvar( "r_lightGridIntensity", 1.2 );
	setDvar( "r_lightGridContrast", 0 );
	setDvar( "sm_sunShadowScale", 0.7 );
		
	maps\arcadia_fx::main();
	maps\mp\_load::main();
	
	maps\mp\_compass::setupMiniMap("compass_map_arcadia");
	
	ambientPlay( "arcadia_ext3" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
}