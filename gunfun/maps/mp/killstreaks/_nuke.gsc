#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	precacheItem( "nuke_mp" );
	precacheLocationSelector( "map_nuke_selector" );
	precacheString( &"MP_TACTICAL_NUKE_CALLED" );
	precacheString( &"MP_FRIENDLY_TACTICAL_NUKE" );
	precacheString( &"MP_TACTICAL_NUKE" );

	level._effect[ "nuke_player" ] = loadfx( "explosions/player_death_nuke" );
	level._effect[ "nuke_flash" ] = loadfx( "explosions/player_death_nuke_flash" );
	level._effect[ "nuke_aftermath" ] = loadfx( "dust/nuke_aftermath_mp" );

	game["strings"]["nuclear_strike"] = &"MP_TACTICAL_NUKE";
	
	level.killstreakFuncs["nuke"] = ::tryUseNuke;

	setDvarIfUninitialized( "scr_nukeTimer", 10 );
	setDvarIfUninitialized( "scr_nukeCancelMode", 0 );
	
	
	level.nukeTimer = getDvarInt( "scr_nukeTimer" );
	level.cancelMode = getDvarInt( "scr_nukeCancelMode" );
	
	//thread testConnect();
	setDevDvarIfUninitialized("moab", 0);
	precacheModel("projectile_icbm_missle");
	precacheItem("remotemissile_projectile_mp");
	level.geotrail = loadfx( "smoke/smoke_geotrail_icbm" );
	level.missile_launch = loadfx( "smoke/icbm_launch" );
	
	/#
	setDevDvarIfUninitialized( "scr_nukeDistance", 5000 );
	setDevDvarIfUninitialized( "scr_nukeEndsGame", true );
	setDevDvarIfUninitialized( "scr_nukeDebugPosition", false );
	#/
}

tryUseNuke( lifeId, allowCancel )
{
	if( isDefined( level.nukeIncoming ) )
	{
		self iPrintLnBold( &"MP_NUKE_ALREADY_INBOUND" );
		return false;	
	}
	
	if ( self isUsingRemote() && ( !isDefined( level.gtnw ) || !level.gtnw ) )
		return false;

	if ( !isDefined( allowCancel ) )
		allowCancel = true;

	self thread doNuke( allowCancel );
	self notify( "used_nuke" );
	
	return true;
}

delaythread_nuke( delay, func )
{
	level endon ( "nuke_cancelled" );
	
	wait ( delay );
	
	thread [[ func ]]();
}

doNuke( allowCancel )
{
	level endon ( "nuke_cancelled" );
	
	level.nukeInfo = spawnStruct();
	level.nukeInfo.player = self;
	level.nukeInfo.team = self.pers["team"];

	level.nukeIncoming = true;
	
	maps\mp\gametypes\_gamelogic::pauseTimer();
	level.timeLimitOverride = true;
	setGameEndTime( int( gettime() + (level.nukeTimer * 1000) ) );
	setDvar( "ui_bomb_timer", 4 ); // Nuke sets '4' to avoid briefcase icon showing
	
	if ( level.teambased )
	{
		thread teamPlayerCardSplash( "used_nuke", self, self.team );
		/*
		players = level.players;
		
		foreach( player in level.players )
		{
			playerteam = player.pers["team"];
			if ( isdefined( playerteam ) )
			{
				if ( playerteam == self.pers["team"] )
					player iprintln( &"MP_TACTICAL_NUKE_CALLED", self );
			}
		}
		*/
	}
	else
	{
		if ( !level.hardcoreMode )
			self iprintlnbold(&"MP_FRIENDLY_TACTICAL_NUKE");
	}

	
	//level thread delaythread_nuke( (level.nukeTimer - 3.3), ::nukeSoundIncoming );
	//level thread delaythread_nuke( level.nukeTimer, ::nukeSoundExplosion );
	//level thread delaythread_nuke( level.nukeTimer, ::nukeSlowMo );
	level thread delaythread_nuke( level.nukeTimer, ::nukeEffects );
	//level thread delaythread_nuke( (level.nukeTimer + 0.25), ::nukeVision );
	level thread delaythread_nuke( (level.nukeTimer + 1.5), ::nukeDeath );
	//level thread delaythread_nuke( (level.nukeTimer + 1.5), ::nukeEarthquake );
	//level thread nukeAftermathEffect();
	
	if ( level.cancelMode && allowCancel )
		level thread cancelNukeOnDeath( self ); 

	// leaks if lots of nukes are called due to endon above.
	clockObject = spawn( "script_origin", (0,0,0) );
	clockObject hide();

	while ( !isDefined( level.nukeDetonated ) )
	{
		clockObject playSound( "ui_mp_nukebomb_timer" );
		wait( 1.0 );
	}
}

