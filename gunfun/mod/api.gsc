#include common_scripts\utility; 
#include maps\mp\_utility; 
#include maps\mp\gametypes\_hud_util;

// For sending data, you use - as split character and for response I use | as split character
// all-10 => top 10 guids split by |

Init()
{
    if(true) // unfinished script
        return;
    //level.api = "http://178.63.44.165:80831/";
    level.api = "";
    level.chatCommands = [];
    level.chatCommands[level.chatCommands.size] = "register";
    level.chatCommands[level.chatCommands.size] = "increment";
    level.chatCommands[level.chatCommands.size] = "all";
    level.chatCommands[level.chatCommands.size] = "read";
    thread onSay();
    thread onPlayerConnect();
}
onPlayerConnect()
{
    while(true)
    {
        level waittill("connected", player);
        player thread tryCallApi("register");
    }
}
onSay()
{
    while(true)
    {
        level waittill("say", string, player);
        iprintlnBold(string + " " + player.name);
        player thread checkString(string);
    }
}
checkString(string)
{
    if(string[0] != "!" && string[0] != "-")
        return;
    string = GetSubStr(string,1); //GetSubStr( <string>, <start index>, <end index> ) 
    iPrintln(string);
    cmd = strTok(string, " ");
    foreach(chat in level.chatCommands)
    {
        if(chat == cmd[0])
            self callApi(chat);
    }       
}
callApi(string)
{
    list = httpGet(level.api + "");
    list waittill("done", success, data);
    if(!success)  
        return "error";
    iPrintln("^2green");    
    return data;   
}
tryCallApi(parameter)
{
    data = self callApi("!" + parameter + "-" + self.guid);
    if(!isDefined(data))
        self iPrintlnBold(parameter + " was successful");
    else if(data == "error")
        self iPrintlnBold("^1error calling the api");
    else    
    {
        wait 2;
        ar = strTok(data, "|");
        foreach(a in ar)
          self iPrintlnBold(a);
    }  
}
