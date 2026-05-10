#include common_scripts\utility; 
#include maps\mp\_utility; 
#include maps\mp\gametypes\_hud_util;


loadWeapons()
{
    level.gungameList = [];
    weaponList = [];
    amount_of_weapons = getDvarInt("amount_weapons");

    if(getDvar("gunmode") == "Snipers only")
    {
        amount_of_weapons = int(amount_of_weapons/2);
        weaponList[weaponList.size] = "barrett_mp";
        weaponList[weaponList.size] = "wa2000_mp";
        weaponList[weaponList.size] = "m21_mp";
        weaponList[weaponList.size] = "cheytac_mp";
    }
    else if(getDvar("gunmode") == "Pistol & Shotguns only")
    {
        amount_of_weapons = int(amount_of_weapons/2);
        weaponList[weaponList.size] = "deserteagle_mp";
        weaponList[weaponList.size] = "coltanaconda_mp";
        weaponList[weaponList.size] = "beretta_mp";
        // semi auto pistols
        weaponList[weaponList.size] = "tmp_mp";
        weaponList[weaponList.size] = "glock_mp";
        weaponList[weaponList.size] = "beretta393_mp";
        weaponList[weaponList.size] = "pp2000_mp";
        // shotguns
        weaponList[weaponList.size] = "ranger_mp";
        weaponList[weaponList.size] = "model1887_mp";
        weaponList[weaponList.size] = "striker_mp";
        weaponList[weaponList.size] = "aa12_mp";
        weaponList[weaponList.size] = "m1014_mp";
        weaponList[weaponList.size] = "spas12_mp";
    }
    else if(getDvar("gunmode") == "Fungame")
    {
        loadFungameList();
        return;
    }
    else
    {
        // pistols
        weaponList[weaponList.size] = "usp_mp";
        weaponList[weaponList.size] = "deserteagle_mp";
        weaponList[weaponList.size] = "deserteagle_akimbo_mp"; // GL deagle
        weaponList[weaponList.size] = "coltanaconda_mp";
        weaponList[weaponList.size] = "beretta_mp";
        // semi auto pistols
        weaponList[weaponList.size] = "tmp_mp";
        weaponList[weaponList.size] = "glock_mp";
        weaponList[weaponList.size] = "beretta393_mp";
        weaponList[weaponList.size] = "pp2000_mp";
        // shotguns
        weaponList[weaponList.size] = "ranger_mp";
        weaponList[weaponList.size] = "model1887_mp";
        weaponList[weaponList.size] = "striker_mp";
        weaponList[weaponList.size] = "aa12_mp";
        weaponList[weaponList.size] = "m1014_mp";
        weaponList[weaponList.size] = "spas12_mp";
        // rocket launcher
        weaponList[weaponList.size] = "m79_mp";
        weaponList[weaponList.size] = "rpg_mp";
        weaponList[weaponList.size] = "at4_mp";
        //weaponList[weaponList.size] = "javelin_mp";
        // assault rifles
        weaponList[weaponList.size] = "ak47_mp";
        weaponList[weaponList.size] = "m16_mp";
        weaponList[weaponList.size] = "m4_mp";
        weaponList[weaponList.size] = "fn2000_mp";
        weaponList[weaponList.size] = "masada_mp";
        weaponList[weaponList.size] = "famas_mp";
        weaponList[weaponList.size] = "fal_mp";
        weaponList[weaponList.size] = "scar_mp";
        weaponList[weaponList.size] = "tavor_mp";
        weaponList[weaponList.size] = "ak47classic_mp";
        // sub machine guns
        weaponList[weaponList.size] = "mp5k_mp";
        weaponList[weaponList.size] = "uzi_mp";
        weaponList[weaponList.size] = "p90_mp";
        weaponList[weaponList.size] = "kriss_mp";
        weaponList[weaponList.size] = "ump45_mp";
        weaponList[weaponList.size] = "ak74u_mp";
        // light machine guns
        weaponList[weaponList.size] = "rpd_mp";
        weaponList[weaponList.size] = "sa80_mp";
        weaponList[weaponList.size] = "mg4_mp";
        weaponList[weaponList.size] = "m240_mp";
        weaponList[weaponList.size] = "aug_mp";
        // sniper
        weaponList[weaponList.size] = "barrett_mp";
        weaponList[weaponList.size] = "wa2000_mp";
        weaponList[weaponList.size] = "m21_mp";
        weaponList[weaponList.size] = "cheytac_mp";
        weaponList[weaponList.size] = "dragunov_mp";
        weaponList[weaponList.size] = "m40a3_mp";
        // special
        weaponList[weaponList.size] = "ac130_mp";
        //weaponList[weaponList.size] = "riotshield_mp";
        
    }

    shuffle = getDvarInt("shuffle_weapons");
    level.gungameList[0] = "defaultweapon_mp";
    for(i = 1; i <= amount_of_weapons; i++)
    {
        if(weaponList.size <= 0) break;

        if(shuffle)
            id = randomInt(weaponList.size); 
        else
            id = (i - 1) % weaponList.size;

        level.gungameList[level.gungameList.size] = setWeapon(weaponList[id]);
        
        // Only remove specific weapons if we still have enough unique ones left
        if(weaponList.size > 5) 
        {
            if(weaponList[id] == "m79_mp" || weaponList[id] == "at4_mp" || weaponList[id] == "rpg_mp" || weaponList[id] == "riotshield_mp" || weaponList[id] == "dragunov_mp" || weaponList[id] == "m40a3_mp" || weaponList[id] == "peacekeeper_mp" || weaponList[id] == "deserteagle_akimbo_mp")
                weaponList = removeIDfromArray(id, weaponList);
        }
    }
    //level.gungameList[1] = setWeapon("rpg_mp");
    //level.gungameList[1] = "rpg_mp";
    level.weaponsLoaded = true;
}
removeIDfromArray(id, weaponList)
{
    newArray = [];
    for(i = 0; i < weaponList.size;i++)
    {
        if(id != i)
            newArray[newArray.size] = weaponList[i];
    }
    return newArray;
}
setWeapon(name)
{
    // If the caller already specified a fully-qualified akimbo weapon (e.g.
    // "deserteagle_akimbo_mp"), pass it through unchanged — no randomization.
    if(isSubstr(name, "_akimbo_"))
        return name;
    name = strTok(name, "_");
    scope = "";
    attachments = "";
    switch(name[0])
    {
        case "ak47":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break;
        case "m16":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break;    
        case "m4":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break; 
        case "fn2000":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break; 
        case "masada":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break; 
        case "famas":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break; 
        case "fal":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break; 
        case "scar":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break; 
        case "tavor":
            scope = "acog,eotech,,reflex";
            attachments = "fmj,xmags,gl,heartbeat,silencer,thermal,,shotgun";
            break; 
         case "ak47classic":
            scope = "acog,,reflex";
            attachments = "fmj,gl,,silencer,xmags";
            break;     
        // sub machine guns    
        case "mp5k":
            scope = "acog,eotech,,reflex,akimbo";
            attachments = "fmj,xmags,silencer,thermal,,rof";
            break; 
        case "uzi":
            scope = "acog,eotech,,reflex,akimbo";
            attachments = "fmj,xmags,silencer,thermal,,rof";
            break; 
        case "p90":
            scope = "acog,eotech,,reflex,akimbo";
            attachments = "fmj,xmags,silencer,thermal,,rof";
            break; 
        case "kriss":
            scope = "acog,eotech,,reflex,akimbo";
            attachments = "fmj,xmags,silencer,thermal,,rof";
            break; 
        case "ump45":
            scope = "acog,eotech,,reflex,akimbo";
            attachments = "fmj,xmags,silencer,thermal,,rof";
            break;    
         case "ak47u":
            scope = "acog,,";
            attachments = "xmags,,";
            break;        
        // light machine guns
        case "rpd":
            scope = "acog,,eotech";
            attachments = "fmj,xmags,silencer,thermal,,grip,heartbeat"; // reflex
            break;
        case "sa80":
            scope = "acog,,eotech";
            attachments = "fmj,xmags,silencer,thermal,,grip,heartbeat"; 
            break;
        case "mg4":
            scope = "acog,,eotech";
            attachments = "fmj,xmags,silencer,thermal,,grip,heartbeat"; 
            break;
        case "m240":
            scope = "acog,,eotech";
            attachments = "fmj,xmags,silencer,thermal,,grip,heartbeat"; 
            break;
        case "aug":
            scope = "acog,,eotech";
            attachments = "fmj,xmags,silencer,thermal,,grip,heartbeat"; 
            break;     
        // sniper
        case "barrett":
            scope = "acog,,";
            attachments = "fmj,xmags,silencer,thermal,,heartbeat"; 
            break;   
        case "wa2000":
            scope = "acog,,";
            attachments = "fmj,xmags,silencer,thermal,,heartbeat"; 
            break;   
        case "m21":
            scope = "acog,,";
            attachments = "fmj,xmags,silencer,thermal,,heartbeat"; 
            break;   
        case "cheytac":
            scope = "acog,,";
            attachments = "fmj,xmags,silencer,thermal,,heartbeat"; 
            break;      
        // shotgun
        case "ranger":
            scope = "akimbo,";
            attachments = "fmj,"; 
            break; 
        case "model1887":
            scope = "akimbo,";
            attachments = "fmj,"; 
            break;      
        case "striker":
            scope = "eotech,reflex,";
            attachments = "fmj,grip,silencer,xmags,"; 
            break; 
        case "aa12":
            scope = "eotech,reflex,";
            attachments = "fmj,grip,silencer,xmags,"; 
            break; 
         case "m1014":
            scope = "eotech,reflex,";
            attachments = "fmj,grip,silencer,xmags,"; 
            break;          
        case "spas12":
            scope = "eotech,reflex,";
            attachments = "fmj,grip,silencer,xmags,"; 
            break; 
        // pistols
        case "usp": // some variants get lost because fmj can be front and back attachment
            scope = "akimbo,";
            attachments = "fmj,silencer,xmags"; // tactical 
            break; 
        case "beretta": 
            scope = "akimbo,";
            attachments = "fmj,silencer,xmags"; 
            break; 
        case "deserteagle": 
            scope = "akimbo,";
            attachments = "fmj,silencer,xmags"; 
            break; 
        case "coltanaconda": 
            scope = "akimbo,";
            attachments = "fmj,silencer,xmags"; 
            break;    
        // semi automatic pistols
        case "tmp": 
            scope = "akimbo,eotech,"; // reflex
            attachments = "fmj,silencer,xmags,"; 
            break;   
        case "glock": 
            scope = "akimbo,eotech,";
            attachments = "fmj,silencer,xmags,"; 
            break;
        case "beretta393": 
            scope = "akimbo,eotech,";
            attachments = "fmj,silencer,xmags,"; 
            break;
        case "pp2000": 
            scope = "akimbo,eotech,";
            attachments = "fmj,silencer,xmags,"; 
            break;       
        case "ac130":
            scope = "";
            attachments = "25mm,40mm,105mm";     
            break;
        default: // grenadelaunchers and riotshield
            scope = "";
            attachments = "";
            break;    
    }
    
    if(scope == "" && attachments == "")
    {
        return (name[0] + "_mp");
    }
    else if(scope == "") // ac130 only
    {
        attachmentsAr = strTok(attachments, ",");
        usedAttachment = attachmentsAr[randomInt(attachmentsAr.size)];
        return (name[0] + "_" + usedAttachment + "_mp");
    }

    scopeAr = strTok(scope, ",");
    usedScope = scopeAr[randomInt(scopeAr.size)];
    attachmentsAr = strTok(attachments, ",");
    usedAttachment = attachmentsAr[randomInt(attachmentsAr.size)];

    if((usedScope == "akimbo") && (name[0] == "deserteagle" || name[0] == "coltanaconda")){
        attachments = "fmj,"; 
        attachmentsAr = strTok(attachments, ",");
        usedAttachment = attachmentsAr[randomInt(attachmentsAr.size)];
    }
    else if(usedScope == "reflex")
    {
        if(name[0] == "aa12" || name[0] == "spas12" || name[0] == "striker" || name[0] == "m1014")
        {
            attachments = "silencer,xmags,"; 
            attachmentsAr = strTok(attachments, ",");
            usedAttachment = attachmentsAr[randomInt(attachmentsAr.size)];
        }
        else if(isAssaultRifle(name[0]))
        {
            if(usedAttachment == "gl" || usedAttachment == "fmj" || usedAttachment == "heartbeat")
                return (name[0] + "_" + usedAttachment + "_" + usedScope + "_mp");
        }
        else if(isSMG(name[0]))
        {
            if(usedAttachment == "fmj")
                return (name[0] + "_" + usedAttachment + "_" + usedScope + "_mp");
        }
    }
    //iPrintln("scope" + usedScope);
    //iPrintln("attachment" + usedAttachment);
    if(usedAttachment == "thermal")
        return (name[0]  + "_" + usedAttachment + "_mp");
    else    
        return (name[0] + "_" + usedScope + "_" + usedAttachment + "_mp");
}
isAssaultRifle(name)
{
    ar = [];
    ar[ar.size] = "fn2000";
    ar[ar.size] = "masada";
    ar[ar.size] = "famas";
    ar[ar.size] = "fal";
    ar[ar.size] = "m4";
    ar[ar.size] = "m16";
    ar[ar.size] = "scar";
    ar[ar.size] = "tavor";
    ar[ar.size] = "ak47classic";
    foreach(a in ar)
    {
        if(name == a)
            return true;
    }
    return false;
}

