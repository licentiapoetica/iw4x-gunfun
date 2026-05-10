#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

main()
{
	maps\af_caves_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_afghan_caves" );
	
	ambientPlay( "af_caves_ext" );	
	
	setdvar( "compassmaxrange", "1800" );

	game[ "attackers" ] = "allies";
	game[ "defenders" ] = "axis";	
	thread custom_killtrigger();
}	


custom_killtrigger()
{
	while (true)
	{
		wait 0.1;

		foreach (player in level.players)
		{
			if (!isDefined(player) || !isPlayer(player))
			{
				continue;
			}

			if (player.origin[2] < -3980.0) /// Lower level
			{
				player suicide();
			}
		}
	}
}
