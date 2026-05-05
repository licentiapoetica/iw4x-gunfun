
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\dc_whitehouse_code;
///#using_animtree( "generic_human" );

main()
{
	maps\dc_whitehouse_precache::main(); 
	///maps\createart\dc_whitehouse_fog::main();
	maps\createfx\dc_whitehouse_fx::main();
	maps\dc_whitehouse_fx::main();
	/////maps\createart\dc_whitehouse_fog::main();
	///maps\dcburning_fx::main();
	precachemodel( "sentry_minigun" );
	PreCacheTurret( "heli_spotlight" );
	maps\mp\_load::main();
	maps\mp\_compass::setupMiniMap( "compass_map_dcemp_static" );
	
	ambientPlay( "dcemp_heavy_rain_tunnel" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";

	///flags();
	///	flag_set("whitehouse_spotlight");
	///flag_set("whitehouse_spotlight");
	///flag_set("whitehouse_entrace_init");
///	whitehouse_mg_setup();
///	westwing_mg_setup();
///	whitehouse_main();

}

flags()
{
	flag_init("whitehouse_spotlight");
	flag_init( "whitehouse_entrance_init" );
	flag_init("whitehouse_radio_start");
}

whitehouse_main()
{
///	autosave_by_name( "tunnel_exit" );

///	array_spawn_function_noteworthy( "whitehouse_drone", ::whitehouse_drone  );
	///array_spawn_function_noteworthy( "drone_war_drone", ::whitehouse_drone_war_drone  );

///	spawner = getent( "marshall", "script_noteworthy" );
///	spawner add_spawn_function( ::whitehouse_marshall );
///	spawner spawn_ai();

///	chandelier_setup();
///	magic_rpg_setup();
///	whitehouse_rappel_setup();
//	sandbag_group_setup( "sandbag_group" );
///	sandbag_group_setup( "westwing_sandbag_group" );
	///whitehouse_mg_setup();
	///westwing_mg_setup();
	level thread whitehouse_spotlight_main();

	///flag_wait( "whitehouse_spotlight" );
	///thread maps\_weather::rainnone( 20 );
	//thread maps\_ambient::set_ambience_blend_over_time( 20, "dcemp_dry", "dcemp_light_rain" );

	///level thread whitehouse_drone_slaughter();

///	whitehouse_entrance();
}


whitehouse_spotlight_main()
{
	flag_wait( "whitehouse_spotlight" );

	wh_spotlight = whitehouse_spotlight_create( "whitehouse_spotlight", 400 );

	/*
	flag_wait( "whitehouse_entrance_init" );

	if ( isdefined( wh_spotlight ) )
		wh_spotlight.damage_ent notify( "damage", 1000, level.player );
	/
	ww_spotlight = whitehouse_spotlight_create( "westwing_spotlight", 600 );

	flag_wait( "whitehouse_radio_start" );
	wait 30;

	if ( isdefined( ww_spotlight ) )
		ww_spotlight.damage_ent notify( "damage", 1000, level.player );

	*/
	///ww_spotlight = whitehouse_spotlight_create( "westwing_spotlight", 600 );
	
		
}

whitehouse_spotlight_dunn()
{
	// todo: add dialogue
	flag_wait( "whitehouse_entrance_moveup" );
	wait 8;

	if ( isdefined( self ) )
	{
	///	level.dunn SetEntityTarget( self );
		self waittill( "death" );
		///level.dunn clearEntityTarget();
	}
}







