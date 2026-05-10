#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{

	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.5 );
	setdvar( "r_lightGridContrast", 0 );
	
//	maps\createart\favela_fog::main();
//	maps\createart\favela_art::main();
//	maps\createfx\favela_audio::main();
//	maps\favela_precache::main();
	
	maps\favela_fx::main();
	maps\mp\_load::main();
	
	maps\mp\_compass::setupMiniMap( "compass_map_favela" );
	
	ambientPlay( "ambient_favela_ext0" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
}	