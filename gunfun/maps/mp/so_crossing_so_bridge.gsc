#include common_scripts\utility;
//#include maps\_utility;
///#include maps\_vehicle;
//#include maps\_anim;
///#include maps\_specialops;
#include maps\mp\_utility;
#include maps\so_bridge_code;
#include maps\mp\gametypes\_hud_util;
main()
{
	maps\so_bridge_fx::main();
	maps\createart\so_bridge_art::main();
	maps\so_bridge_anim::main();
	maps\so_bridge_precache::main();
	///maps\so_bridge_amb::main();
	ambientPlay( "ambient_bridge_ext0" );
	maps\mp\_compass::setupMiniMap("compass_map_so_bridge");
	setdvar( "compassmaxrange", "1800" );
	/*game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";
	//maps\_load::main();
	
	/// /// Gives bride .fx
	level thread maps\so_bridge_code::bridge_collapse_prep();

	thread enable_missile_attack_taxi();
	///enable_uav_resources();

	trigger = GetEnt( "collapsed_bridge_effects", "targetname" );
	wait (30);
	///flag_set( "so_ambient_uavs" );
	taxi = GetEnt( "missile_taxi", "script_noteworthy" );
	
	level notify("bridge_collapse"); /// Triggers bridge collison
	taxi notify("taxi_moving");
	level thread maps\so_bridge_code:: bridge_collapse_earthquake();
	trigger notify("trigger");  /// for .fx
	wait (0.5);
	level notify("bridge_sway_start");
	
	thread maps\so_bridge_code::collapsed_section_shakes();
*/
}
/*
enable_missile_attack_taxi()
{
	flag_set( "so_missile_attack_taxi" );
	thread missile_taxi_moves();
}
*/
/*
enable_troop_flood()
{
	flag_set( "so_flood_spawner" );
}

enable_uav_resources()
{
	array_thread( getvehiclenodearray( "uav_sound", "script_noteworthy" ), maps\_ucav::plane_sound_node );
	array_thread( getvehiclenodearray( "fire_missile", "script_noteworthy" ), maps\_ucav::fire_missile_node );
}
*/

/*
enable_bridge_collapse()
{

	flag_set( "so_bridge_collapse" );

	precacheModel( "vehicle_coupe_gold" );

	///level thread collapsed_section_shakes();
	///level thread bridge_collapse_prep();

	trigger = GetEnt( "bridge_collapse", "targetname" );

	if ( GetDvar( "test_bridge_collapse" ) == "1" )
	{	
		wait 10;
		trigger  notify( "trigger");
	}

	trigger waittill( "trigger" );

	// Reduce speed until collapse is done, view_tilt resets this
	foreach ( player in level.players )
	{
	player AllowSprint( false );
	///	player blend_movespeedscale( 0.7, 2 );
	}
	
	dmg_trigger = GetEnt( "so_bridge_damage_trigger", "targetname" );
	thread bridge_collapse_earthquake();
	level notify( "bridge_collapse" );
	count = 0;
	while ( 1 ) {

		dmg_trigger waittill( "trigger", other );

		if ( other.code_classname == "script_vehicle" )
		{
			count++;

			if ( count == 1 )
			{
				thread bridge_collapse_earthquake();
				exploder( 2 );
			}

			if ( count == 2 )
			{
				level notify( "bridge_collapse" );
				return;
			}
		}
	}
	
}
*/