loadFungameList()
{
    level.fungameWeapons = [];

    // PISTOLS (1-20)
    addFungameWeapon("m40a3_mp");
    addFungameWeapon("usp_mp");
    addFungameWeapon("usp_silencer_mp");
    addFungameWeapon("usp_tactical_mp");
    addFungameWeapon("usp_fmj_mp");
    addFungameWeapon("usp_akimbo_mp");
    addFungameWeapon("beretta_mp");
    addFungameWeapon("beretta_silencer_mp");
    addFungameWeapon("beretta_tactical_mp");
    addFungameWeapon("beretta_fmj_mp");
    addFungameWeapon("beretta_akimbo_mp");
    addFungameWeapon("deserteagle_mp");
    addFungameWeapon("deserteagle_fmj_mp");
    addFungameWeapon("deserteagle_tactical_mp");
    addFungameWeapon("deserteagle_akimbo_mp");
    addFungameWeapon("coltanaconda_mp");
    addFungameWeapon("coltanaconda_fmj_mp");
    addFungameWeapon("coltanaconda_tactical_mp");
    addFungameWeapon("coltanaconda_akimbo_mp");
    addFungameWeapon("usp_mp"); // Filler
    addFungameWeapon("beretta_mp"); // Filler

    // MACHINE PISTOLS (21-40)
    addFungameWeapon("glock_mp");
    addFungameWeapon("glock_silencer_mp");
    addFungameWeapon("glock_reflex_mp");
    addFungameWeapon("glock_akimbo_mp");
    addFungameWeapon("tmp_mp");
    addFungameWeapon("tmp_silencer_mp");
    addFungameWeapon("tmp_reflex_mp");
    addFungameWeapon("tmp_akimbo_mp");
    addFungameWeapon("beretta393_mp");
    addFungameWeapon("beretta393_silencer_mp");
    addFungameWeapon("beretta393_reflex_mp");
    addFungameWeapon("beretta393_akimbo_mp");
    addFungameWeapon("pp2000_mp");
    addFungameWeapon("pp2000_silencer_mp");
    addFungameWeapon("pp2000_reflex_mp");
    addFungameWeapon("pp2000_akimbo_mp");
    addFungameWeapon("glock_eotech_mp");
    addFungameWeapon("tmp_eotech_mp");
    addFungameWeapon("beretta393_eotech_mp");
    addFungameWeapon("pp2000_eotech_mp");

    wait .05;
    // SHOTGUNS (41-60)
    addFungameWeapon("spas12_mp");
    addFungameWeapon("spas12_grip_mp");
    addFungameWeapon("spas12_silencer_mp");
    addFungameWeapon("spas12_reflex_mp");
    addFungameWeapon("m1014_mp");
    addFungameWeapon("m1014_grip_mp");
    addFungameWeapon("m1014_silencer_mp");
    addFungameWeapon("m1014_reflex_mp");
    addFungameWeapon("aa12_mp");
    addFungameWeapon("aa12_grip_mp");
    addFungameWeapon("aa12_silencer_mp");
    addFungameWeapon("aa12_reflex_mp");
    addFungameWeapon("striker_mp");
    addFungameWeapon("striker_grip_mp");
    addFungameWeapon("striker_silencer_mp");
    addFungameWeapon("striker_reflex_mp");
    addFungameWeapon("ranger_mp");
    addFungameWeapon("ranger_akimbo_mp");
    addFungameWeapon("model1887_mp");
    addFungameWeapon("model1887_akimbo_mp");

    wait .05;
    // SMGS (61-90)
    addFungameWeapon("mp5k_mp");
    addFungameWeapon("mp5k_silencer_mp");
    addFungameWeapon("mp5k_reflex_mp");
    addFungameWeapon("mp5k_akimbo_mp");
    addFungameWeapon("mp5k_rof_mp");
    addFungameWeapon("uzi_mp");
    addFungameWeapon("uzi_silencer_mp");
    addFungameWeapon("uzi_reflex_mp");
    addFungameWeapon("uzi_akimbo_mp");
    addFungameWeapon("uzi_rof_mp");
    addFungameWeapon("p90_mp");
    addFungameWeapon("p90_silencer_mp");
    addFungameWeapon("p90_reflex_mp");
    addFungameWeapon("p90_akimbo_mp");
    addFungameWeapon("p90_rof_mp");
    addFungameWeapon("kriss_mp");
    addFungameWeapon("kriss_silencer_mp");
    addFungameWeapon("kriss_reflex_mp");
    addFungameWeapon("kriss_akimbo_mp");
    addFungameWeapon("kriss_rof_mp");
    addFungameWeapon("ump45_mp");
    addFungameWeapon("ump45_silencer_mp");
    addFungameWeapon("ump45_reflex_mp");
    addFungameWeapon("ump45_akimbo_mp");
    addFungameWeapon("ump45_rof_mp");
    addFungameWeapon("ak74u_mp");
    addFungameWeapon("mp5k_acog_mp");
    addFungameWeapon("p90_acog_mp");
    addFungameWeapon("kriss_acog_mp");
    addFungameWeapon("ump45_acog_mp");

    wait .05;
    // ASSAULT RIFLES (91-120)
    addFungameWeapon("m4_mp");
    addFungameWeapon("m4_silencer_mp");
    addFungameWeapon("m4_reflex_mp");
    addFungameWeapon("m4_acog_mp");
    addFungameWeapon("m4_gl_mp");
    addFungameWeapon("scar_mp");
    addFungameWeapon("scar_silencer_mp");
    addFungameWeapon("scar_reflex_mp");
    addFungameWeapon("scar_acog_mp");
    addFungameWeapon("scar_gl_mp");
    addFungameWeapon("tavor_mp");
    addFungameWeapon("tavor_silencer_mp");
    addFungameWeapon("tavor_reflex_mp");
    addFungameWeapon("tavor_acog_mp");
    addFungameWeapon("tavor_gl_mp");
    addFungameWeapon("masada_mp");
    addFungameWeapon("masada_silencer_mp");
    addFungameWeapon("masada_reflex_mp");
    addFungameWeapon("masada_acog_mp");
    addFungameWeapon("masada_gl_mp");
    addFungameWeapon("ak47_mp");
    addFungameWeapon("ak47_silencer_mp");
    addFungameWeapon("ak47_reflex_mp");
    addFungameWeapon("ak47_acog_mp");
    addFungameWeapon("ak47_gl_mp");
    addFungameWeapon("famas_mp");
    addFungameWeapon("famas_silencer_mp");
    addFungameWeapon("famas_reflex_mp");
    addFungameWeapon("famas_acog_mp");
    addFungameWeapon("famas_fmj_mp");
    addFungameWeapon("fal_mp");
    addFungameWeapon("fal_silencer_mp");
    addFungameWeapon("fal_reflex_mp");
    addFungameWeapon("fal_acog_mp");
    addFungameWeapon("fal_gl_mp");
    addFungameWeapon("m16_mp");
    addFungameWeapon("m16_silencer_mp");
    addFungameWeapon("m16_reflex_mp");
    addFungameWeapon("m16_acog_mp");
    addFungameWeapon("m16_gl_mp");
    addFungameWeapon("ak47classic_mp");

    wait .05;
    // LMGS (121-135)
    addFungameWeapon("rpd_mp");
    addFungameWeapon("rpd_grip_mp");
    addFungameWeapon("rpd_reflex_mp");
    addFungameWeapon("mg4_mp");
    addFungameWeapon("mg4_grip_mp");
    addFungameWeapon("mg4_reflex_mp");
    addFungameWeapon("aug_mp");
    addFungameWeapon("aug_grip_mp");
    addFungameWeapon("aug_reflex_mp");
    addFungameWeapon("m240_mp");
    addFungameWeapon("m240_grip_mp");
    addFungameWeapon("m240_reflex_mp");
    addFungameWeapon("sa80_mp");
    addFungameWeapon("sa80_grip_mp");
    addFungameWeapon("sa80_reflex_mp");

    // SNIPERS (136-145)
    addFungameWeapon("cheytac_mp");
    addFungameWeapon("cheytac_acog_mp");
    addFungameWeapon("cheytac_thermal_mp");
    addFungameWeapon("barrett_mp");
    addFungameWeapon("barrett_acog_mp");
    addFungameWeapon("barrett_thermal_mp");
    addFungameWeapon("wa2000_mp");
    addFungameWeapon("wa2000_thermal_mp");
    addFungameWeapon("m21_mp");
    addFungameWeapon("m21_thermal_mp");

    // LAUNCHERS & SPECIAL (146-150)
    addFungameWeapon("m79_mp");
    addFungameWeapon("rpg_mp");
    addFungameWeapon("at4_mp");
    addFungameWeapon("riotshield_mp");
    addFungameWeapon("javelin_mp");

    level.gungameList = [];
    level.gungameList[0] = "defaultweapon_mp";

    amount = getDvarInt("amount_weapons");
    if(amount <= 0 || amount > level.fungameWeapons.size)
        amount = level.fungameWeapons.size;

    shuffle = getDvarInt("shuffle_weapons");

    for(i = 0; i < amount; i++)
    {
        if(shuffle)
        {
            id = randomInt(level.fungameWeapons.size);
            level.gungameList[level.gungameList.size] = level.fungameWeapons[id];
            level.fungameWeapons = removeIDfromArray(id, level.fungameWeapons);
        }
        else
        {
            level.gungameList[level.gungameList.size] = level.fungameWeapons[i];
        }
    }
    level.weaponsLoaded = true; // signal that the list is ready for use
}

addFungameWeapon(weapon)
{
    level.fungameWeapons[level.fungameWeapons.size] = weapon;
}
isSMG(name)
{
    ar = [];
    ar[ar.size] = "mp5k";
    ar[ar.size] = "uzi";
    ar[ar.size] = "p90";
    ar[ar.size] = "kriss";
    ar[ar.size] = "ump45";
    ar[ar.size] = "ak74u"; //?
    foreach(a in ar)
    {
        if(name == a)
            return true;
    }
    return false;
}