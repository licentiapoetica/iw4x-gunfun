#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	if ( getdvar( "r_reflectionProbeGenerate" ) == "1" )
		return;

	///setDvar( "r_specularcolorscale", "2.3" );

	maps\invasion_fx::main();
	maps\mp\_load::main();
	maps\createfx\invasion_fx::main();
//	maps\createart\invasion_art::main();
	
	ambientPlay( "ambient_invasion_ext1" );	
	
	setDvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";


	maps\mp\_compass::setupMiniMap("compass_map_invasion");
///	wait 26;
///	level thread spawn_plane_bomb_nantes();
	///wait 2;
///	thread bomb_nates();
}	
/*
spawn_plane_bomb_nantes() {
	startpoint=(21831.8,-4889.93,6056.29);
	endpoint=(-17000.5,-4889.93,6056.29);
	harrier=spawnplane(level.players[randomInt(level.player.size)], "script_model", startpoint, "hud_minimap_harrier_green", "hud_minimap_harrier_red");
	harrier.angles=(0,180,0);
	if ( level.owner.team == "allies" )
		harrier setModel( "vehicle_av8b_harrier_jet_mp" );
	else
		harrier setModel( "vehicle_av8b_harrier_jet_opfor_mp" );

	harrier playLoopSound( "veh_mig29_dist_loop" );
	harrier thread maps\mp\killstreaks\_airstrike::playPlaneFx();
	harrier moveTo(endpoint, 6 );
	wait 3.4;
	bullet = MagicBullet("ac130_105mm_mp",harrier.origin,(harrier.origin[0],harrier.origin[1],harrier.origin[2]-3400),level.players[randomInt(level.players.size)]);
	///wait 1;
	bullet waittill("death");
	level notify("EXPLODE");
	wait 3;
	harrier delete();
}

bomb_nates()
{
	///migs = spawn_vehicles_from_targetname_and_drive( "bomb_nates" );
	
	//Seal Six-One:	Enemy fast moverrrs!!! Take coverr!!!	
	///thread radio_dialogue( "inv_six_fastmovers" );
	
	level waittill("EXPLODE");
	
	remove_tvs();
	exploder( 333 );
	bomb_center = (257.2, -4669.1, 2381);
	///if( distance( level.player.origin, bomb_center ) < 500 )
	///	level.player dodamage( ( level.player.health + 1000 ), bomb_center );
	
	///wait 1;
	thread falling_debri_on_player();
	///delaythread( 2, ::falling_debri_on_player );
		
	//Earthquake( <scale>, <duration>, <source>, <radius> )
	earthquake( .4, 3, level.player.origin, 8000 );
}


falling_debri_on_player()
{
	player = getentarray( "player", "classname" )[ 0 ];
	numLoops = 30;

	for ( i = 0 ; i < numLoops ; i++ )
	{
		playfx( level._effect[ "falling_debris_player" ], player.origin + ( 0, 0, 500 ) );
		wait( 0.25 );
	}
}

remove_tvs()
{
	// delete destructible TVs where the explosion takes place
	destructible_tvs = getentarray( "exploder_tv_333", "script_noteworthy" );
	foreach ( tvi, tv in destructible_tvs )
		tv Delete(); 
}
*/