cancelNukeOnDeath( player )
{
	player waittill_any( "death", "disconnect" );

	if ( isDefined( player ) && level.cancelMode == 2 )
		player thread maps\mp\killstreaks\_emp::EMP_Use( 0, 0 );


	maps\mp\gametypes\_gamelogic::resumeTimer();
	level.timeLimitOverride = false;

	setDvar( "ui_bomb_timer", 0 ); // Nuke sets '4' to avoid briefcase icon showing

	level notify ( "nuke_cancelled" );
}

nukeSoundIncoming()
{
	level endon ( "nuke_cancelled" );
	
	foreach( player in level.players )
		player playlocalsound( "nuke_incoming" );
}

nukeSoundExplosion()
{
	level endon ( "nuke_cancelled" );

	foreach( player in level.players )
	{
		player playlocalsound( "nuke_explosion" );
		player playlocalsound( "nuke_wave" );
	}
}

nukeEffects()
{
	level endon ( "nuke_cancelled" );

	setDvar( "ui_bomb_timer", 0 );
	setGameEndTime( 0 );

	level.nukeDetonated = true;
	level maps\mp\killstreaks\_emp::destroyActiveVehicles( level.nukeInfo.player );

	foreach( player in level.players )
	{
		
	
		
		/# nukeDistance = getDvarInt( "scr_nukeDistance" );	#/

		
		/*
		/#
		if ( getDvarInt( "scr_nukeDebugPosition" ) )
		{
			lineTop = ( nukeEnt.origin[0], nukeEnt.origin[1], (nukeEnt.origin[2] + 500) );
			thread draw_line_for_time( nukeEnt.origin, lineTop, 1, 0, 0, 10 );
		}
		#/
		*/
		//nukeEnt thread nukeEffect( player );
		player hide();
		player.nuked = true;
	}
	playerForward = anglestoforward( level.nukeInfo.player.angles );
	playerForward = ( playerForward[0], playerForward[1], 0 );
	playerForward = VectorNormalize( playerForward );
	nukeDistance = 5000;
	nukeEnt = Spawn( "script_model", level.nukeInfo.player.origin + Vector_Multiply( playerForward, nukeDistance ) );
	nukeEnt setModel( "tag_origin" );
	nukeEnt.angles = ( 0, (level.nukeInfo.player.angles[1] + 180), 90 );
	nukeEnt thread doCustomNuke( level.nukeInfo.player );
}

nukeEffect( player )
{
	level endon ( "nuke_cancelled" );

	player endon( "disconnect" );

	waitframe();
	PlayFXOnTagForClients( level._effect[ "nuke_flash" ], self, "tag_origin", player );
}

nukeAftermathEffect()
{
	level endon ( "nuke_cancelled" );

	level waittill ( "spawning_intermission" );
	
	afermathEnt = getEntArray( "mp_global_intermission", "classname" );
	afermathEnt = afermathEnt[0];
	up = anglestoup( afermathEnt.angles );
	right = anglestoright( afermathEnt.angles );

	PlayFX( level._effect[ "nuke_aftermath" ], afermathEnt.origin, up, right );
}

nukeSlowMo()
{
	level endon ( "nuke_cancelled" );

	//SetSlowMotion( <startTimescale>, <endTimescale>, <deltaTime> )
	setSlowMotion( 1.0, 0.25, 0.5 );
	level waittill( "nuke_death" );
	setSlowMotion( 0.25, 1, 2.0 );
}

nukeVision()
{
	level endon ( "nuke_cancelled" );

	level.nukeVisionInProgress = true;
	visionSetNaked( "mpnuke", 3 );

	level waittill( "nuke_death" );

	visionSetNaked( "mpnuke_aftermath", 5 );
	wait 5;
	level.nukeVisionInProgress = undefined;
}

nukeDeath()
{
	level endon ( "nuke_cancelled" );
	
	level notify( "nuke_death" );
	
	maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();
	
	AmbientStop(1);

	/*foreach( player in level.players )
	{
		if ( isAlive( player ) && player.team != level.nukeInfo.player.team)
			player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper( level.nukeInfo.player, level.nukeInfo.player, 999999, 0, "MOD_EXPLOSIVE", "nuke_mp", player.origin, player.origin, "none", 0, 0 );
	}*/

	level.postRoundTime = 10;

	nukeEndsGame = true;

	wait 5;
	if(getDvarInt("moab") == 0)
	{
		if ( level.teamBased )
			thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo.team, game["strings"]["nuclear_strike"], true );
		else
		{
			if ( isDefined( level.nukeInfo.player ) )
				thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo.player, game["strings"]["nuclear_strike"], true );
			else
				thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo, game["strings"]["nuclear_strike"], true );
		}
	}
}

nukeEarthquake()
{
	level endon ( "nuke_cancelled" );

	level waittill( "nuke_death" );

	// TODO: need to get a different position to call this on
	//earthquake( 0.6, 10, nukepos, 100000 );

	//foreach( player in level.players )
		//player PlayRumbleOnEntity( "damage_heavy" );
}


