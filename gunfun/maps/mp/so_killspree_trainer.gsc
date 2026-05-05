//#include maps\_utility;
//#include maps\_vehicle;
//#include maps\_anim;
//#include maps\_hud_util;
//#include common_scripts\utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
main()
{

	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.2 );
	setdvar( "r_lightGridContrast", 0 );
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
	///maps\createart\trainer_fog::main();
	///maps\trainer_precache::main();
	///maps\createfx\trainer_audio::main();
	///maps\trainer_fx::main();
///	maps\_drone_ai::init();
	

	maps\mp\_load::main();	
	
	maps\mp\_compass::setupMiniMap("compass_map_trainer");
}