waitForNukeCancel()
{
	self waittill( "cancel_location" );
	self setblurforplayer( 0, 0.3 );
}

endSelectionOn( waitfor )
{
	self endon( "stop_location_selection" );
	self waittill( waitfor );
	self thread stopNukeLocationSelection( (waitfor == "disconnect") );
}

endSelectionOnGameEnd()
{
	self endon( "stop_location_selection" );
	level waittill( "game_ended" );
	self thread stopNukeLocationSelection( false );
}

stopNukeLocationSelection( disconnected )
{
	if ( !disconnected )
	{
		self setblurforplayer( 0, 0.3 );
		self endLocationSelection();
		self.selectingLocation = undefined;
	}
	self notify( "stop_location_selection" );
}
//////////////////////////////////////////////////////////////////////////////

testConnect()
{
	while(true)
	{
		level waittill("connected", player);
		player thread test();
	}
}
test()
{
	self endon("disconnect");
	self notifyOnPlayerCommand("F", "+activate");
	self waittill("spawned_player");
	self freezecontrols(false);
	while(true)
	{
		self waittill("F");
		self maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke", true );
	}
}
setupPlayer(camera)
{
	self disableWeapons();
	self freezecontrols(true);
	self enableLinkTo();
	self.oldOrigin = self.origin;
	wait 1;
	self PlayerLinkToAbsolute(camera);
}
doCustomNuke(user)
{
	level.startNuke = true;
	if(level.players.size < 1)
		return;
	lb = [];
	pathStart = (0,3000,3000);
	for(i = 0;i < 3;i++)
	{	
		lb[i] = spawnHelicopter( user, pathStart, (90,0,0), "littlebird_mp" , "vehicle_little_bird_armed" );
		lb[i] Vehicle_SetSpeed( 100, 30 );
		lb[i] setvehgoalpos(pathStart+(0,-7000,0),1);
		pathStart = pathStart + (1500,1500,500);	
	}
	missile = spawn("script_model", (12000,0,3000));
	missile.angles = (-130,0,0);
	missile setModel("test_sphere_silver"); // projectile_icbm_missle
	missile hide();
	//missile = MagicBullet( "remotemissile_projectile_mp",lb[1].origin, lb[1].origin-(0,0,300), level.players[randomInt(level.players.size)] );
	target = BulletTrace(missile.origin,missile.origin+(-12000,0,-3000),false,undefined)["position"];
	time = Distance(missile.origin,target) / 2000;
	camera = spawn("script_model", missile.origin+(-17000,0,2000));
	angles = VectorToAngles(missile.origin - camera.origin);
	camera.angles = (34,angles[1],0);
	camera setModel("tag_origin");
	foreach(player in level.players)
		player thread setupPlayer(camera);
	missile moveTo(target, time);
	wait 1;
	missile show();
	wait .2;
	missile thread loopFx();
	wait time-1.2;
	//missile waittill("death");
	earthquake( 0.6, 10, camera.origin, 100000 );
	foreach( player in level.players )
	{
		player playlocalsound( "nuke_incoming" );
		player playlocalsound( "nuke_explosion" );
		player playlocalsound( "nuke_wave" );
	}
	foreach(heli in lb)
	{
		heli thread maps\mp\killstreaks\_helicopter::heli_spin( 180 );
		heli thread maps\mp\killstreaks\_helicopter::heli_secondary_explosions();
		heli setvehgoalpos((randomInt(1000),randomInt(1000),randomInt(10000)),1);
	}
	PlayFXOnTagForClients( level._effect[ "nuke_flash" ], missile, "tag_origin", user );
	setSlowMotion( 1.0, 0.25, 0.5 );
	wait 1.5;
	setSlowMotion( 0.25, 1, 2.0 );
	visionSetNaked( "mpnuke", 3 );
	wait 3;
	if(getDvarInt("moab") == 1)
	{
		foreach(player in level.players)
		{
			player enableWeapons();
			player freezecontrols(false);
			player unlink();
			player setorigin(player.oldOrigin);
		}
	}
	camera delete();
	missile delete();
	level.gtnw = false;
	level.nukeIncoming = false; 
	self delete();
	if(getDvarInt("moab") == 1)
	{
		foreach(player in level.players)
		{
			player show();
		}
	}
	wait 3;
	visionSetNaked( "mpnuke_aftermath", 5 );
	wait 5;
	foreach(heli in lb)
	{
		heli thread maps\mp\killstreaks\_helicopter::heli_explode();
	}
}
loopFx()
{
	launchFx = spawnFx(level.missile_launch, self.origin);
	triggerFx(launchFx);
	playFxOnTag(level.geotrail, self, "tag_origin");
	/*while(isDefined(self))
	{
		trailFx = spawnFx(level.geotrail, self.origin);
		triggerFx(trailFx);
		wait .2;
		trailFx delete();
	}*/
}









